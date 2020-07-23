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

// Package importer defines resource-specific implementations for interface Importer.
package importer

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

// ConfigMap is a type alias for a map of resource config values.
// It's supposed to hold values for keys used in determining a resource's ImportID.
// May come from the provider block, the planned change values, manually provided defaults, or elsewhere.
type ConfigMap map[string]interface{}

// InsufficientInfoErr indicates that we do not have enough information to import a resource.
type InsufficientInfoErr struct {
	MissingFields []string
	Msg           string
}

func (e *InsufficientInfoErr) Error() string {
	err := fmt.Sprintf("missing fields: %v", strings.Join(e.MissingFields, ", "))
	if e.Msg != "" {
		err = fmt.Sprintf("%v; additional info: %v", err, e.Msg)
	}
	return err
}

// fromConfigValues returns the first matching config value for key, from the given config value maps cvs.
func fromConfigValues(key string, cvs ...ConfigMap) (interface{}, error) {
	for _, cv := range cvs {
		if v, ok := cv[key]; ok {
			return v, nil
		}
	}
	return nil, fmt.Errorf("could not find key %q in resource change or provider config", key)
}

// Small helper functions to DRY the fromUser* functions.
func showPrompt(fieldName, prompt string) {
	log.Printf("Could not determine %q automatically\n", fieldName)
	log.Println(prompt)
}
func parseUserVal(fieldName, val string, err error) (string, error) {
	if val == "" {
		ie := &InsufficientInfoErr{MissingFields: []string{fieldName}}
		if err != nil {
			ie.Msg = err.Error()
		}
		return "", ie
	}
	return val, err
}

// fromUser asks the user for the value.
func fromUser(in io.Reader, fieldName string, prompt string) (val string, err error) {
	showPrompt(fieldName, prompt)
	val, err = userValue(in)
	return parseUserVal(fieldName, val, err)
}

// userValue asks the user to fill in a value that the importer can't figure out.
func userValue(in io.Reader) (string, error) {
	fmt.Println("Enter a value manually (blank to skip):")
	reader := bufio.NewReader(in)
	val, err := reader.ReadString('\n')
	if err != nil {
		return "", err
	}
	val = strings.TrimSpace(val)
	return val, nil
}

// loadFields returns a map of field names to values, taking into account interactivity and multiple ConfigMaps.
// The result can be used in templates.
func loadFields(fields []string, interactive bool, configValues ...ConfigMap) (fieldsMap map[string]interface{}, err error) {
	fieldsMap = make(map[string]interface{})
	var missingFields []string
	for _, field := range fields {
		val, err := fromConfigValues(field, configValues...)
		// If interactive is set, try to get the field interactively.
		if err != nil && interactive {
			prompt := fmt.Sprintf("Please enter the exact value for %v", field)
			val, err = fromUser(os.Stdin, field, prompt)
		}

		// If err is still not nil, then user didn't provide value, treat this as a missing field.
		if err != nil {
			missingFields = append(missingFields, field)
		}

		// Leave the value as-is, to allow arbitrary nesting in the template, if it happens to not be a string.
		// For example, in the google_container_node_pool resource, `node_config` is a map but has potentially useful sub-fields.
		fieldsMap[field] = val
	}

	if len(missingFields) > 0 {
		return nil, &InsufficientInfoErr{missingFields, ""}
	}

	return fieldsMap, nil
}
