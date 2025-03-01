{{- define "jena-fuseki.podTemplate" }}
metadata:
  {{- with .Values.podAnnotations }}
  annotations:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  labels:
    {{- include "jena-fuseki.labels" . | nindent 8 }}
    {{- with .Values.podLabels }}
    {{- toYaml . | nindent 8 }}
    {{- end }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  serviceAccountName: {{ include "jena-fuseki.serviceAccountName" . }}
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 8 }}
  containers:
    - name: {{ .Chart.Name }}
      securityContext:
        {{- toYaml .Values.securityContext | nindent 12 }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      env:
        - name: ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ include "jena-fuseki.fullname" . }}
              key: password
      ports:
        - name: http
          containerPort: {{ .Values.service.port }}
          protocol: TCP
      livenessProbe:
        {{- toYaml .Values.livenessProbe | nindent 12 }}
      readinessProbe:
        {{- toYaml .Values.readinessProbe | nindent 12 }}
      resources:
        {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.volumeMounts }}
      volumeMounts:
        {{- toYaml . | nindent 12 }}
      {{- end }}
  {{- with .Values.volumes }}
  volumes:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 8 }}
  {{- end }}
{{- end }}