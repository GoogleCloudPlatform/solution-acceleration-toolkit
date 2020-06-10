# Policy Generator Integration Tests

This directory contains the integration test scripts and data of the Policy
Generator. We use
[CFT Scorecard](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/master/cli/docs/scorecard.md)
to test our auto-generated Policy Library constraints with fake Cloud Asset
Inventory (CAI) export data and assert the generated violations to a known list.

The [assets/](./assets) directory contains fake CAI export data in their
original format. CFT Scorecard looks for all four different types of inventory,
and the correponding data file must exist, even if it is empty. The file names
are default output names from a CAI export (`gcloud asset export`) and are
hardcoded in the CFT Scorecard.

* access_policy_inventory.json
* iam_inventory.json
* org_policy_inventory.json
* resource_inventory.json

The data in each file is not a JSON array but rather a dump of assets
(one-per-line) encoded as JSON. CFT Scorecard parses the data line by line, and
the data must be in its original format (e.g. cannot be reformatted to a valid
JSON array) for the CFT Scorecard to consume.
