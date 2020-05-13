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
	"io/ioutil"
	"log"
	"os"
	"strings"
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

var testProject = "my-project"
var testLocation = "us-central1-a"
var testCluster = "my-cluster"
var testNodePools = []*containerpb.NodePool{
	{Name: "nodepool1"},
	{Name: "nodepool2"},
}

func TestFetchNodePools(t *testing.T) {
	c := &GKENodePool{client: &FakeGKENodePoolClient{
		wantParent: "projects/my-project/locations/us-central1-a/clusters/my-cluster",
		nodePools:  testNodePools,
	}}

	ctx := context.Background()
	np, err := c.fetchNodePools(ctx, testProject, testLocation, testCluster)
	if err != nil {
		t.Errorf(err.Error())
	} else if diff := cmp.Diff(np, testNodePools, cmpopts.EquateEmpty()); diff != "" {
		t.Errorf("fetchNodePools(%v, %v, %v) returned diff (-got +want):\n%s", testProject, testLocation, testCluster, diff)
	}
}

func TestFetchNodePoolName(t *testing.T) {
	c := &GKENodePool{client: &FakeGKENodePoolClient{
		wantParent: "projects/my-project/locations/us-central1-a/clusters/my-cluster",
		nodePools:  testNodePools,
	}}

	// Temporarily redirect output to null while running
	stdout := os.Stdout
	os.Stdout = os.NewFile(0, os.DevNull)
	log.SetOutput(ioutil.Discard)

	np, err := c.fetchNodePoolName(strings.NewReader("-1\n2\n1\n"), testProject, testLocation, testCluster)

	// Restore.
	os.Stdout = stdout

	wantNp := "nodepool2"
	if err != nil {
		t.Errorf("fetchNodePoolName(%v, %v, %v, %v) err = %v", c, testProject, testLocation, testCluster, err)
	} else if np != wantNp {
		t.Errorf("fetchNodePoolName(%v, %v, %v, %v) = %v; want %v", c, testProject, testLocation, testCluster, np, wantNp)
	}

}
