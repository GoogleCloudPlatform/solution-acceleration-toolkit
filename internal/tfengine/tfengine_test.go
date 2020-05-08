package tfengine

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

// TestExamples is a basic test for the engine to ensure it runs without error on the examples.
func TestExamples(t *testing.T) {
	exs, err := filepath.Glob("../../examples/tfengine/*.yaml")
	if err != nil {
		t.Fatalf("filepath.Glob = %v", err)
	}

	if len(exs) == 0 {
		t.Error("found no examples")
	}

	for _, ex := range exs {
		t.Run(filepath.Base(ex), func(t *testing.T) {
			tmp, err := ioutil.TempDir("", "")
			if err != nil {
				t.Fatalf("ioutil.TempDir = %v", err)
			}
			defer os.RemoveAll(tmp)

			if err := Run(ex, tmp); err != nil {
				t.Fatalf("tfengine.Run(%q, %q) = %v", ex, tmp, err)
			}

			// Check for the existence of the bootstrap folder.
			if _, err := os.Stat(filepath.Join(tmp, "bootstrap")); err != nil {
				t.Fatalf("os.Stat bootstrap dir = %v", err)
			}
		})
	}
}
