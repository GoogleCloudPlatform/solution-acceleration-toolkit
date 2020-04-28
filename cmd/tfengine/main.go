/*
 * Copyright 2020 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// tfengine provides an engine to power your Terraform environment.
//
// Usage:
// $ tfengine --config_path=path/to/config --output_dir=/tmp/engine
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"flag"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/ghodss/yaml"
)

var (
	configPath = flag.String("config_path", "", "Path to config file")
	outputPath = flag.String("output_path", "", "Path to directory dump output")
)

// Config is the user supplied config for the engine.
type Config struct {
	Data      map[string]interface{} `json:"data"`
	Templates []*templateInfo        `json:"templates"`
}

type templateInfo struct {
	Name          string                  `json:"name"`
	ComponentPath string                  `json:"component_path"`
	RecipePath    string                  `json:"recipe_path"`
	OutputRef     string                  `json:"output_ref"`
	OutputPath    string                  `json:"output_path"`
	Flatten       []*template.FlattenInfo `json:"flatten"`
	Data          map[string]interface{}  `json:"data"`
}

func main() {
	flag.Parse()

	if *configPath == "" {
		log.Fatal("--config_path must be set")
	}
	if *outputPath == "" {
		log.Fatal("--output_path must be set")
	}

	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	c, err := loadConfig(*configPath, nil)
	if err != nil {
		return err
	}
	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	outputRefs := map[string]string{
		"": tmpDir,
	}
	if err := dump(c, filepath.Dir(*configPath), outputRefs, ""); err != nil {
		return err
	}

	if err := os.MkdirAll(*outputPath, 0755); err != nil {
		return fmt.Errorf("failed to mkdir %q: %v", *outputPath, err)
	}

	fs, err := filepath.Glob(filepath.Join(tmpDir, "/*"))
	if err != nil {
		return err
	}
	cp := exec.Command("cp", append([]string{"-a", "-t", *outputPath}, fs...)...)
	cp.Stderr = os.Stderr
	return cp.Run()
}

func loadConfig(path string, data map[string]interface{}) (*Config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	buf, err := template.WriteBuffer(string(b), data)
	if err != nil {
		return nil, err
	}
	c := new(Config)
	if err := yaml.Unmarshal(buf.Bytes(), c); err != nil {
		return nil, err
	}
	return c, nil
}

func dump(conf *Config, root string, outputRefs map[string]string, parentKey string) error {
	for _, ti := range conf.Templates {
		if ti.Name == "" {
			return fmt.Errorf("template name cannot be empty: %+v", ti)
		}
		if ti.Data == nil {
			ti.Data = make(map[string]interface{})
		}
		if err := template.MergeData(ti.Data, conf.Data, ti.Flatten); err != nil {
			return err
		}

		tp := parentKey
		if ti.OutputRef != "" {
			tp = buildOutputKey(parentKey, ti.OutputRef)
		}
		parentPath, ok := outputRefs[tp]
		if !ok {
			return fmt.Errorf("output reference for %q not found: %v", tp, outputRefs)
		}

		outputPath := filepath.Join(parentPath, ti.OutputPath)
		outputKey := buildOutputKey(parentKey, ti.Name)
		outputRefs[outputKey] = outputPath

		switch {
		case ti.RecipePath != "":
			rp := ti.RecipePath
			if !filepath.IsAbs(rp) {
				rp = filepath.Join(root, rp)
			}
			rc, err := loadConfig(rp, ti.Data)
			if err != nil {
				return fmt.Errorf("load recipe %q: %v", ti.Name, err)
			}
			rc.Data = ti.Data
			if err := dump(rc, filepath.Dir(rp), outputRefs, outputKey); err != nil {
				return fmt.Errorf("recipe %q: %v", ti.Name, err)
			}
		case ti.ComponentPath != "":
			cp := ti.ComponentPath
			if !filepath.IsAbs(cp) {
				cp = filepath.Join(root, cp)
			}
			if err := template.WriteDir(cp, outputPath, ti.Data); err != nil {
				return fmt.Errorf("component %q: %v", ti.Name, err)
			}
		}
	}
	return nil
}

func buildOutputKey(parent, child string) string {
	if parent == "" {
		return child
	}
	return parent + "." + child
}
