# Sentinel GitHub Actions

These Sentinel GitHub Actions allow you to run `sentinel test` and `fmt` on your pull requests to help you review and validate Sentinel policy changes.

The recommended workflow for using these actions is in the [Terraform Enterprise Sentinel VCS docs](https://www.terraform.io/docs/enterprise/sentinel/integrate-vcs.html). [tfe-policies-example](https://github.com/hashicorp/tfe-policies-example) includes an example of using these actions in practice.

## Example

```hcl
workflow "Sentinel" {
  resolves = ["sentinel-test", "sentinel-fmt"]
  on = "pull_request"
}

action "sentinel-test" {
  uses = "hashicorp/sentinel-github-actions/test@master"
  secrets = ["GITHUB_TOKEN"]
  env = {
    STL_ACTION_WORKING_DIR = "."
  }
}


action "sentinel-fmt" {
  uses = "hashicorp/sentinel-github-actions/fmt@v0.1"
  secrets = ["GITHUB_TOKEN"]
  env = {
    TF_ACTION_WORKING_DIR = "."
  }
}
```