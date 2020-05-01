{{- range .OUTPUTS}}
output "{{.NAME}}" {
  value = {{.VALUE}}
}
{{- end}}
