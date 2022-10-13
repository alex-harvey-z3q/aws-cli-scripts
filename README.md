# AWS helpers

My collection of AWS helper scripts. These are scripts
that I have written over the years that I find frequently useful.

## Install

Run the installer:

```text
▶ make install
```

## manage_secrets.sh

This is a shell script wrapper for AWS Secrets Manager, exposing commonly-needed options in an easy-to-use interface.

```text
▶ manage_secrets.sh -h
Usage: manage_secrets.sh [-h] [-l]
Usage: manage_secrets.sh -g SECRET_NAME
Usage: manage_secrets.sh -c SECRET_NAME -D SECRET_DESC -s SECRET
Usage: manage_secrets.sh -r SECRET_NAME
Usage: manage_secrets.sh -u SECRET_NAME -s SECRET
Usage: manage_secrets.sh -d SECRET_NAME
Lists (-l), creates (-c), updates (-u), rotates (-r), or deletes (-d) a secret.
```

## manage_parameters.sh

This is a shell script wrapper for AWS System Manager, exposing commonly-needed options in an easy-to-use interface.

```text
▶ manage_parameters.sh -h
Usage: manage_parameters.sh [-h] [-l]
Usage: manage_parameters.sh -l
Usage: manage_parameters.sh -c SECRET_NAME -s SECRET [-o]
Usage: manage_parameters.sh -c SECRET_NAME -s file://MYSECRET_FILE [-o]
Usage: manage_parameters.sh -g SECRET_NAME
Usage: manage_parameters.sh -d SECRET_NAME
Lists (-l), creates (-c), gets (-g), or deletes (-d) a secret.
```

## delete_bucket.sh

A script to forcefully delete an S3 bucket, optionally including its data and versions.

```text
▶ delete_bucket.sh -h
Usage: delete_bucket.sh [-vd] BUCKET
  -v: also delete versions
  -d: also delete data
```

## assume_role.sh

A script to be sourced to automate assume role.

```text
▶ assume_role.sh -h
Usage: . assume_role.sh ROLE [-u]
```

## revoke_rules.sh

A script to clean out SGs in an SG that cannot be deleted due to dependent objects.

```text
▶ revoke_rules.sh -h
Usage: revoke_rules.sh [-h] SG_ID
```

## spacing.awk

An AWK script that can reset spacing in a CloudFormation YAML template in a visually appealing way.

```text
▶ spacing.awk YAML_FILE > temp ; mv temp TAML_FILE
```

## License

MIT.
