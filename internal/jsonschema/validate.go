// Package jsonschema defines helpers for JSON schema validation.
package jsonschema

import (
	"errors"
	"fmt"
	"strings"

	"github.com/xeipuuv/gojsonschema"
)

func Validate(schemaJSON []byte, confJSON []byte) error {
	result, err := gojsonschema.Validate(gojsonschema.NewBytesLoader(schemaJSON), gojsonschema.NewBytesLoader(confJSON))
	if err != nil {
		return fmt.Errorf("validate config: %v", err)
	}

	if len(result.Errors()) == 0 {
		return nil
	}

	var sb strings.Builder
	sb.WriteString("config has validation errors:")
	for _, err := range result.Errors() {
		sb.WriteString(fmt.Sprintf("\n- %s: %s", err.Context().String(), err.Description()))
	}
	return errors.New(sb.String())
}
