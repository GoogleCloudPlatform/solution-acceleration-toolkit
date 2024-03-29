// Copyright 2021 Google LLC
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
	"text/template"
)

// tmpl is a Template to convert one schema file to markdown.
var tmpl = template.Must(template.New("").Parse(`# {{.Title}}

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
{{- range $name, $_ := .Properties}}
| {{$name}} | {{or .Description "-"}} | {{or .Type "-"}} | {{.RequiredByParent}} | {{or .Default "-"}} | {{or .Pattern "-"}} |
{{- end}}
`))
