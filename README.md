# Sentinel GitHub Actions

Sentinel GitHub Actions allow you to execute Sentinel commands within GitHub Actions.

The output of the actions can be viewed from the Actions tab in the main repository view. If the actions are executed on a pull request event, a comment may be posted on the pull request.

Sentinel GitHub Actions are a single GitHub Action that executes different Sentinel subcommands depending on the content of the GitHub Actions YAML file.

# Success Criteria

An exit code of `0` is considered a successful execution.

## Usage

The most common workflow is to run `sentinel fmt`, `sentinel test` on all of the Sentinel files in the root of the repository when a pull request is opened or updated. A comment will be posted to the pull request depending on the output of the Sentinel subcommand being executed. This workflow can be configured by adding the following content to the GitHub Actions workflow YAML file.

```yaml
name: 'Sentinel GitHub Actions'
on:
  - pull_request
jobs:
  sentinel:
    name: 'Sentinel'
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Sentinel Format'
        uses: hashicorp/sentinel-github-actions@master
        with:
          stl_actions_version: 0.14.2
          stl_actions_subcommand: 'fmt'
          stl_actions_working_dir: '.'
          stl_actions_comment: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: 'Sentinel Test'
        uses: hashicorp/sentinel-github-actions@master
        with:
          stl_actions_version: 0.14.2
          stl_actions_subcommand: 'test'
          stl_actions_working_dir: '.'
          stl_actions_comment: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This was a simplified example showing the basic features of these Sentinel GitHub Actions.

## Inputs

Inputs configure Sentinel GitHub Actions to perform different actions.

* `stl_actions_subcommand` - (Required) The Sentinel subcommand to execute. Valid values are `fmt` and `test`.
* `stl_actions_version` - (Required) The Sentinel version to install and execute. If set to `latest`, the latest stable version will be used.
* `stl_actions_comment` - (Optional) Whether or not to comment on GitHub pull requests. Defaults to `true`.
* `stl_actions_working_dir` - (Optional) The working directory to change into before executing Sentinel subcommands. Defaults to `.` which means use the root of the GitHub repository.

## Outputs

Outputs are used to pass information to subsequent GitHub Actions steps.

* `stl_actions_output` - The Sentinel outputs.

## Secrets

Secrets are similar to inputs except that they are encrypted and only used by GitHub Actions. It's a convenient way to keep sensitive data out of the GitHub Actions workflow YAML file.

* `GITHUB_TOKEN` - (Optional) The GitHub API token used to post comments to pull requests. Not required if the `stl_actions_comment` input is set to `false`.

**WARNING:** These secrets could be exposed if the action is executed on a malicious Sentinel file. To avoid this, it is recommended not to use these Sentinel GitHub Actions on repositories where untrusted users can submit pull requests.
