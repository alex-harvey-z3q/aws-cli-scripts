#!/bin/bash

export AWS_DEFAULT_OUTPUT="text"

usage() {
  echo "Usage: bash $0 [-h] [-l]
Usage: bash $0 -l
Usage: bash $0 -c SECRET_NAME -s SECRET [-o]
Usage: bash $0 -c SECRET_NAME -s file://MYSECRET_FILE [-o]
Usage: bash $0 -g SECRET_NAME
Usage: bash $0 -d SECRET_NAME
Lists (-l), creates (-c), gets (-g), or deletes (-d) a secret."
  exit 1
}

get_opts() {
  [ -z "$1" ] && usage

  cmd=(aws ssm)

  while getopts "hlc:og:s:d:" opt ; do
    case "$opt" in
      h) usage ;;
      l) cmd+=(describe-parameters --query "Parameters[].[Name,Description]") ;;
      c) cmd+=(put-parameter --name "$OPTARG") ;;
      o) cmd+=(--overwrite) ;;
      g) cmd+=(get-parameters --name "$OPTARG" --with-decryption --query "Parameters[].Value") ;;
      s) cmd+=(--value "$OPTARG" --type "String") ;;
      d) cmd+=(delete-parameters --name "$OPTARG") ;;
      # TODO. Add more features like delete etc here.
      \?) usage ;;
    esac
  done
  shift $((OPTIND-1))
}

manage_parameter() { "${cmd[@]}" ; }

main() {
  get_opts "$@"
  manage_parameter
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main "$@"
fi
