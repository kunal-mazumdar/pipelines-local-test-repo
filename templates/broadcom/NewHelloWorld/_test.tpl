{{/*
Expand the name of the chart.
*/}}
{{- define "sanity.name" -}}
{{- "Sanity-Pipeline-Template-" | trunc 63 | trimSuffix "-" }}
{{- end }}