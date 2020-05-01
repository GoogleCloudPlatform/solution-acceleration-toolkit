
# Project level IAM permissions for project owners. Existing owners will not be removed.
resource "google_project_iam_member" "owners" {
  for_each = toset(var.owners)
  project  = module.project.project_id
  role     = "roles/owner"
  member   = each.value
}
