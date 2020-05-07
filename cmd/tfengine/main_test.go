package main

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
)

const basePath = "../../examples/tfengine"

func TestRun(t *testing.T) {
	for _, c := range []string{"simple", "full"} {
		t.Run(c, func(t *testing.T) {
			tmp, err := ioutil.TempDir("", "")
			if err != nil {
				t.Fatalf("ioutil.TempDir: %v", err)
			}
			defer os.RemoveAll(tmp)

			p := filepath.Join(basePath, c+".yaml")
			if err := tfengine.Run(p, tmp); err != nil {
				t.Fatalf("tfengine.Run(%q, %q) = %v", p, tmp, err)
			}
		})
	}
}
