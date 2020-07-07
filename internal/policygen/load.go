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

package policygen

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

	"cloud.google.com/go/storage"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/jsonschema"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/ghodss/yaml"
	"github.com/hashicorp/hcl/v2/hclsimple"
	"github.com/hashicorp/terraform/states"
	"github.com/zclconf/go-cty/cty"
	"google.golang.org/api/iterator"
	"google.golang.org/api/option"
)

// config is the struct representing the Policy Generator configuration.
type config struct {
	TemplateDir string `hcl:"template_dir" json:"template_dir"`

	// HCL decoder can't unmarshal into map[string]interface{},
	// so make it unmarshal to a cty.Value and manually convert to map.
	// TODO(https://github.com/hashicorp/hcl/issues/291): Remove the need for DataCty.
	ForsetiPoliciesCty *cty.Value             `hcl:"forseti_policies,optional" json:"-"`
	ForsetiPolicies    map[string]interface{} `json:"forseti_policies"`

	GCPOrgPoliciesCty *cty.Value             `hcl:"gcp_org_policies,optional" json:"-"`
	GCPOrgPolicies    map[string]interface{} `json:"gcp_org_policies"`
}

func ValidateOrgPoliciesConfig(conf map[string]interface{}) error {
	sj, err := hcl.ToJSON(orgPoliciesSchema)
	if err != nil {
		return err
	}
	cj, err := json.Marshal(conf)
	if err != nil {
		return err
	}

	return jsonschema.ValidateJSONBytes(sj, cj)
}

func loadConfig(path string) (*config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config %q: %v", path, err)
	}

	// Save unmodified path to use in init().
	originalPath := path

	// Convert yaml to json so hcl decoder can parse it.
	cj := b
	if filepath.Ext(path) == ".yaml" {
		cj, err = yaml.YAMLToJSON(cj)
		if err != nil {
			return nil, err
		}
		// hclsimple.Decode doesn't actually use the path for anything other
		// than its extension, so just pass in any file name ending with json so
		// the library knows to treat these bytes as json and not yaml.
		path = "file.json"
	}

	c := new(config)
	if err := hclsimple.Decode(path, cj, nil, c); err != nil {
		return nil, err
	}

	if err := c.init(originalPath); err != nil {
		return nil, err
	}

	return c, nil
}

func (c *config) init(path string) error {
	var err error
	if c.ForsetiPoliciesCty != nil {
		c.ForsetiPolicies, err = hcl.CtyValueToMap(c.ForsetiPoliciesCty)
		if err != nil {
			return fmt.Errorf("failed to convert %v to map: %v", c.ForsetiPoliciesCty, err)
		}
	}

	if c.GCPOrgPoliciesCty != nil {
		c.GCPOrgPolicies, err = hcl.CtyValueToMap(c.GCPOrgPoliciesCty)
		if err != nil {
			return fmt.Errorf("failed to convert %v to map: %v", c.GCPOrgPoliciesCty, err)
		}
	}

	sj, err := hcl.ToJSON(schema)
	if err != nil {
		return fmt.Errorf("convert schema to JSON: %v", err)
	}

	cj, err := json.Marshal(c)
	if err != nil {
		return err
	}

	if err := jsonschema.ValidateJSONBytes(sj, cj); err != nil {
		return err
	}

	if c.GCPOrgPolicies != nil {
		if err := ValidateOrgPoliciesConfig(c.GCPOrgPolicies); err != nil {
			return err
		}
	}

	if !filepath.IsAbs(c.TemplateDir) {
		c.TemplateDir = filepath.Join(filepath.Dir(path), c.TemplateDir)
	}

	return nil
}

// loadResources loads Terraform state resources from the given path.
// - If the path is a single local file, it loads resouces from it.
// - If the path is a local directory, it walks the directory recursively and loads resources from each .tfstate file.
// - If the path is a Cloud Storage bucket (indicated by 'gs://' prefix), it walks the bucket recursively and loads resources from each .tfstate file.
//   It only reads the bucket name from the path and ignores the file/dir, if specified. All .tfstate file from the bucket will be read.
func loadResources(ctx context.Context, path string) ([]*states.Resource, error) {
	if strings.HasPrefix(path, "gs://") {
		return loadResourcesFromCloudStorageBucket(ctx, path)
	}

	fi, err := os.Stat(path)
	if os.IsNotExist(err) {
		return nil, err
	}

	// If the input is a file, also process it even if the extension is not .tfstate.
	if !fi.IsDir() {
		return loadResourcesFromSingleLocalFile(path)
	}

	return loadResourcesFromLocalDir(path)
}

func loadResourcesFromLocalDir(path string) ([]*states.Resource, error) {
	var allResources []*states.Resource
	fn := func(path string, _ os.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("walk path %q: %v", path, err)
		}

		if filepath.Ext(path) != terraform.StateFileExtension {
			return nil
		}

		resources, err := loadResourcesFromSingleLocalFile(path)
		if err != nil {
			return err
		}
		allResources = append(allResources, resources...)

		return nil
	}

	if err := filepath.Walk(path, fn); err != nil {
		return nil, err
	}

	return allResources, nil
}

func loadResourcesFromSingleLocalFile(path string) ([]*states.Resource, error) {
	resources, err := terraform.ResourcesFromStateFile(path)
	if err != nil {
		return nil, fmt.Errorf("read resources from Terraform state file %q: %v", path, err)
	}
	return resources, nil
}

func loadResourcesFromCloudStorageBucket(ctx context.Context, path string) ([]*states.Resource, error) {
	// Trim the 'gs://' prefix and split the path into the bucket name and cloud storage file path.
	bucketName := strings.SplitN(strings.TrimPrefix(path, "gs://"), "/", 2)[0]
	log.Printf("Reading state files from Cloud Storage bucket %q", bucketName)

	client, err := storage.NewClient(ctx, option.WithScopes(storage.ScopeReadOnly))
	if err != nil {
		return nil, fmt.Errorf("start cloud storage client: %v", err)
	}

	bucket := client.Bucket(bucketName)
	// Stat the bucket, check existence and caller permission.
	if _, err := bucket.Attrs(ctx); err != nil {
		return nil, fmt.Errorf("read bucket: %v", err)
	}

	var names []string
	it := bucket.Objects(ctx, &storage.Query{})
	for {
		attrs, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}
		name := attrs.Name
		if filepath.Ext(name) != terraform.StateFileExtension {
			continue
		}
		names = append(names, name)
	}

	var allResources []*states.Resource
	for _, name := range names {
		log.Printf("reading remote file: gs://%s/%s", bucketName, name)
		obj := bucket.Object(name)
		r, err := obj.NewReader(ctx)
		if err != nil {
			return nil, err
		}
		defer r.Close()
		resources, err := terraform.ResourcesFromState(r)
		if err != nil {
			return nil, err
		}
		allResources = append(allResources, resources...)
	}

	return allResources, nil
}
