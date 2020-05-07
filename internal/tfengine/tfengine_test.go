package tfengine

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

const basePath = "../../examples/tfengine"

// TestExamples is a basic test for the engine to ensure it runs without error on the examples.
func TestExamples(t *testing.T) {
	for _, c := range []string{"simple", "full"} {
		t.Run(c, func(t *testing.T) {
			tmp, err := ioutil.TempDir("", "")
			if err != nil {
				t.Fatalf("ioutil.TempDir: %v", err)
			}
			defer os.RemoveAll(tmp)

			p := filepath.Join(basePath, c+".yaml")
			if err := Run(p, tmp); err != nil {
				t.Fatalf("tfengine.Run(%q, %q) = %v", p, tmp, err)
			}
		})
	}
}
