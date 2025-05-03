{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "fullname" -}}
{{- printf "%s-%s" .Release.Name (include "name" .) -}}
{{- end -}}
