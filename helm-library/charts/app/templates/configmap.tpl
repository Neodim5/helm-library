{{- define "app.configmap" -}}
{{- if .Values.configmap.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "app.fullname" . }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
data:
  {{- range $k, $v := .Values.env.configMap }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
{{- end }}
{{- end }}
