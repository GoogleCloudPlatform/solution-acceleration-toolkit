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

package hcl

import (
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestToJSON(t *testing.T) {

	testHCL := []byte(`
string = "A"
bool = false
list = ["1", "2"]

object = {
	foo = {
		description = <<EOF
			A multi
			line string
		EOF
		type = "string"
	}

	bar = {
		type = "object"
		another_bool = false
		properties = {
			inner_1 = {
				type = "array"
				items = {
					type = "string"
				}
			}
			inner_2 = {
				description = "a boolean"
				type = "boolean"
			}
		}
	}
}`)

	want := []byte(`{"bool":false,"list":["1","2"],"object":{"bar":{"another_bool":false,"properties":{"inner_1":{"items":{"type":"string"},"type":"array"},"inner_2":{"description":"a boolean","type":"boolean"}},"type":"object"},"foo":{"description":"\t\t\tA multi\n\t\t\tline string\n","type":"string"}},"string":"A"}`)

	got, err := ToJSON([]byte(testHCL))
	if err != nil {
		t.Fatalf("hcl.ToJSON() = %v", err)
	}
	if diff := cmp.Diff(want, got); diff != "" {
		t.Errorf("hcl.ToJSON() returned diff (-want +got):\n%s", diff)
	}
}
