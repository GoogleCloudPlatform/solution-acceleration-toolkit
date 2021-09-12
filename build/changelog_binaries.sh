#!/usr/bin/env bash
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

# Generates a simple commit log for changes to the binaries between the last two tags.

latest_tag="$(git tag | grep '^v.*' | sort -Vr | head -1)"
previous_tag="$(git tag | grep '^v.*' | sort -Vr | head -2 | tail -1)"
echo -e "Changes:\n$(git log --pretty='format:- %s (by %an) on %cs' ${previous_tag}..${latest_tag} -- internal/ cmd/ go.mod)"
