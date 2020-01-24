#!/bin/bash

function sentinelFmt {
  # Gather the output of `sentinel fmt`.
  echo "fmt: info: checking if Sentinel files in ${stlWorkingDir} are correctly formatted"
  fmtOutput=$(sentinel fmt -check=true -write=false ${*}/*.sentinel 2>&1)
  fmtExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${fmtExitCode} -eq 0 ]; then
    echo "fmt: info: Sentinel files in ${stlWorkingDir} are correctly formatted"
    echo "${fmtOutput}"
    echo
    exit ${fmtExitCode}
  fi

  # Exit code of 2 indicates a parse error. Print the output and exit.
  if [ ${fmtExitCode} -eq 2 ]; then
    echo "fmt: error: failed to parse Sentinel files"
    echo "${fmtOutput}"
    echo
    exit ${fmtExitCode}
  fi

  # Exit code of !0 and !2 indicates failure.
  echo "fmt: error: Sentinel files in ${stlWorkingDir} are incorrectly formatted"
  echo "${fmtOutput}"
  echo
  echo "fmt: error: the following files in ${stlWorkingDir} are incorrectly formatted"
  fmtFileList=$(sentinel fmt -check=true -write=false ${stlWorkingDir}/*.sentinel)
  echo "${fmtFileList}"
  echo

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${stlComment}" == "1" ]; then
    fmtComment=""
    for file in ${fmtFileList}; do
      fmtFileDiff=$(sentinel fmt -write=false "${file}" | sed -n '/@@.*/,//{/@@.*/d;p}')
      fmtComment="${fmtComment}
<details><summary><code>${stlWorkingDir}/${file}</code></summary>
\`\`\`diff
${fmtFileDiff}
\`\`\`
</details>"

    done

    fmtCommentWrapper="#### \`sentinel fmt\` Failed
${fmtComment}
*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${stlWorkingDir}\`*"

    fmtCommentWrapper=$(stripColors "${fmtCommentWrapper}")
    echo "fmt: info: creating JSON"
    fmtPayload=$(echo "${fmtCommentWrapper}" | jq -R --slurp '{body: .}')
    fmtCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "fmt: info: commenting on the pull request"
    echo "${fmtPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${fmtCommentsURL}" > /dev/null
  fi

  exit ${fmtExitCode}
}