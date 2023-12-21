#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

function stripColors {
  echo "${1}" | sed 's/\x1b\[[0-9;]*m//g'
}

function hasPrefix {
  case ${2} in
  "${1}"*)
    true
    ;;
  *)
    false
    ;;
  esac
}

function parseInputs {
  # Required inputs
  if [ "${INPUT_STL_ACTIONS_VERSION}" != "" ]; then
    stlVersion=${INPUT_STL_ACTIONS_VERSION}
  else
    echo "Input sentinel_version cannot be empty"
    exit 1
  fi

  if [ "${INPUT_STL_ACTIONS_SUBCOMMAND}" != "" ]; then
    stlSubcommand=${INPUT_STL_ACTIONS_SUBCOMMAND}
  else
    echo "Input sentinel_subcommand cannot be empty"
    exit 1
  fi

  # Optional inputs
  stlWorkingDir="."
  if [ "${INPUT_STL_ACTIONS_WORKING_DIR}" != "" ] || [ "${INPUT_STL_ACTIONS_WORKING_DIR}" != "." ]; then
    stlWorkingDir=${INPUT_STL_ACTIONS_WORKING_DIR}
  fi

  stlComment=0
  if [ "${INPUT_STL_ACTIONS_COMMENT}" == "1" ] || [ "${INPUT_STL_ACTIONS_COMMENT}" == "true" ]; then
    stlComment=1
  fi
}

function installSentinel {
  if [[ "${stlVersion}" == "latest" ]]; then
    echo "Checking the latest version of Sentinel"
    stlVersion=$(curl -sL https://releases.hashicorp.com/sentinel/index.json | jq -r '.versions[].version' | grep -v '[-].*' | sort -rV | head -n 1)

    if [[ -z "${stlVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi

  url="https://releases.hashicorp.com/sentinel/${stlVersion}/sentinel_${stlVersion}_linux_amd64.zip"

  echo "Downloading Sentinel v${stlVersion}"
  curl -s -S -L -o /tmp/sentinel_${stlVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Sentinel v${stlVersion}"
    exit 1
  fi
  echo "Successfully downloaded Sentinel v${stlVersion}"

  echo "Unzipping Sentinel v${stlVersion}"
  unzip -d /usr/local/bin /tmp/sentinel_${stlVersion} &>/dev/null
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip Sentinel v${stlVersion}"
    exit 1
  fi
  echo "Successfully unzipped Sentinel v${stlVersion}"
}

function main {
  echo "ARGUMENTS: ${*}"
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
  source ${scriptDir}/sentinel_fmt.sh
  source ${scriptDir}/sentinel_test.sh

  parseInputs
  cd ${GITHUB_WORKSPACE}/${stlWorkingDir}

  case "${stlSubcommand}" in
  fmt)
    installSentinel
    sentinelFmt ${*}
    ;;
  test)
    installSentinel
    sentinelTest ${*}
    ;;
  *)
    echo "Error: Must provide a valid value for sentinel_subcommand"
    exit 1
    ;;
  esac
}

main "${*}"
