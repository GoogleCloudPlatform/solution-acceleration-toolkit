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
	"github.com/google/go-cmp/cmp/cmpopts"
)

func TestMergeData(t *testing.T) {
	cases := []struct {
		name string
		dst  map[string]interface{}
		src  map[string]interface{}
		want map[string]interface{}
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
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if err := MergeData(tc.dst, tc.src); err != nil {
				t.Fatalf("MergeData: %v", err)
			}
			if diff := cmp.Diff(tc.want, tc.dst); diff != "" {
				t.Errorf("MergeData destination differs (-want +got):\n%v", diff)
			}
		})
	}
}

func TestFlattenData(t *testing.T) {
	cases := []struct {
		name  string
		input map[string]interface{}
		info  []*FlattenInfo
		want  map[string]interface{}
	}{
		{
			name: "none",
			input: map[string]interface{}{
				"a": 1,
			},
		},
		{
			name: "map",
			input: map[string]interface{}{
				"a": map[string]interface{}{
					"b": 1,
				},
			},
			info: []*FlattenInfo{{
				Key: "a",
			}},
			want: map[string]interface{}{
				"b": 1,
			},
		},
		{
			name: "slice",
			input: map[string]interface{}{
				"a": []interface{}{
					map[string]interface{}{"b": 1},
				},
			},
			info: []*FlattenInfo{{Key: "a", Index: intPointer(0)}},
			want: map[string]interface{}{
				"b": 1,
			},
		},
		{
			name: "inner",
			input: map[string]interface{}{
				"a": []interface{}{
					map[string]interface{}{
						"b": map[string]interface{}{
							"c": 1,
						}},
				},
			},
			info: []*FlattenInfo{{Key: "a", Index: intPointer(0)}, {Key: "b"}},
			want: map[string]interface{}{
				"b": map[string]interface{}{"c": int(1)},
				"c": 1,
			},
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := FlattenData(tc.input, tc.info)
			if err != nil {
				t.Errorf("FlattenData: %v", err)
			}
			if diff := cmp.Diff(tc.want, got, cmpopts.EquateEmpty()); diff != "" {
				t.Errorf("flattened data differs (-want +got):\n%v", diff)
			}
		})
	}
}

func TestWriteBuffer(t *testing.T) {
	tests := []struct {
		tmpl      string
		fieldsMap map[string]interface{}
		want      string
	}{
		// Empty.
		{"", nil, ""},

		// Template doesn't use fields.
		{"mytext", map[string]interface{}{"field1": "val1"}, "mytext"},

		// Simple string fields.
		{"field value is: {{.field1}}", map[string]interface{}{"field1": "val1"}, "field value is: val1"},

		// Nested fields.
		{
			"nested value is: {{(index .field1 1).inner.leaf}}",
			map[string]interface{}{
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
		if diff := cmp.Diff(tc.want, got); diff != "" {
			t.Errorf("fillTemplate buffer differs (-want +got):\n%v", diff)
		}
	}
}

func TestWriteBufferErr(t *testing.T) {
	tests := []struct {
		tmpl string
	}{
		// Invalid character, should fail to parse.
		{"{{.field[0]}}"},

		// Missing key, should fail to execute.
		{"{{.field}}"},
	}
	for _, tc := range tests {
		_, err := WriteBuffer(tc.tmpl, nil)
		if err == nil {
			t.Fatalf("fillTemplate(%v, %v) succeeded for malformed input, want error", tc.tmpl, nil)
		}
	}
}

func intPointer(i int) *int {
	return &i
}

func TestMakeSlice(t *testing.T) {
	tests := []struct {
		inputs, want []interface{}
	}{
		{
			inputs: []interface{}{"a", "b", "c"},
			want:   []interface{}{"a", "b", "c"},
		},
		{
			inputs: []interface{}{1, 2, 3},
			want:   []interface{}{1, 2, 3},
		},
	}
	for _, tc := range tests {
		got := makeSlice(tc.inputs...)
		if diff := cmp.Diff(tc.want, got); diff != "" {
			t.Errorf("makeSlice result differs (-want +got):\n%v", diff)
		}
	}
}
