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

package hcl

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
	"github.com/hashicorp/hcl/v2/hclwrite"
)

// Based on https://github.com/apparentlymart/terraform-clean-syntax.
// It is not importable due to being a binary and is not actively maintained:
// https://github.com/apparentlymart/terraform-clean-syntax/issues/12.
func removeDeprecatedBracesFromDir(path string) error {
	fn := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if filepath.Ext(info.Name()) == ".tf" {
			if err := removeDeprecatedBracesFromFile(path, info.Mode()); err != nil {
				return err
			}
		}
		return nil
	}
	return filepath.Walk(path, fn)
}

func removeDeprecatedBracesFromFile(path string, mode os.FileMode) error {
	src, err := ioutil.ReadFile(path)
	if err != nil {
		return fmt.Errorf("read file %q: %v", path, err)
	}

	f, diags := hclwrite.ParseConfig(src, path, hcl.Pos{Line: 1, Column: 1})
	if diags.HasErrors() {
		return diags
	}

	if err := cleanFile(f); err != nil {
		return err
	}

	newSrc := f.Bytes()
	if bytes.Equal(newSrc, src) {
		// No changes
		return nil
	}

	if err := ioutil.WriteFile(path, newSrc, mode); err != nil {
		return fmt.Errorf("write %q: %v", path, err)
	}
	return nil
}

func cleanFile(f *hclwrite.File) error {
	return cleanBody(f.Body(), nil)
}

func cleanBody(body *hclwrite.Body, inBlocks []string) error {
	attrs := body.Attributes()
	for name, attr := range attrs {
		if len(inBlocks) == 1 && inBlocks[0] == "variable" && name == "type" {
			cleanedExprTokens := cleanTypeExpr(attr.Expr().BuildTokens(nil))
			body.SetAttributeRaw(name, cleanedExprTokens)
			continue
		}
		cleanedExprTokens := cleanValueExpr(attr.Expr().BuildTokens(nil))
		body.SetAttributeRaw(name, cleanedExprTokens)
	}

	blocks := body.Blocks()
	for _, block := range blocks {
		inBlocks := append(inBlocks, block.Type())
		if err := cleanBody(block.Body(), inBlocks); err != nil {
			return err
		}
	}
	return nil
}

func cleanValueExpr(tokens hclwrite.Tokens) hclwrite.Tokens {
	if len(tokens) < 5 {
		// Can't possibly be a "${ ... }" sequence without at least enough
		// tokens for the delimiters and one token inside them.
		return tokens
	}
	oQuote := tokens[0]
	oBrace := tokens[1]
	cBrace := tokens[len(tokens)-2]
	cQuote := tokens[len(tokens)-1]
	if oQuote.Type != hclsyntax.TokenOQuote || oBrace.Type != hclsyntax.TokenTemplateInterp || cBrace.Type != hclsyntax.TokenTemplateSeqEnd || cQuote.Type != hclsyntax.TokenCQuote {
		// Not an interpolation sequence at all, then.
		return tokens
	}

	inside := tokens[2 : len(tokens)-2]

	// We're only interested in sequences that are provable to be single
	// interpolation sequences, which we'll determine by hunting inside
	// the interior tokens for any other interpolation sequences. This is
	// likely to produce false negatives sometimes, but that's better than
	// false positives and we're mainly interested in catching the easy cases
	// here.
	quotes := 0
	for _, token := range inside {
		if token.Type == hclsyntax.TokenOQuote {
			quotes++
			continue
		}
		if token.Type == hclsyntax.TokenCQuote {
			quotes--
			continue
		}
		if quotes > 0 {
			// Interpolation sequences inside nested quotes are okay, because
			// they are part of a nested expression.
			// "${foo("${bar}")}"
			continue
		}
		if token.Type == hclsyntax.TokenTemplateInterp || token.Type == hclsyntax.TokenTemplateSeqEnd {
			// We've found another template delimiter within our interior
			// tokens, which suggests that we've found something like this:
			// "${foo}${bar}"
			// That isn't unwrappable, so we'll leave the whole expression alone.
			return tokens
		}
	}

	// If we got down here without an early return then this looks like
	// an unwrappable sequence, but we'll trim any leading and trailing
	// newlines that might result in an invalid result if we were to
	// naively trim something like this:
	// "${
	//    foo
	// }"
	return trimNewlines(inside)
}

func cleanTypeExpr(tokens hclwrite.Tokens) hclwrite.Tokens {
	if len(tokens) != 3 {
		// We're only interested in plain quoted strings, which consist
		// of the open and close quotes and a literal string token.
		return tokens
	}
	oQuote := tokens[0]
	strTok := tokens[1]
	cQuote := tokens[2]
	if oQuote.Type != hclsyntax.TokenOQuote || strTok.Type != hclsyntax.TokenQuotedLit || cQuote.Type != hclsyntax.TokenCQuote {
		// Not a quoted string sequence, then.
		return tokens
	}

	switch string(strTok.Bytes) {
	case "string":
		return hclwrite.Tokens{
			{
				Type:  hclsyntax.TokenIdent,
				Bytes: []byte("string"),
			},
		}
	case "list":
		return hclwrite.Tokens{
			{
				Type:  hclsyntax.TokenIdent,
				Bytes: []byte("list"),
			},
			{
				Type:  hclsyntax.TokenOParen,
				Bytes: []byte("("),
			},
			{
				Type:  hclsyntax.TokenIdent,
				Bytes: []byte("string"),
			},
			{
				Type:  hclsyntax.TokenCParen,
				Bytes: []byte(")"),
			},
		}
	case "map":
		return hclwrite.Tokens{
			{
				Type:  hclsyntax.TokenIdent,
				Bytes: []byte("map"),
			},
			{
				Type:  hclsyntax.TokenOParen,
				Bytes: []byte("("),
			},
			{
				Type:  hclsyntax.TokenIdent,
				Bytes: []byte("string"),
			},
			{
				Type:  hclsyntax.TokenCParen,
				Bytes: []byte(")"),
			},
		}
	default:
		// Something else we're not expecting, then.
		return tokens
	}
}

func trimNewlines(tokens hclwrite.Tokens) hclwrite.Tokens {
	if len(tokens) == 0 {
		return nil
	}
	var start, end int
	for start = 0; start < len(tokens); start++ {
		if tokens[start].Type != hclsyntax.TokenNewline {
			break
		}
	}
	for end = len(tokens); end > 0; end-- {
		if tokens[end-1].Type != hclsyntax.TokenNewline {
			break
		}
	}
	return tokens[start:end]
}
