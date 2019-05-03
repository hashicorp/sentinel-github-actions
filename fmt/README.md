# Sentinel FMT Action

Runs `sentinel fmt` to format all Sentinel files in a directory to the canonical format. If any files differ, this action will comment back on the pull request with the result of each file.

## Example

```hcl
  workflow "Sentinel" {
  resolves = ["sentinel-fmt"]
  on = "pull_request"
}

action "sentinel-fmt" {
  uses = "hashicorp/sentinel-github-actions/fmt@master"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "."
  }
}
```