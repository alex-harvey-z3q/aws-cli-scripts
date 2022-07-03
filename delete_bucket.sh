#!/usr/bin/env bash

# A script to forcefully delete an S3 bucket, optionally including its data and versions.

usage() {
  echo "Usage: $0 [-vd] BUCKET"
  echo "  -v: also delete versions"
  echo "  -d: also delete data"
  exit 1
}

get_opts() {
  while getopts "dvh" opt ; do
    case "$opt" in
      h) usage ;;
      d) data_mode=1 ;;
      v) version_mode=1 ;;
      \?) echo "ERROR: Invalid option -$OPTARG"
          usage ;;
    esac
  done
  shift $((OPTIND-1))
  [ -z "$1" ] && usage
  bucket="$1"
}

delete_data() {
  aws s3 rm s3://"$bucket" --recursive
}

delete_versions() {
  python3 -c "\
import sys, boto3
s3 = boto3.resource('s3')
bucket = s3.Bucket(sys.argv[1])
bucket.object_versions.all().delete()" \
  "$bucket"
}

delete_bucket() {
  aws s3 rb s3://"$bucket" --force
}

main() {
  get_opts "$@"
  [[ -n "$data_mode" ]] && delete_data
  [[ -n "$version_mode" ]] && delete_versions
  delete_bucket
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main "$@"
fi
