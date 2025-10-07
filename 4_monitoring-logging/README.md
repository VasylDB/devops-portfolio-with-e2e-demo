# Monitoring & Logging on Windows 10 (Docker Desktop + kind) — with ELK (mandatory)

End‑to‑end mini‑portfolio that demonstrates two complementary stacks:
- **Prometheus + Alertmanager** for metrics and alerting
- **Grafana** dashboards (Prometheus + Loki as data sources)
- **Loki + Promtail** for centralized container logs
- **ELK (Elasticsearch + Logstash + Kibana + Filebeat)** as a full log analytics stack (MANDATORY part of this project)

> All commands below are **PowerShell**.  
> When creating files from the terminal we use PowerShell here-strings `@'…'@` piped into `kubectl` or saved to disk.

---

## 0) Prerequisites
- Windows 10 with **Docker Desktop** (WSL2 backend).
- **kubectl**, **helm**, **kind** on PATH.
- **curl** available (ships with modern Windows 10).

Quick check:
```powershell
kubectl version --client=true
helm version --short
kind version
```

---

## 1) Create a local Kubernetes cluster (kind)
```powershell
kind create cluster --name monlog
kubectl cluster-info --context kind-monlog
```
This spins up a Docker‑backed K8s cluster named `monlog` and prints the control plane/CoreDNS addresses.

Create namespaces:
```powershell
@"
apiVersion: v1
kind: Namespace
metadata: { name: monitoring }
---
apiVersion: v1
kind: Namespace
metadata: { name: logging }
"@ | kubectl apply -f -
```

---

## 2) Add Helm repositories
```powershell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

---

## 3) kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
Create values:
```powershell
New-Item -ItemType Directory -Force -Path k8s\prometheus | Out-Null
@'
grafana:
  adminPassword: "admin"
  defaultDashboardsEnabled: false
  additionalDataSources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki.logging.svc.cluster.local:3100
      isDefault: false
  sidecar:
    dashboards: { enabled: true, searchNamespace: ALL }
    datasources: { enabled: true }

prometheus:
  prometheusSpec:
    retention: 15d
    scrapeInterval: 30s
    evaluationInterval: 30s
    ruleSelectorNilUsesHelmValues: false

alertmanager:
  config:
    route:
      receiver: "default"
      group_by: ["alertname","namespace","severity"]
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 4h
      routes:
        - matchers: [severity="critical"]
          receiver: "critical"
    receivers:
      - name: "default"
        webhook_configs:
          - url: "http://example-webhook.monitoring.svc.cluster.local:8080/"
      - name: "critical"
        email_configs:
          - to: "alerts@example.com"
            from: "noreply@example.com"
            smarthost: "smtp.example.com:587"
            auth_username: "noreply@example.com"
            auth_password: "REPLACE_ME"
  ingress: { enabled: false }
'@ | Set-Content -Path k8s\prometheus\values-kube-prom-stack.yaml
```

Install:
```powershell
helm upgrade --install kps prometheus-community/kube-prometheus-stack `
  -n monitoring `
  -f k8s\prometheus\values-kube-prom-stack.yaml
