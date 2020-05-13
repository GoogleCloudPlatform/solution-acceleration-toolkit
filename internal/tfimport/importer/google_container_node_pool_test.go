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

package importer

import (
	"context"
	"fmt"
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
	gax "github.com/googleapis/gax-go/v2"
	containerpb "google.golang.org/genproto/googleapis/container/v1"
)

type FakeGKENodePoolClient struct {
	wantParent string
	nodePools  []*containerpb.NodePool
}

func (c *FakeGKENodePoolClient) ListNodePools(ctx context.Context, req *containerpb.ListNodePoolsRequest, opts ...gax.CallOption) (*containerpb.ListNodePoolsResponse, error) {
	if req.Parent != c.wantParent {
		return nil, fmt.Errorf("fetchNodePools(%v) Parent = %v; want %v", req, req.Parent, c.wantParent)
	}
	return &containerpb.ListNodePoolsResponse{NodePools: c.nodePools}, nil
}

func TestFetchNodePools(t *testing.T) {
	testProject := "my-project"
	testRegion := "us-central1-a"
	testCluster := "my-cluster"
	testNodePools := []*containerpb.NodePool{
		{Name: "nodepool1"},
		{Name: "nodepool2"},
	}

	c := &GKENodePool{client: &FakeGKENodePoolClient{
		wantParent: "projects/my-project/locations/us-central1-a/clusters/my-cluster",
		nodePools:  testNodePools,
	}}

	ctx := context.Background()
	np, err := c.fetchNodePools(ctx, testProject, testRegion, testCluster)
	if err != nil {
		t.Errorf(err.Error())
	} else if diff := cmp.Diff(np, testNodePools, cmpopts.EquateEmpty()); diff != "" {
		t.Errorf("fetchNodePools(%v, %v, %v) returned diff (-got +want):\n%s", testProject, testRegion, testCluster, diff)
	}
}
