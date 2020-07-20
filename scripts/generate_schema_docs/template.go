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

package main

import (
	"strings"
	"text/template"
)

var tmpl = template.Must(template.New("").Funcs(template.FuncMap{"lstrip": lstrip}).Parse(`
# {{.Title}}

## Properties
{{range $name, $prop := .Properties}}
## {{$name}}

{{lstrip $prop.Description}}

{{end}}
`))

func lstrip(s string) string {
	var b strings.Builder
	for _, line := range strings.Split(s, "\n") {
		b.WriteString(strings.TrimLeft(line, " "))
		b.WriteRune('\n')
	}
	return b.String()
}
