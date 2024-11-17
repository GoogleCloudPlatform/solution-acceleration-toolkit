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

#!/usr/bin/env bash

# Helper script to install the latest version of GitHub Hub.

set -x

# See https://github.com/github/hub/blob/master/script/get
latest=" $(curl -fsi https://github.com/github/hub/releases/latest | awk -F/ 'tolower($1) ~ /^location:/ {print $(NF)}' | tr -d '\r')"
latest="${latest#v}"

# Install the latest version
# See https://github.com/github/hub#github-actions
curl -fsSL https://github.com/github/hub/raw/master/script/get | bash -s "${latest}"
