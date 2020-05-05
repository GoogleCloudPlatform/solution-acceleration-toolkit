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
	"testing"
)

func TestFromConfigValues(t *testing.T) {
	configs := []ProviderConfigMap{
		{
			"":       "emptyValFirst",
			"mykey1": "key1First",
			"mykey2": "key2First",
		},
		nil, // nil map to ensure it doesn't crash the check.
		{},  // Empty map just to make sure it gets skipped correctly.
		{
			"mykey1": "key1Second",
			"mykey3": "key3Second",
		},
	}

	tests := []struct {
		key     string
		cvs     []ProviderConfigMap
		want    interface{}
		wantErr bool
	}{
		// Empty configs - should return nil and err.
		{"", nil, nil, true},

		// Empty key - should still work.
		{"", configs, "emptyValFirst", false},

		// Key not in any config - should return nil and err.
		{"nonExistentKey", configs, nil, true},

		// Key in second config - should return second one, not nil.
		{"mykey3", configs, "key3Second", false},

		// Key in both configs - should return first one.
		{"mykey1", configs, "key1First", false},
	}
	for _, tc := range tests {
		got, err := fromConfigValues(tc.key, tc.cvs...)

		if (err != nil) != tc.wantErr {
			t.Errorf("fromConfigValues(%v, %v) = error: %v; want error %t", tc.key, tc.cvs, err, tc.wantErr)
		}

		if got != tc.want {
			t.Errorf("fromConfigValues(%v, %v) = %v; want %v", tc.key, tc.cvs, got, tc.want)
		}
	}
}
