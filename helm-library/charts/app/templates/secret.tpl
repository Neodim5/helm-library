{{- define "app.secret" -}}
{{- if .Values.secret.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "app.fullname" . }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- range $k, $v := .Values.env.secret }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
{{- end }}
{{- end }}
