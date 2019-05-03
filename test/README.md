# Sentinel Test Action

Runs `sentinel test` to test all Sentinel files in a directory. If any tests fail, this action will comment back on the pull request with the result of each file.

## Example

```hcl
workflow "Sentinel" {
  resolves = ["sentinel-test", "terraform-fmt"]
  on = "pull_request"
}

action "sentinel-test" {
  uses = "hashicorp/sentinel-github-actions/test@master"
  secrets = ["GITHUB_TOKEN"]
  env = {
    STL_ACTION_WORKING_DIR = "."
  }
}
```
