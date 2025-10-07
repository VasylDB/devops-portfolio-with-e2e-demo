{{- define "service-api.name" -}}
service-api
{{- end -}}
{{- define "service-api.fullname" -}}
{{ include "service-api.name" . }}
{{- end -}}
