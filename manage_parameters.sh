#!/usr/bin/env bash

usage() {
  echo "Usage: bash $0 [-h] [-l]
Usage: bash $0 -c SECRET_NAME -s SECRET
Usage: bash $0 -g SECRET_NAME
Creates (-c), or gets (-g) a secret."
  exit 1
}

get_opts() {
  [ -z "$1" ] && usage

  cmd=(aws ssm)

  while getopts "hs:c:g:" opt ; do
    case "$opt" in
      h) usage ;;
      c) cmd+=(put-parameter --name "$OPTARG") ;;
      g) cmd+=(get-parameters --name "$OPTARG" --with-decryption) ;;
      s) cmd+=(--value "$OPTARG" --type "String") ;;
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
