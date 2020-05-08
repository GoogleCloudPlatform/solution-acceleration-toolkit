package tfengine

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/ghodss/yaml"
	"github.com/otiai10/copy"
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

	outputRefs := map[string]string{
		"": tmpDir,
	}
	if err := dump(c, filepath.Dir(confPath), outputRefs, ""); err != nil {
		return err
	}

	if err := os.MkdirAll(outPath, 0755); err != nil {
		return fmt.Errorf("failed to mkdir %q: %v", outPath, err)
	}

	return copy.Copy(tmpDir, outPath)
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
			rp, err := pathutil.Expand(ti.RecipePath)
			if err != nil {
				return err
			}
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
			cp, err := pathutil.Expand(ti.ComponentPath)
			if err != nil {
				return err
			}
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
