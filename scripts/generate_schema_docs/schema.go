// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

// schema is a subset of json schema.
type schema struct {
	Title                string               `json:"title"`
	AdditionalProperties bool                 `json:"additionalProperties"`
	Properties           map[string]*property `json:"properties"`
}

type property struct {
	Description          string               `json:"description"`
	Type                 string               `json:"type"`
	Pattern              string               `json:"pattern"`
	AdditionalProperties bool                 `json:"additionalProperties"`
	Properties           map[string]*property `json:"properties"`
	Items                *property            `json:"items"`
}
