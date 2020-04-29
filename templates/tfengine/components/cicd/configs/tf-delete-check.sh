#!/usr/bin/env bash

# Helper script that checks for delete changes in terraform plans.
# Expects that the following command was previously run:
# $ terragrunt plan-all --terragrunt-non-interactive -out='plan.tfplan'
#
# Requirements:
#  * terraform
#  * terragrunt
#  * jq

set -e

reject_plan_deletions="${1}"

# Parse every plan
found_deletes="false"
find "$(pwd)" -name 'plan.tfplan' | while read planfile; do
  plandir="$(dirname ${planfile})"
  pushd "${plandir}"

  delchanges="$(terraform show -json $(basename ${planfile}) | jq '.resource_changes[].change | select(.actions | index("delete"))')"
  if ! [[ -z "${delchanges}" ]]; then
    echo >&2 "Error: Found changes intending to delete resources in module ${plandir}:"
    echo >&2 "${delchanges}"
    found_deletes="true"

    # Don't fail early, show all deletions found.
  fi

  popd
done

if [[ "${found_deletes}" == 'true' ]]; then
  echo >&2 'Error: Found changes intending to delete resources. See above for details.'
  echo >&2 'Destructive changes are dangerous and should be manually applied by a human operator, not by automation.'

  # Don't fail is this check is disabled.
  if [[ '${reject_plan_deletions}' == 'false' ]]; then
    echo >&2 'Flag reject_plan_deletions is set to false, not failing.'
    exit 0
  fi

  # Otherwise fail.
  exit 1
fi
