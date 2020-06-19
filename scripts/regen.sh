# Copyright 2020 Google LLC
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

# Helper to regenerate generated files.
rm -rf examples/*/generated/*
go run ./cmd/policygen --config_path examples/policygen/config.yaml --output_path examples/policygen/generated --state_path examples/policygen/example.tfstate

for f in org_foundation folder_foundation full
do
    go run ./cmd/tfengine --config_path examples/tfengine/$f.hcl --output_path examples/tfengine/generated/$f
done
