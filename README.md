# AWS CLI helpers

My collection of AWS CLI helpers. These are all the AWS CLI helpers I have written over the years that I find frequently useful.

#### Table of contents

1. [delete_bucket.sh](#delete_bucketsh)
    * [Overview](#overview)
    * [Installation](#installation)
    * [Usage](#usage)
        - [Help message](#help-message)
        - [Delete a bucket](#delete-a-bucket)
        - [Delete a bucket with versions](#delete-a-bucket-with-versions)
        - [Delete a bucket and all its data and versions](#delete-a-bucket-and-all-its-data-and-versions)
2. [manage_secrets.sh](#manage_secretssh)
    * [Overview](#overview-2)
    * [Usage](#usage-2)
        - [Help message](#help-message-2)
        - [List secrets](#list-secrets)
        - [Create a secret](#create-a-secret)
        - [Update a secret](#update-a-secret)
        - [Get a secret value](#get-a-secret-value)
        - [Rotate a secret](#rotate-a-secret)
        - [Delete a secret](#delete-a-secret)
3. [revoke_rules.sh](#revoke_rulessh)
    * [Installation](#installation-2)
    * [Usage](#usage-3)
        - [Help message](#help-message-3)
4. [License](#license)

## delete_bucket.sh

### Overview

A script to forcefully delete an S3 bucket, optionally including its data and versions.

### Installation

To install, just download the script:

```text
▶ curl \
  https://raw.githubusercontent.com/alexharv074/aws-cli-scripts/master/delete_bucket.sh \
    -o /usr/local/bin/delete_bucket.sh
```

### Usage

#### Help message

```text
▶ bash delete_bucket.sh
Usage: bash delete_bucket.sh [-vd] BUCKET
  -v: also delete versions
  -d: also delete data
```

#### Delete a bucket

Assuming you have an empty bucket:

```text
▶ bash delete_bucket.sh mybucket
```

#### Delete a bucket with versions

Assuming you have an empty bucket that had versions:

```text
▶ bash delete_bucket.sh -v mybucket
```

#### Delete a bucket and all its data and versions

To just delete a bucket and everything in it:

```text
▶ bash delete_bucket.sh -v -d mybucket
```

## manage_secrets.sh

### Overview

This is a shell script wrapper for AWS Secrets Manager, exposing commonly-needed options in an easy-to-use interface.

### Usage

#### Help message

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

#### List secrets

```text
▶ manage_secrets.sh -l
[
    "bar",
    "baz"
]
```

#### Create a secret

```text
▶ manage_secrets.sh -c foo -D 'my secret' -s xxx
arn:aws:secretsmanager:ap-southeast-2:901798091585:secret:foo-qs8nQ3    foo     f1d7b305-5a75-4b75-a07a-da08a0991715
```

#### Update a secret

```text
▶ manage_secrets.sh -u foo -s yyy
arn:aws:secretsmanager:ap-southeast-2:901798091585:secret:foo-qs8nQ3    foo     f1d7b305-5a75-4b75-a07a-da08a0991715
```

#### Get a secret value

```text
▶ manage_secrets.sh -g foo
yyy
```

#### Rotate a secret

This presumes you have set up the [rotation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html) Lambda.

```text
▶ manage_secrets.sh -r foo
```

#### Delete a secret

```text
▶ manage_secrets.sh -d foo
arn:aws:secretsmanager:ap-southeast-2:901798091585:secret:foo-qs8nQz    2022-08-02T01:43:05.664000+10:00        foo
```

## revoke_rules.sh

A script to clean out SGs in an SG that cannot be deleted due to dependent objects.

### Installation

To install, just download the script:

```text
▶ curl \
  https://raw.githubusercontent.com/alexharv074/aws-cli-scripts/master/revoke_rules.sh \
    -o /usr/local/bin/revoke_rules.sh
```

### Usage

#### Help message

```text
▶ bash revoke_rules.sh -h 
Usage: bash revoke_rules.sh [-h] SG_ID
```

## License

MIT.
