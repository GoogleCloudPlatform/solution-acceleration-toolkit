# Copyright 2020 Google Inc.
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

#!/usr/bin/env bash

# Helper script to run terragrunt command and suppress verbose command outputs.

set -e

filter_regex="[terragrunt].*\(Setting\|Module.*dep\|Module.*skip\|Running command\|Reading\|Initializing\|Are you sure\|The non-interactive\)"

function plan_all() {
  terragrunt plan-all --terragrunt-non-interactive -lock=false -compact-warnings -out=plan.tfplan 2> >(grep -v "${filter_regex}" >&2)
}

function apply_all() {
  terragrunt apply-all --terragrunt-non-interactive -compact-warnings 2> >(grep -v "${filter_regex}" >&2)
}

case "$1" in
  plan-all)
      plan_all
      ;;
  apply-all)
      apply_all
      ;;
  *)
      echo $"Usage: $0 {plan-all|apply-all}"
      exit 1
esac
