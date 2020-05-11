// Copyright 2019 Google LLC
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

// Package runner provides utilities to execute commands.
package runner

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

// Runner is the interface to execute commands.
type Runner interface {
	CmdRun(cmd *exec.Cmd) error
	CmdOutput(cmd *exec.Cmd) ([]byte, error)
	CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error)
}

// Default is the Runner that executes the command by default.
type Default struct{}

// CmdRun executes the command.
func (*Default) CmdRun(cmd *exec.Cmd) error {
	log.Printf("Running: %v", cmd.Args)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%v: %s", err, stderr.String())
	}
	return nil
}

// CmdOutput executes the command and returns the command stdout.
func (*Default) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	log.Printf("Running: %v", cmd.Args)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	b, err := cmd.Output()
	if err != nil {
		return b, fmt.Errorf("%v: %s", err, stderr.String())
	}
	return b, nil
}

// CmdCombinedOutput executes the command and returns the command stdout and stderr.
func (*Default) CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error) {
	log.Printf("Running: %v", cmd.Args)
	return cmd.CombinedOutput()
}

// Dry is the Runner that only prints commands and does not execute them.
type Dry struct{}

func (*Dry) CmdRun(cmd *exec.Cmd) error {
	log.Printf("%v", cmd.String())
	return nil
}

func (d *Dry) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	return []byte(cmd.String()), d.CmdRun(cmd)
}

func (d *Dry) CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error) {
	return []byte(cmd.String()), d.CmdRun(cmd)
}

// Private helper functions.
func contains(s string, subs ...string) bool {
	for _, sub := range subs {
		if !strings.Contains(s, sub) {
			return false
		}
	}
	return true
}
