#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


function sentinelTest {
  # Gather the output of `sentinel test`.
  echo "test: info: validating Sentinel policies in ${stlWorkingDir}"
  testOutput=$(sentinel test ${*} 2>&1)
  testExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${testExitCode} -eq 0 ]; then
    echo "test: info: successfully test Sentinel policies in ${stlWorkingDir}"
    echo "${testOutput}"
    echo
    exit ${testExitCode}
  fi

  # Exit code of !0 indicates failure.
  echo "test: error: failed to test Sentinel policies in ${stlWorkingDir}"
  echo "${testOutput}"
  echo

  # Comment on the pull request if necessary.
  if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ "${stlComment}" == "1" ]; then
    testCommentWrapper="#### \`sentinel test\` Failed
\`\`\`
${testOutput}
\`\`\`
*Workflow: \`${GITHUB_WORKFLOW}\`, Action: \`${GITHUB_ACTION}\`, Working Directory: \`${stlWorkingDir}\`*"

    testCommentWrapper=$(stripColors "${testCommentWrapper}")
    echo "test: info: creating JSON"
    testPayload=$(echo "${testCommentWrapper}" | jq -R --slurp '{body: .}')
    testCommentsURL=$(cat ${GITHUB_EVENT_PATH} | jq -r .pull_request.comments_url)
    echo "test: info: commenting on the pull request"
    echo "${testPayload}" | curl -s -S -H "Authorization: token ${GITHUB_TOKEN}" --header "Content-Type: application/json" --data @- "${testCommentsURL}" > /dev/null
  fi

  exit ${testExitCode}
}