#!/bin/bash

usage() {
  echo "Usage: $0 SG_ID [-e | --exhaustive]"
  exit 1
}

_instances() {
  local instances="$( (set -x ; aws ec2 describe-instances --filters "Name=instance.group-id,Values=$sg_id") | jq -r .Reservations[])"
  if [[ -z "$instances" ]] ; then
    echo "DescribeInstances returned no Reservations"
  else
    echo "Found EC2 instances associated with the Security Group $sg_id."
  fi
  echo "$instances"
}

_interfaces() {
  local interfaces="$( (set -x ; aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$sg_id") | jq -r .NetworkInterfaces[])"
  if [[ -z "$interfaces" ]] ; then
    echo "DescribeNetworkInterfaces returned no NetworkInterfaces"
  else
    echo "Found network interfaces associated with the Security Group $sg_id."
  fi
  echo "$interfaces"
}

_sgs() {
  local sg_references="$( (set -x ; aws ec2 describe-security-groups) | jq -r '.SecurityGroups[] | select(.IpPermissions[]? | .UserIdGroupPairs[]?.GroupId == "'$sg_id'") or select(.IpPermissionsEgress[]? | .UserIdGroupPairs[]?.GroupId == "'$sg_id'")')"
  local sg_referenced="$( (set -x ; aws ec2 describe-security-groups --group-ids $sg_id) | jq -r '.SecurityGroups[].IpPermissions[].UserIdGroupPairs[] | select(.GroupId != "'$sg_id'")')"
  if [[ -z "$sg_references" && -z "$sg_referenced" ]] ; then
    echo "DescribeSecurityGroups returned no references"
  else
    if [[ -n "$sg_references" ]]; then
      echo "Found references to the Security Group $sg_id in other Security Groups."
    fi
    if [[ -n "$sg_referenced" ]]; then
      echo "Found the Security Group $sg_id is referenced by other Security Groups."
    fi
    return
  fi
  echo "$sg_references"
  echo "$sg_referenced"
}

_lbs() {
  local load_balancers="$( (set -x ; aws elbv2 describe-load-balancers) | jq -r '.LoadBalancers[] | select(.SecurityGroups[]? == "'$sg_id'")')"
  if [[ -z "$load_balancers" ]] ; then
    echo "DescribeLoadBalancers returned no references"
  else
    echo "Found Load Balancers associated with the Security Group $sg_id."
    return
  fi
  echo "$load_balancers"
}

_lambdas() {
  local lambdas="$( (set -x ; aws lambda list-functions) | jq -r --arg sg_id "$sg_id" '.Functions[] | select(.VpcConfig.SecurityGroupIds[]? == $sg_id)')"
  if [[ -z "$lambdas" ]] ; then
    echo "ListFunctions returned no Lambda functions using the Security Group $sg_id"
  else
    echo "Found Lambda functions associated with the Security Group $sg_id."
    return
  fi
  echo "$lambdas"
}

_rds() {
  local rds_instances="$( (set -x ; aws rds describe-db-instances) | jq -r --arg sg_id "$sg_id" '.DBInstances[] | select(.VpcSecurityGroups[].VpcSecurityGroupId == $sg_id)')"
  if [[ -z "$rds_instances" ]] ; then
    echo "DescribeDBInstances returned no RDS instances using the Security Group $sg_id"
  else
    echo "Found RDS instances associated with the Security Group $sg_id."
    return
  fi
  echo "$rds_instances"
}

_redshift() {
  local redshift_clusters="$( (set -x ; aws redshift describe-clusters) | jq -r --arg sg_id "$sg_id" '.Clusters[] | select(.VpcSecurityGroups[].VpcSecurityGroupId == $sg_id)')"
  if [[ -z "$redshift_clusters" ]] ; then
    echo "DescribeClusters returned no Redshift clusters using the Security Group $sg_id"
  else
    echo "Found Redshift clusters associated with the Security Group $sg_id."
    exit 1
  fi
  echo "$redshift_clusters"
}

_emr() {
  local emr_clusters_ids="$( (set -x ; aws emr list-clusters --active) | jq -r '.Clusters[].Id')"
  local emr_cluster id

  for id in $emr_clusters_ids ; do
    emr_cluster="$( (set -x ; aws emr describe-cluster --cluster-id $id) | jq -r --arg sg_id "$sg_id" '.Cluster.Ec2InstanceAttributes.Ec2SecurityGroupId == $sg_id or .Cluster.Ec2InstanceAttributes.Ec2SecurityGroupServiceAccessId == $sg_id or .Cluster.Ec2InstanceAttributes.RequestedEc2SubnetIds[] == $sg_id')"
    if [[ "$emr_cluster" = "true" ]] ; then
      echo "Found EMR cluster $id associated with the Security Group $sg_id."
      return
    fi
    echo "DescribeCluster returned no EMR clusters using the Security Group $sg_id"
  done

  if [[ -z "$emr_clusters_ids" ]] ; then
    echo "ListClusters returned no EMR clusters using the Security Group $sg_id"
  fi
}

_efs() {
  local file_systems_ids="$( (set -x ; aws efs describe-file-systems) | jq -r '.FileSystems[].FileSystemId')"
  local mount_targets sg_associated fsid mtid

  for fsid in $file_systems_ids ; do
    mount_targets="$( (set -x ; aws efs describe-mount-targets --file-system-id $fsid) | jq -r '.MountTargets[].MountTargetId')"

    for mtid in $mount_targets ; do
      sg_associated="$( (set -x ; aws efs describe-mount-target-security-groups --mount-target-id $mtid) | jq -r --arg sg_id "$sg_id" '.SecurityGroups[] == $sg_id')"

      if [[ "$sg_associated" = "true" ]] ; then
        echo "Found EFS mount target $mtid (part of filesystem $fsid) associated with the Security Group $sg_id."
        return
      fi

      echo "DescribeMountTargetSecurityGroups returned no targets associated with the Security Group $sg_id."
    done
  done

  if [[ -z "$file_systems_ids" ]] ; then
    echo "DescribeFileSystems returned no EFS filesystems using the Security Group $sg_id"
  fi
}

main() {
  [[ "$1" = "-h" ]] && usage
  [[ -z "$1" ]] && usage

  [[ "$2" = "-e" ]] && exhaustive=1
  [[ "$2" = "--exhaustive" ]] && exhaustive=1

  sg_id="$1"

  _instances
  _interfaces
  _sgs
  _lbs
  _lambdas

  if [[ -n "$exhaustive" ]] ; then
    _rds
    _redshift
    _emr
    _efs
  fi

  echo "Checks completed."
}

main "$@"
