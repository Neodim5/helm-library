{{- define "app.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "app.fullname" . }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.deployment.replicas }}
  strategy:
    type: {{ .Values.deployment.strategy.type }}
  selector:
    matchLabels:
      {{- include "app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.deployment.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "app.selectorLabels" . | nindent 8 }}
        {{- with .Values.deployment.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with .Values.image.pullSecrets }}
      imagePullSecrets:
        {{- range . }}
        - name: {{ . }}
        {{- end }}
      {{- end }}
      {{- with .Values.securityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: app
          image: {{ include "app.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- if or .Values.configmap.enabled .Values.secret.enabled .Values.env.plain }}
          env:
            {{- range $k, $v := .Values.env.plain }}
            - name: {{ $k }}
              value: {{ $v | quote }}
            {{- end }}
          {{- end }}
          {{- if or .Values.configmap.enabled .Values.secret.enabled }}
          envFrom:
            {{- if .Values.configmap.enabled }}
            - configMapRef:
                name: {{ include "app.fullname" . }}
            {{- end }}
            {{- if .Values.secret.enabled }}
            - secretRef:
                name: {{ include "app.fullname" . }}
            {{- end }}
          {{- end }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          {{- if .Values.probes.enabled }}
          {{- if eq .Values.probes.liveness.type "http" }}
          livenessProbe:
            httpGet:
              path: {{ .Values.probes.liveness.path }}
              port: {{ .Values.probes.liveness.port }}
          {{- else if eq .Values.probes.liveness.type "tcp" }}
          livenessProbe:
            tcpSocket:
              port: {{ .Values.probes.liveness.port }}
          {{- end }}
          {{- if eq .Values.probes.readiness.type "http" }}
          readinessProbe:
            httpGet:
              path: {{ .Values.probes.readiness.path }}
              port: {{ .Values.probes.readiness.port }}
          {{- else if eq .Values.probes.readiness.type "tcp" }}
          readinessProbe:
            tcpSocket:
              port: {{ .Values.probes.readiness.port }}
          {{- end }}
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          {{- if or .Values.security.runAsNonRoot .Values.security.readOnlyRootFilesystem }}
          securityContext:
            {{- if .Values.security.runAsNonRoot }}
            runAsNonRoot: {{ .Values.security.runAsNonRoot }}
            {{- end }}
            {{- if .Values.security.readOnlyRootFilesystem }}
            readOnlyRootFilesystem: {{ .Values.security.readOnlyRootFilesystem }}
            {{- end }}
          {{- end }}
      {{- with .Values.scheduling.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.scheduling.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.scheduling.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
