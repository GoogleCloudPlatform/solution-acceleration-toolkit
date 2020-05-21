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

// Package tfengine implements the Terraform Engine.
package tfengine

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/otiai10/copy"
	"github.com/zclconf/go-cty/cty"
)

// Config is the user supplied config for the engine.
type Config struct {
	DataCty   *cty.Value             `hcl:"data,optional" json:"-"`
	Data      map[string]interface{} `json:"data,omitempty"`
	Templates []*templateInfo        `hcl:"templates,block" json:"templates,omitempty"`
}

type templateInfo struct {
	ComponentPath string                  `hcl:"component_path,optional" json:"component_path,omitempty"`
	RecipePath    string                  `hcl:"recipe_path,optional" json:"recipe_path,omitempty"`
	OutputPath    string                  `hcl:"output_path,optional" json:"output_path,omitempty"`
	Flatten       []*template.FlattenInfo `hcl:"flatten,block" json:"flatten,omitempty"`
	DataCty       *cty.Value              `hcl:"data,optional" json:"-"`
	Data          map[string]interface{}  `json:"data,omitempty"`
}

func (c *Config) Init() error {
	var err error
	if c.DataCty != nil {
		c.Data, err = ctyValueToMap(c.DataCty)
		if err != nil {
			return err
		}
	}

	for _, t := range c.Templates {
		if t.DataCty == nil {
			continue
		}
		t.Data, err = ctyValueToMap(t.DataCty)
		if err != nil {
			return err
		}
	}
	return nil
}

func Run(confPath, outPath string) error {
	var err error
	confPath, err = pathutil.Expand(confPath)
	if err != nil {
		return err
	}
	outPath, err = pathutil.Expand(outPath)
	if err != nil {
		return err
	}

	c, err := loadConfig(confPath, nil)
	if err != nil {
		return err
	}
	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	if err := dump(c, filepath.Dir(confPath), tmpDir); err != nil {
		return err
	}

	if err := os.MkdirAll(outPath, 0755); err != nil {
		return fmt.Errorf("failed to mkdir %q: %v", outPath, err)
	}

	return copy.Copy(tmpDir, outPath)
}

func dump(conf *Config, root, outputPath string) error {
	for _, ti := range conf.Templates {
		outputPath := filepath.Join(outputPath, ti.OutputPath)

		if ti.Data == nil {
			ti.Data = make(map[string]interface{})
		}
		if err := template.MergeData(ti.Data, conf.Data, ti.Flatten); err != nil {
			return err
		}

		switch {
		case ti.RecipePath != "":
			rp, err := pathutil.Expand(ti.RecipePath)
			if err != nil {
				return err
			}
			if !filepath.IsAbs(rp) {
				rp = filepath.Join(root, rp)
			}
			rc, err := loadConfig(rp, ti.Data)
			if err != nil {
				return fmt.Errorf("load recipe %q: %v", rp, err)
			}
			rc.Data = ti.Data
			if err := dump(rc, filepath.Dir(rp), outputPath); err != nil {
				return fmt.Errorf("recipe %q: %v", rp, err)
			}
		case ti.ComponentPath != "":
			cp, err := pathutil.Expand(ti.ComponentPath)
			if err != nil {
				return err
			}
			if !filepath.IsAbs(cp) {
				cp = filepath.Join(root, cp)
			}
			if err := template.WriteDir(cp, outputPath, ti.Data); err != nil {
				return fmt.Errorf("component %q: %v", cp, err)
			}
		}
	}
	return nil
}
