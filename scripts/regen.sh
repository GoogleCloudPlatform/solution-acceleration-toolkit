#!/usr/bin/env bash

# Helper to regenerate generated files.
go run ./cmd/policygen --config_path examples/policygen/config.yaml --output_path examples/policygen/generated --state_path examples/policygen/example.tfstate
go run ./cmd/tfengine --config_path examples/tfengine/simple.hcl --output_path examples/tfengine/generated/simple
go run ./cmd/tfengine --config_path examples/tfengine/full.hcl --output_path examples/tfengine/generated/full
