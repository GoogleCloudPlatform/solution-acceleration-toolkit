# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

# Don't set -e, want to capture the output of missing files.

# Print versions
go version

# Install license headers checker.
# Switch directories to avoid changing go.mod and go.sum files (see https://stackoverflow.com/a/57313319).
(cd / && go get -u github.com/google/addlicense)

# Check for missing license headers
missing="$(find -name "*.go" | xargs addlicense -check)"
if [ -n "${missing}" ]; then
  cat <<EOF

Files missing license headers:
${missing}

To fix, run the following:
go get -u github.com/google/addlicense
addlicense -c "Google LLC" -l "apache" .
EOF

  exit 1
fi
