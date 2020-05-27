// Copyright 2020 Google LLC.
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

package template

import (
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestMergeData(t *testing.T) {
	cases := []struct {
		name    string
		dst     map[string]interface{}
		src     map[string]interface{}
		flatten []*FlattenInfo
		want    map[string]interface{}
	}{
		{
			name: "all_empty",
			dst:  map[string]interface{}{},
			want: map[string]interface{}{},
		},
		{
			name: "dst_only",
			dst: map[string]interface{}{
				"a": 1,
			},
			want: map[string]interface{}{
				"a": 1,
			},
		},
		{
			name: "src_only",
			dst:  map[string]interface{}{},
			src: map[string]interface{}{
				"a": 1,
			},
			want: map[string]interface{}{
				"a": 1,
			},
		},
		{
			name: "distinct",
			dst: map[string]interface{}{
				"a": 1,
			},
			src: map[string]interface{}{
				"b": 1,
			},
			want: map[string]interface{}{
				"a": 1,
				"b": 1,
			},
		},
		{
			name: "overlap",
			dst: map[string]interface{}{
				"a": 1,
			},
			src: map[string]interface{}{
				"a": 2,
			},
			want: map[string]interface{}{
				"a": 2,
			},
		},
		{
			name: "flatten_map",
			dst: map[string]interface{}{
				"a": 1,
			},
			src: map[string]interface{}{
				"b": map[string]interface{}{
					"c": 1,
				},
			},
			flatten: []*FlattenInfo{{Key: "b"}},
			want: map[string]interface{}{
				"a": 1,
				"c": 1,
			},
		},
		{
			name: "flatten_list",
			dst: map[string]interface{}{
				"a": 1,
			},
			src: map[string]interface{}{
				"bs": []interface{}{
					map[string]interface{}{"c": 1},
				},
			},
			flatten: []*FlattenInfo{{Key: "bs", Index: intPointer(0)}},
			want: map[string]interface{}{
				"a": 1,
				"c": 1,
			},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if err := MergeData(tc.dst, tc.src, tc.flatten); err != nil {
				t.Fatalf("MergeData: %v", err)
			}
			if diff := cmp.Diff(tc.dst, tc.want); diff != "" {
				t.Errorf("MergeData destination differs (-got +want):\n%v", diff)
			}
		})
	}
}
func TestWriteBuffer(t *testing.T) {
	type T map[string]interface{}
	tests := []struct {
		tmpl      string
		fieldsMap T
		want      string
	}{
		// Empty.
		{"", nil, ""},

		// Template doesn't use fields.
		{"mytext", T{"field1": "val1"}, "mytext"},

		// Simple string fields.
		{"field value is: {{.field1}}", T{"field1": "val1"}, "field value is: val1"},

		// Nested fields.
		{
			"nested value is: {{(index .field1 1).inner.leaf}}",
			T{
				"field1": []map[string]interface{}{
					nil,
					{
						"inner": map[string]interface{}{
							"leaf": "leaf value",
						},
					},
				},
			},
			"nested value is: leaf value",
		},
	}
	for _, tc := range tests {
		buf, err := WriteBuffer(tc.tmpl, tc.fieldsMap)
		if err != nil {
			t.Fatalf("fillTemplate(%v, %v) failed: %v", tc.tmpl, tc.fieldsMap, err)
		}
		got := buf.String()
		if !cmp.Equal(got, tc.want) {
			t.Errorf("fillTemplate(%v, %v) = %v; want %v", tc.tmpl, tc.fieldsMap, got, tc.want)
		}
	}
}

func TestWriteBufferErr(t *testing.T) {
	type T map[string]interface{}
	tests := []struct {
		tmpl      string
		fieldsMap T
	}{
		// Invalid character, should fail to parse.
		{"{{.field[0]}}", nil},

		// Missing key, should fail to execute.
		{"{{.field}}", nil},
	}
	for _, tc := range tests {
		_, err := WriteBuffer(tc.tmpl, tc.fieldsMap)
		if err == nil {
			t.Fatalf("fillTemplate(%v, %v) succeeded for malformed input, want error", tc.tmpl, tc.fieldsMap)
		}
	}
}

func intPointer(i int) *int {
	return &i
}
