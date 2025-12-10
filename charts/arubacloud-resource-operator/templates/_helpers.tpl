{{/*
Expand the name of the chart.
*/}}
{{- define "operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "operator.labels" -}}
helm.sh/chart: {{ include "operator.chart" . }}
{{ include "operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "operator.serviceAccountName" -}}
{{- $default := (include "operator.fullname" .) }}
{{- with .Values.serviceAccount }}
{{- if .create }}
{{- default $default .name }}
{{- else }}
{{- default "default" .name }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the metrics service name with truncation to stay within 63 character limit
*/}}
{{- define "operator.metricsServiceName" -}}
{{- $fullname := include "operator.fullname" . -}}
{{- printf "%s-metrics" $fullname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the controller manager name with truncation
*/}}
{{- define "operator.controllerManagerName" -}}
{{- $fullname := include "operator.fullname" . -}}
{{- printf "%s-controller" $fullname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the leader election role name with truncation
*/}}
{{- define "operator.leaderElectionRoleName" -}}
{{- $fullname := include "operator.fullname" . -}}
{{- printf "%s-leader" $fullname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the manager role name with truncation
*/}}
{{- define "operator.managerRoleName" -}}
{{- $fullname := include "operator.fullname" . -}}
{{- printf "%s-manager" $fullname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the metrics auth role name with truncation
*/}}
{{- define "operator.metricsAuthRoleName" -}}
{{- $fullname := include "operator.fullname" . -}}
{{- printf "%s-metrics-auth" $fullname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the metrics reader role name with truncation
*/}}
{{- define "operator.metricsReaderRoleName" -}}
{{- $fullname := include "operator.fullname" . -}}
{{- printf "%s-metrics-reader" $fullname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "operator.config" -}}
operator-config
{{- end }}