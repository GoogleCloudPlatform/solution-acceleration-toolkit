# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

allowed_policy_member_customer_ids = [
  "example_customer_id",
]
allowed_shared_vpc_host_projects = [
  "under:folders/12345678",
]
allowed_trusted_image_projects = [
  "projects/example-image-project",
]
allowed_public_vms = [
  "projects/example-project/zones/us-central1-a/instances/example-public-instance",
]
allowed_ip_forwarding_vms = [
  "projects/example-project/zones/us-central1-a/instances/example-routing-instance",
]
