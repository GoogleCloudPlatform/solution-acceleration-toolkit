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

package importer

import (
	"context"
	"fmt"
	"io"
	"os"

	container "cloud.google.com/go/container/apiv1"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	gax "github.com/googleapis/gax-go/v2"
	"google.golang.org/api/option"
	containerpb "google.golang.org/genproto/googleapis/container/v1"
)

// Define the client as an interface to allow overriding it in tests.
type GKENodePoolClient interface {
	ListNodePools(ctx context.Context, req *containerpb.ListNodePoolsRequest, opts ...gax.CallOption) (*containerpb.ListNodePoolsResponse, error)
}

// GKENodePool defines a struct with the necessary information for a google_container_node_pool to be imported.
type GKENodePool struct {
	client GKENodePoolClient
}

func (b *GKENodePool) initClient(ctx context.Context) error {
	if b.client != nil {
		// Already initialized.
		return nil
	}

	client, err := container.NewClusterManagerClient(ctx, option.WithScopes("ScopeReadOnly"))
	if err != nil {
		return fmt.Errorf("Failed to initialize client: %q", err)
	}
	b.client = client

	return nil
}

func (b *GKENodePool) fetchNodePools(ctx context.Context, project string, location string, cluster string) ([]*containerpb.NodePool, error) {
	// Initialize client so we can make an API call to fetch possible node pools.
	if err := b.initClient(ctx); err != nil {
		return nil, err
	}

	// Prepare the request.
	req := &containerpb.ListNodePoolsRequest{
		Parent: fmt.Sprintf("projects/%v/locations/%v/clusters/%v", project, location, cluster),
	}

	resp, err := b.client.ListNodePools(ctx, req)
	if err != nil {
		return nil, err
	}

	// Return the node pools from the response.
	return resp.NodePools, nil
}

func (b *GKENodePool) fetchNodePoolName(in io.Reader, project string, location string, cluster string) (string, error) {
	clusterName := fmt.Sprintf("%v/%v/%v", project, location, cluster)

	// Fetch the node pools for this cluster and ask the user.
	ctx := context.Background()
	nodePools, err := b.fetchNodePools(ctx, project, location, cluster)
	if err != nil {
		return "", err
	}

	// Can't proceed if no node pools to choose from.
	if len(nodePools) <= 0 {
		return "", fmt.Errorf("No node pools to import in cluster %v", clusterName)
	}

	// Get just the node pool names.
	var nodePoolNames []string
	for _, np := range nodePools {
		nodePoolNames = append(nodePoolNames, np.Name)
	}

	// Ask the user to choose.
	prompt := "Please identify the node pool"
	choice, err := fromUser(in, "name", prompt, nodePoolNames)
	if err != nil {
		return "", err
	}

	return choice, nil
}

// ImportID returns the ID of the resource to use in importing.
func (b *GKENodePool) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	project, err := fromConfigValues("project", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	location, err := fromConfigValues("location", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	cluster, err := fromConfigValues("cluster", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	name, err := fromConfigValues("name", rc.Change.After, pcv)
	if err != nil {
		name = ""

		// Could not find the name in the config. If interactive, ask the user for it.
		if interactive {
			name, err = b.fetchNodePoolName(os.Stdin, project.(string), location.(string), cluster.(string))
			if err != nil {
				return "", err
			}
		}
		if name == "" {
			return "", &InsufficientInfoErr{[]string{"name"}, ""}
		}
	}

	return fmt.Sprintf("%v/%v/%v/%v", project, location, cluster, name), nil
}