```

Add a few basic alerting rules:
```powershell
@'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata: { name: k8s-basic-alerts, namespace: monitoring }
spec:
  groups:
    - name: k8s.basic.rules
      rules:
        - alert: NodeHighCPU
          expr: 100 - (avg by (instance)(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
          for: 10m
          labels: { severity: warning }
          annotations:
            summary: "High CPU on {{ $labels.instance }}"
            description: "CPU usage >85% for 10m"
        - alert: PodCrashLooping
          expr: increase(kube_pod_container_status_restarts_total[10m]) > 3
          for: 10m
          labels: { severity: critical }
          annotations:
            summary: "CrashLoop in {{ $labels.namespace }}/{{ $labels.pod }}"
            description: "Container restarting frequently"
        - alert: LokiErrorSpike
          expr: sum(rate(loki_distributor_ingester_appends_failed_total[5m])) > 0
          for: 5m
          labels: { severity: warning }
          annotations:
            summary: "Loki ingestion errors"
            description: "Loki is failing to ingest logs"
'@ | Set-Content -Path k8s\prometheus\prometheus-rules.yaml

kubectl apply -f k8s\prometheus\prometheus-rules.yaml
```

---

## 4) Loki + Promtail
Values and install:
```powershell
New-Item -ItemType Directory -Force -Path k8s\loki | Out-Null
@'
loki:
  auth_enabled: false
  commonConfig: { replication_factor: 1 }
  storage: { type: filesystem }
  ruler:
    enabled: true
    alertmanager_url: http://kps-kube-prometheus-stack-alertmanager.monitoring.svc:9093

grafana: { enabled: false }

promtail:
  enabled: true
  config:
    clients:
      - url: http://loki.logging.svc.cluster.local:3100/loki/api/v1/push
    snippets:
      pipelineStages:
        - docker: {}
        - cri: {}
'@ | Set-Content -Path k8s\loki\values-loki-stack.yaml

helm upgrade --install loki grafana/loki-stack `
  -n logging `
  -f k8s\loki\values-loki-stack.yaml
```

---

## 5) Grafana: datasources and dashboards
Datasources (note the **correct** Prometheus service URL):
```powershell
New-Item -ItemType Directory -Force -Path k8s\grafana\dashboards | Out-Null
@'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://kps-kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090
    isDefault: true
  - name: Loki
    type: loki
    access: proxy
    url: http://loki.logging.svc.cluster.local:3100
'@ | Set-Content -Path k8s\grafana\datasources.yaml

kubectl -n monitoring create configmap grafana-datasources `
  --from-file=datasources.yaml=k8s\grafana\datasources.yaml `
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring label configmap grafana-datasources grafana_datasource="1" --overwrite
```

Dashboards as ConfigMaps (already included in `k8s/grafana/dashboards`):
- **Nodes Overview** — CPU/Memory as time series
- **K8s Workloads** — pod restarts & container CPU
- **App Error Rate (Loki)** — a `stat` + `logs` panel bound to the Loki datasource

Port-forward Grafana:
```powershell
kubectl -n monitoring port-forward svc/kps-grafana 3000:80
```
Login at http://localhost:3000 (admin/admin from values).

---

## 6) Demo log generator (for Loki)
PowerShell often breaks shell one-liners; use a Deployment:
```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata: { name: error-logger, namespace: default }
spec:
  replicas: 1
  selector: { matchLabels: { app: error-logger } }
  template:
    metadata: { labels: { app: error-logger } }
    spec:
      containers:
        - name: logger
          image: busybox:1.36
          command: ["/bin/sh","-c"]
          args:
            - |
              i=0
              while true; do
                echo "ERROR: demo log $i"
                i=$((i+1))
                sleep 1
              done
          resources: { requests: { cpu: "10m", memory: "16Mi" } }
'@ | kubectl apply -f -

kubectl -n default logs deploy/error-logger --tail=10
```

---

## 7) Alertmanager smoke tests
Always-firing rule:
```powershell
@'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata: { name: demo-always-firing, namespace: monitoring }
spec:
  groups:
    - name: demo.always
      rules:
        - alert: AlwaysFiring
          expr: vector(1) == 1
          for: 1m
          labels: { severity: critical }
          annotations:
            summary: "Demo alert is firing"
            description: "Pipeline check."
'@ | kubectl apply -f -
```
Alertmanager UI:
```powershell
kubectl -n monitoring port-forward svc/kps-kube-prometheus-stack-alertmanager 9093:9093
```
Open http://localhost:9093 → **Alerts**.

(Optionally) deploy a webhook echo to verify deliveries:
```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata: { name: example-webhook, namespace: monitoring }
spec:
  replicas: 1
  selector: { matchLabels: { app: example-webhook } }
  template:
    metadata: { labels: { app: example-webhook } }
    spec:
      containers:
      - name: echo
        image: ealen/echo-server:latest
        ports: [ { containerPort: 80 } ]
---
apiVersion: v1
kind: Service
metadata: { name: example-webhook, namespace: monitoring }
spec:
  selector: { app: example-webhook }
  ports: [ { name: http, port: 8080, targetPort: 80 } ]
'@ | kubectl apply -f -

kubectl -n monitoring logs deploy/example-webhook --tail=100
```

---

# 8) ELK stack — **MANDATORY**

### 8.1 Why ELK here
- Show a mature log analytics pipeline (Beats/Logstash routing, parsing, normalization).
- Demonstrate parallel indices (app vs nginx), ILM retention, Kibana dashboards & alerting.

### 8.2 Elasticsearch requirement in Docker Desktop (vm.max_map_count)
If Elasticsearch fails to start, bump `vm.max_map_count` inside the Docker Desktop Linux VM:
```powershell
wsl -d docker-desktop sh -lc "sysctl -w vm.max_map_count=262144"
```

### 8.3 Project files (already included under `elk-docker/`)
- **docker-compose.yml** — runs Elasticsearch 8.x (security disabled), Kibana, Logstash, Filebeat, plus two log generators:
  - `app-json-writer` produces JSON lines like `{ "@timestamp": "...", "level": "error|info", "service": "orders-api", "env": "dev", "message": "..." }` into `/logs/app/app.json`
  - `nginx` writes standard combined access logs to `/var/log/nginx/access.log`
- **filebeat.yml** — tails both sources and ships to Logstash (5044).
- **logstash.conf** — branches by `fields.log_type`:
  - **app-json** → normalize fields (ECS‑friendly), index `logs-app-YYYY.MM.dd`
  - **nginx** → GROK parse, index `logs-nginx-YYYY.MM.dd`

### 8.4 Run ELK
```powershell
cd elk-docker
docker compose up -d
docker compose ps
```
Endpoints:
- Elasticsearch → http://localhost:9200  
- Kibana → http://localhost:5601  
- Logstash Beats input → tcp://localhost:5044

### 8.5 Verify indices
After 15–30s:
```powershell
curl http://localhost:9200/_cat/indices?v
```
You should see `logs-app-*` and `logs-nginx-*`.

### 8.6 Create a Kibana Data View (via API)
```powershell
curl -X POST "http://localhost:5601/api/data_views/data_view" `
 -H "kbn-xsrf: true" -H "Content-Type: application/json" `
 -d "{""data_view"":{""title"":""logs-*"",""name"":""Logs (app+nginx)"",""id"":""logs-all"",""timeFieldName"":""@timestamp""}}"
```
Or do it in UI: **Stack Management → Data views → Create** with `logs-*` and `@timestamp`.

### 8.7 Useful KQL queries in Discover
- App errors: `event.dataset : "app" and log.level : "error"`  
- Nginx 5xx: `event.dataset : "nginx" and http.response.status_code >= 500`  
- Specific path: `event.dataset : "nginx" and url.path : "/api/v1/orders"`

### 8.8 Build a Kibana dashboard
1) **App Error Rate** (Area): filter `event.dataset:"app" and log.level:"error"`, X: Date histogram `@timestamp`, Y: Count.  
2) **Top error messages** (Terms): field `message` + same filter.  
3) **Nginx status codes over time** (Stacked area): split series by `http.response.status_code`.  
4) **Top URLs** (Horizontal bar): field `url.path`, filter `event.dataset:"nginx"`.

> If you want, import a prebuilt Dashboard via Saved Objects (NDJSON) — I can provide one.

### 8.9 ILM retention (7 days) and index template
```powershell
# ILM policy: delete after 7 days
curl -X PUT "http://localhost:9200/_ilm/policy/logs_7d" -H "Content-Type: application/json" `
 -d "{""policy"":{""phases"":{""hot"":{""actions"":{}},""delete"":{""min_age"":""7d"",""actions"":{""delete"":{}}}}}}"

# Composable index template for logs-*
curl -X PUT "http://localhost:9200/_index_template/logs-template" -H "Content-Type: application/json" `
 -d "{""index_patterns"":[""logs-*""],""template"":{""settings"":{""index.lifecycle.name"":""logs_7d"",""number_of_shards"":1,""number_of_replicas"":0}}}"
```

### 8.10 Kibana rule‑based alert
When app errors > 50 over 5 minutes:
- **Stack Management → Rules → Create rule → Elasticsearch query**
- Index: `logs-*`
- KQL: `event.dataset:"app" and log.level:"error"`
- Condition: `Count is above 50 for the last 5 minutes`
- Choose a connector (Email/Slack/Webhook).

### 8.11 ELK troubleshooting
- **ES won’t start / OOM** → lower heap (`ES_JAVA_OPTS=-Xms512m -Xmx512m`), set `vm.max_map_count`.
- **Beats not reaching Logstash** → check `5044` is listening, verify `output.logstash` hosts.
- **Empty Kibana** → ensure indices exist; create the Data View.
- **GROK failures** → adjust the grok pattern in `logstash.conf` or switch to dissect.

---

## 9) Cleanup
Kubernetes:
```powershell
kind delete cluster --name monlog
```
ELK:
```powershell
cd elk-docker
docker compose down -v
```

---

## 10) Repository tree
```
devops-monlog-portfolio/
├─ k8s/
│  ├─ namespaces.yaml
│  ├─ prometheus/
│  │  ├─ values-kube-prom-stack.yaml
│  │  └─ prometheus-rules.yaml
│  ├─ loki/
│  │  └─ values-loki-stack.yaml
│  └─ grafana/
│     ├─ datasources.yaml
│     └─ dashboards/
│        ├─ nodes-overview.json
│        ├─ k8s-workloads.json
│        └─ logs-error-rate.json
└─ elk-docker/
   ├─ docker-compose.yml
   ├─ logstash.conf
   └─ filebeat.yml
```

---

## 11) Troubleshooting (Windows notes)
- If Grafana shows `no such host` for Prometheus, double‑check the service FQDN:  
  `kps-kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090`.  
  Recreate the ConfigMap and restart Grafana:
  ```powershell
  kubectl -n monitoring create configmap grafana-datasources --from-file=datasources.yaml=k8s\grafana\datasources.yaml --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n monitoring rollout restart deploy/kps-grafana
  ```
- If a Loki panel shows `parse error: unexpected character '|'` → the panel’s datasource is Prometheus, not Loki. Edit the JSON to set `"type": "loki"`.
- If Grafana doesn’t pick up ConfigMaps → restart Grafana:
  ```powershell
  kubectl -n monitoring rollout restart deploy/kps-grafana
  ```
- PowerShell quoting can break shell loops; prefer multi‑line YAML Deployments (as shown).
