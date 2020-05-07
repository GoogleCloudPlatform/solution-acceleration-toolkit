package main

import (
	"path/filepath"
	"testing"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
)

const basePath = "../../../examples/tfengine"

func TestGenerate(t *testing.T) {
	conf := filepath.Join(basePath, "full.yaml")
	out := filepath.Join(basePath, "generated/full")
	if err := tfengine.Run(conf, out); err != nil {
		t.Fatal(err)
	}
}
