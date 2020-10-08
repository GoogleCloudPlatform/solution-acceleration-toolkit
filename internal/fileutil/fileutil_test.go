// Copyright 2020 Google LLC
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

package fileutil

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestDiffDirs(t *testing.T) {
	tests := []struct {
		name    string
		d1Paths []string
		d2Paths []string
		want    []string
	}{
		{
			name:    "d1 only, returns diff",
			d1Paths: []string{"a"},
			d2Paths: nil,
			want:    []string{"a"},
		},
		{
			name:    "d2 only, no diff",
			d1Paths: nil,
			d2Paths: []string{"a"},
			want:    nil,
		},
		{
			name:    "d1 and d1, no diff",
			d1Paths: []string{"a"},
			d2Paths: []string{"a"},
			want:    nil,
		},
		{
			name:    "d1 and d2, diff",
			d1Paths: []string{"a"},
			d2Paths: []string{"b"},
			want:    []string{"a"},
		},
		{
			name:    "dirs",
			d1Paths: []string{"a/"},
			d2Paths: nil,
			want:    []string{"a"},
		},
		{
			name:    "dir and files",
			d1Paths: []string{"dir1/", "dir1/file1.txt", "dir1/file2.txt", "dir2/"},
			d2Paths: []string{"dir1/", "dir1/file1.txt", "dir1/file3.txt", "dir3/"},
			want:    []string{"dir1/file2.txt", "dir2"},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			d1 := writeDir(t, tc.d1Paths)
			d2 := writeDir(t, tc.d2Paths)

			got, err := DiffDirs(d1, d2)
			if err != nil {
				t.Errorf("DiffDirs = %v", err)
			}
			if diff := cmp.Diff(tc.want, got); diff != "" {
				t.Errorf("dir diff differs (-want +got):\n%v", diff)
			}
		})
	}
}

func writeDir(t *testing.T, paths []string) string {
	t.Helper()
	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		t.Fatalf("ioutil.TempDir = %v", err)
	}
	t.Cleanup(func() {
		os.RemoveAll(tmp)
	})

	for _, p := range paths {
		d, f := filepath.Split(p)
		if d != "" {
			d := filepath.Join(tmp, d)
			if err := os.MkdirAll(d, 0755); err != nil {
				t.Fatalf("os.MkdirAll(%q) = %v", d, err)
			}
		}
		if f != "" {
			f := filepath.Join(tmp, p)
			if err := ioutil.WriteFile(f, nil, 0755); err != nil {
				t.Fatalf("ioutil.WriteFile(%q) = %v", f, err)
			}
		}
	}
	return tmp
}
