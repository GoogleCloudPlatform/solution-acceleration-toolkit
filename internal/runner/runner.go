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

// Package runner provides utilities to execute commands.
package runner

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
)

// Runner is the interface to execute commands.
type Runner interface {
	CmdRun(cmd *exec.Cmd) error
	CmdOutput(cmd *exec.Cmd) ([]byte, error)
	CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error)
}

// Default is the Runner that executes the command by default.
type Default struct {
	Quiet bool
}

// CmdRun executes the command.
func (d *Default) CmdRun(cmd *exec.Cmd) error {
	if !d.Quiet {
		log.Printf("Running: %v", cmd.Args)
	}
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
func (d *Default) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	if !d.Quiet {
		log.Printf("Running: %v", cmd.Args)
	}
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	b, err := cmd.Output()
	if err != nil {
		return b, fmt.Errorf("%v: %s", err, stderr.String())
	}
	return b, nil
}

// CmdCombinedOutput executes the command and returns the command stdout and stderr.
func (d *Default) CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error) {
	if !d.Quiet {
		log.Printf("Running: %v", cmd.Args)
	}
	return cmd.CombinedOutput()
}

// Multi will both print the output for the user and return it to callers.
// Useful for debugging, e.g. if the importer calls terraform import but it freezes without returning output.
// Inspired by https://blog.kowalczyk.info/article/wOYk/advanced-command-execution-in-go-with-osexec.html
type Multi struct {
	Quiet bool
}

// CmdRun executes the command aand prints stdout and stderr without returning either.
func (d *Multi) CmdRun(cmd *exec.Cmd) error {
	if !d.Quiet {
		log.Printf("Running: %v", cmd.Args)
	}

	var stderr bytes.Buffer
	cmd.Stdout = os.Stdout
	cmd.Stderr = io.MultiWriter(os.Stderr, &stderr)

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%v: %s", err, stderr.String())
	}
	return nil
}

// CmdOutput executes the command and prints stdout and stderr then returns just stdout.
func (d *Multi) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	if !d.Quiet {
		log.Printf("Running: %v", cmd.Args)
	}

	var stdout, stderr bytes.Buffer
	cmd.Stdout = io.MultiWriter(os.Stdout, &stdout)
	cmd.Stderr = io.MultiWriter(os.Stderr, &stderr)

	err := cmd.Run()
	if err != nil {
		err = fmt.Errorf("%v: %s", err, stderr.String())
	}
	return stdout.Bytes(), err
}

// CmdCombinedOutput executes the command and prints stdout and stderr then returns them.
func (d *Multi) CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error) {
	if !d.Quiet {
		log.Printf("Running: %v", cmd.Args)
	}
	var combined bytes.Buffer
	cmd.Stdout = io.MultiWriter(os.Stdout, &combined)
	cmd.Stderr = io.MultiWriter(os.Stderr, &combined)

	err := cmd.Run()
	return combined.Bytes(), err
}

// Dry is the Runner that only prints commands and does not execute them.
type Dry struct{}

// CmdRun prints the command.
func (*Dry) CmdRun(cmd *exec.Cmd) error {
	log.Printf("%v", cmd.String())
	return nil
}

// CmdOutput prints the command.
func (d *Dry) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	return []byte(cmd.String()), d.CmdRun(cmd)
}

// CmdCombinedOutput prints the command.
func (d *Dry) CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error) {
	return []byte(cmd.String()), d.CmdRun(cmd)
}
