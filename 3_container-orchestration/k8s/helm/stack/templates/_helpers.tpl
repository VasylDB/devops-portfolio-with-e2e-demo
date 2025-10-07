{{- define "stack.labels" -}}
app.kubernetes.io/name: {{ include "stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "stack.name" -}}
{{ .Chart.Name }}
{{- end }}
