{{- range .VARS}}
{{- if has . "VALUE"}}
{{.NAME}} = {{.VALUE}}
{{- end}}
{{- end}}
