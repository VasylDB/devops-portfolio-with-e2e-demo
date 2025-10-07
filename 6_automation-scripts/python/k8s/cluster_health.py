import argparse
import sys
from kubernetes import client, config
from python.common.notify import slack_notify

# Basic cluster health summary: node Ready, pod Pending count, image pull errors, etc.

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--namespace", default=None, help="Limit checks to a specific namespace")
    args = ap.parse_args()

    config.load_kube_config()  # respects KUBECONFIG; in-cluster also works if available
    v1 = client.CoreV1Api()

    problems = 0

    # Nodes
    nodes = v1.list_node().items
    not_ready_nodes = []
    for n in nodes:
        ready = False
        for cond in n.status.conditions or []:
            if cond.type == "Ready" and cond.status == "True":
                ready = True
        if not ready:
            not_ready_nodes.append(n.metadata.name)
    if not_ready_nodes:
        print("[WARN] NotReady nodes:", ", ".join(not_ready_nodes))
        problems += 1
    else:
        print("[OK] All nodes Ready")

    # Pods
    ns = args.namespace
    pods = v1.list_namespaced_pod(ns).items if ns else v1.list_pod_for_all_namespaces().items
    pending = [p for p in pods if p.status.phase == "Pending"]
    if pending:
        print(f"[WARN] Pending pods: {len(pending)}")
        problems += 1
    else:
        print("[OK] No pending pods")

    # Image pull errors quick scan
    bad = []
    for p in pods:
        for cs in p.status.container_statuses or []:
            state = cs.state
            waiting = state.waiting
            if waiting and waiting.reason in ("ImagePullBackOff", "ErrImagePull"):
                bad.append((p.metadata.namespace, p.metadata.name, cs.name, waiting.reason))
    if bad:
        print("[WARN] Image pull issues:")
        for ns_, pod, c, r in bad:
            print(f"  - {ns_}/{pod}:{c} -> {r}")
        problems += 1
    else:
        print("[OK] No image pull issues")

    if problems:
        slack_notify(f"Cluster health found {problems} issues.")
        sys.exit(2)
    print("[OK] Cluster healthy")

if __name__ == "__main__":
    main()
