{{range get . "STORAGE_BUCKETS"}}
module "{{resourceName .NAME}}" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "{{.NAME}}"
  project_id = var.project_id
  {{- if has . "LOCATION"}}
  location   = "{{.LOCATION}}"
  {{- else}}
  location   = "{{$.STORAGE_BUCKET_LOCATION}}"
  {{- end}}

  {{- if index . "IAM_MEMBERS"}}
  iam_members = [
    {{- range .IAM_MEMBERS}}
    {
      role   = "{{.ROLE}}"
      member = "{{.MEMBER}}"
    },
    {{- end}}
  ]
  {{- end}}
}
{{end}}
