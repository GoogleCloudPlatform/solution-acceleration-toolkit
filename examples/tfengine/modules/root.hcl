# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

schema = {
  title                = "Root module"
  description          = "This module is reusable so that it can be used both as an example and during integration tests."
  additionalProperties = false
  properties = {
    recipes = {
      description = "Recipe path."
      type        = "string"
    }
    folder_id = {
      description = "ID of folder to create projects."
      type        = "string"
      pattern     = "^[0-9]{8,25}$"
    }
    billing_account = {
      description = "ID of billing account to associate projects with."
      type        = "string"
    }
    state_bucket = {
      description = "Name of the state bucket."
      type        = "string"
    }
    prefix = {
      description = "Prefix to attach to all global resources (e.g. project IDs and storage buckets)."
      type        = "string"
      pattern     = "^[a-z0-9]+$"
    }
    env = {
      description = "Env code."
      type        = "string"
    }
    domain = {
      description = "Domain of groups."
      type        = "string"
    }
    default_location = {
      description = "Default region for resources."
      type        = "string"
    }
    default_zone = {
      description = "Default zone for resources."
      type        = "string"
    }
    labels = {
      description = "Label map."
    }
  }
}

template "foundation" {
  recipe_path = "./foundation.hcl"
  data = {
    recipes     = "../{{.recipes}}"
    parent_type = "folder"
    parent_id   = "{{.folder_id}}"
  }
}

template "main" {
  recipe_path = "./team.hcl"
  data = {
    recipes     = "../{{.recipes}}"
    parent_type = "folder"
    parent_id   = "{{.folder_id}}"
  }
}
