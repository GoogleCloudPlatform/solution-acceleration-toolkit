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
	"strings"
)

// ProviderConfigMap is a type alias to make variables more readable.
type ProviderConfigMap map[string]interface{}

// InsufficientInfoErr indicates that we do not have enough information to import a resource.
type InsufficientInfoErr struct {
	missingFields []string
	msg           string
}

func (e *InsufficientInfoErr) Error() string {
	err := fmt.Sprintf("missing fields: %v", strings.Join(e.missingFields, ", "))
	if e.msg != "" {
		err = fmt.Sprintf("%v; additional info: %v", err, e.msg)
	}
	return err
}

// fromConfigValues returns the first matching config value for key, from the given config value maps cvs.
func fromConfigValues(key string, cvs ...ProviderConfigMap) (interface{}, error) {
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
		ie := &InsufficientInfoErr{missingFields: []string{fieldName}}
		if err != nil {
			ie.msg = err.Error()
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
