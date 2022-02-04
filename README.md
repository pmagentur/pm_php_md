# PM Phpmd Check - GitHub Action
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


A [GitHub Action](https://github.com/features/actions) to parse violations using [phpmd](https://phpmd.org/) checker.
## Usage

You can use this action after any other action. Here is an example setup of this action:

1. Create a `.github/workflows/phpmd_checker.yml` file in your GitHub repo.
2. Add the following code to the `phpmd_checker.yml` file.

```yml
name: PHPMD check

on:
  pull_request_target:
    types: [opened, edeted]
  pull_request:
    types: [synchronize]
  
env:
  BASELINE_BRANCH: "development"
  BASELINE_PATH: "baseline_conf"
jobs:
  phpmd:
      name: PHPMD check
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
          with:
            ref: ${{ github.event.pull_request.head.sha }}
        - uses: actions/checkout@v2
          with:
            ref: ${{ env.BASELINE_BRANCH }}
            path: ${{ env.BASELINE_PATH }}
        - name: PHPMD check
          uses: pmagentur/pm_php_md@master
          with:
            files: '.'
            renderers: 'json'
            only_changed_files: 'true'
            head_sha_annotations: ${{github.event.pull_request.head.sha}}
```


## Environment Variables

By default, action is designed to run with minimal configuration but you can use the following environment variables:

Variable       | Default                                               | Purpose
---------------|-------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------
BASELINE_BRANCH     | " " | The branch name where keeped baseline file
BASELINE_PATH    | " "  | Baseline file path basline file helps you ignore violations which you have before



You can see the action block with all variables as below:
``` yml
    - name: PHPMD check
      uses: pmagentur/pm_php_md@master
      with:
        files: '.'
        renderers: 'json'
        only_changed_files: 'true'
        head_sha_annotations: ${{github.event.pull_request.head.sha}}
```
Input      | Default            |     Required            | Purpose
---------------|--------------------------|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------
files  | " " | false |For checking exact directory or files, used with only_changed_files: "false"
renderers | "github" | false |The format of output "xml/json/github"
only_changed_files | " " | false |For checking only changed files from PR
head_sha_annotations    | " "  | true | head_sha in PR
## License

[MIT](LICENSE) © 2019 PM Agenture
