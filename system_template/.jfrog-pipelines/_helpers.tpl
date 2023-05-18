{{- define "sanity.qualifiedName" -}}
{{- "Sanity-Pipeline-Template-" | trunc 63 | trimSuffix "-" }}
{{- end }}
