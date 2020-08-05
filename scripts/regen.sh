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

gendir='./examples'
if [[ -n "${1}" ]]; then
  gendir="${1}"
fi

# Helper to regenerate generated files.
rm -rf ${gendir}/*/generated/*

# Policygen
go run ./cmd/policygen --config_path examples/policygen/config.hcl --output_path ${gendir}/policygen/generated --state_path examples/policygen/example.tfstate

# TF Engine
for example in examples/tfengine/*.hcl; do
  example_gendir="${gendir}/tfengine/generated/$(basename "${example}" | cut -d. -f1)"
  go run ./cmd/tfengine --config_path ${example} --output_path ${example_gendir}
done

# Schema docs
rm -rf ./docs/*/schemas/*
go run ./scripts/generate_schema_docs
