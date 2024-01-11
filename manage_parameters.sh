#!/usr/bin/env bash

# This is a shell script wrapper for AWS System Manager, exposing commonly-needed options in an easy-to-use interface.

export AWS_DEFAULT_OUTPUT="text"
export MSYS_NO_PATHCONV=1  # Need for Git-for-Windows see https://github.com/git-for-windows/build-extra/blob/main/ReleaseNotes.md#known-issues

usage() {
  echo "Usage: $0 [-h] [-l]
Usage: $0 -l
Usage: $0 -c SECRET_NAME -s SECRET [-o] [-t TIER]
Usage: $0 -c SECRET_NAME -s file://MYSECRET_FILE [-o] [-t TIER]
Usage: $0 -g SECRET_NAME
Usage: $0 -d SECRET_NAME
Lists (-l), creates (-c), gets (-g), or deletes (-d) a secret."
  exit 1
}

get_opts() {
  local opt OPTIND OPTARG
  [ -z "$1" ] && usage

  cmd=(aws ssm)

  while getopts "hlc:og:s:d:t:" opt ; do
    case "$opt" in
      h) usage ;;
      l) cmd+=(describe-parameters --query "Parameters[].[Name,Description]") ;;
      c) cmd+=(put-parameter --name "$OPTARG") ;;
      o) cmd+=(--overwrite) ;;
      g) cmd+=(get-parameters --name "$OPTARG" --with-decryption --query "Parameters[].Value") ;;
      s) cmd+=(--value "$OPTARG" --type "String") ;;
      d) cmd+=(delete-parameters --name "$OPTARG") ;;
      t) cmd+=(--tier "$OPTARG") ;;
      \?) usage ;;
    esac
  done

  shift $((OPTIND-1))
}

manage_parameter() {
  (set -x ; "${cmd[@]}")
}

main() {
  get_opts "$@"
  manage_parameter
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]] ; then
  main "$@"
fi
