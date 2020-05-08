{{- if has . "MASTER_AUTHORIZED_NETWORKS"}}
master_authorized_networks = [
  {{- range .MASTER_AUTHORIZED_NETWORKS}}
  {
    cidr_block   = "{{.CIDR_BLOCK}}"
    display_name = "{{.DISPLAY_NAME}}"
  },
  {{- end}}
]
{{- end}}
