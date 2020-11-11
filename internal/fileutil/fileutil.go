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

// Package fileutil provides utility functions around files.
package fileutil

import (
	"crypto/sha256"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/hashicorp/go-getter"
	"github.com/mitchellh/go-homedir"
)

// Expand expands the path.
func Expand(path string) (string, error) {
	path, err := homedir.Expand(path)
	if err != nil {
		return "", err
	}
	return os.ExpandEnv(path), nil
}

// Fetch handles fetching remote paths.
// If the path is local then it will simply expand it and return.
// Remote paths are fetched to the cache dir.
// Relative paths are handled from pwd.
// TODO(umairidris): support absolute paths.
func Fetch(path, pwd, cacheDir string) (string, error) {
	if strings.HasPrefix(path, ".") { // Is local path.
		path, err := Expand(path)
		if err != nil {
			return "", err
		}
		if !filepath.IsAbs(path) {
			path = filepath.Join(pwd, path)
		}
		return path, nil

	}

	root, subdir := getter.SourceDirSubdir(path)
	hash := sha256.Sum256([]byte(root))
	dst := filepath.Join(cacheDir, fmt.Sprintf("%x", hash))
	c := getter.Client{
		Dst:  dst,
		Src:  root,
		Pwd:  pwd,
		Mode: getter.ClientModeDir,
	}
	if err := c.Get(); err != nil {
		return "", err
	}
	return filepath.Join(dst, subdir), nil
}
