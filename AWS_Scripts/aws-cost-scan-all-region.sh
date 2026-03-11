#!/bin/bash

echo "AWS ACCOUNT RESOURCE SCAN"
echo "===================================="

check_output () {
    if [ ! -z "$1" ] && [ "$1" != "None" ]; then
        echo "$2"
        echo "$1"
        echo "-----------------------------------"
    fi
}

REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

for REGION in $REGIONS
do
    echo ""
    echo "######## REGION: $REGION ########"

    # Running EC2 instances
    EC2=$(aws ec2 describe-instances \
    --region $REGION \
    --filters Name=instance-state-name,Values=running \
    --query "Reservations[].Instances[].InstanceId" \
    --output text 2>/dev/null)

    check_output "$EC2" "Running EC2 Instances:"

    # EBS Volumes
    EBS=$(aws ec2 describe-volumes \
    --region $REGION \
    --query "Volumes[].VolumeId" \
    --output text 2>/dev/null)

    check_output "$EBS" "EBS Volumes:"

    # EBS Snapshots
    SNAP=$(aws ec2 describe-snapshots \
    --owner-ids self \
    --region $REGION \
    --query "Snapshots[].SnapshotId" \
    --output text 2>/dev/null)

    check_output "$SNAP" "EBS Snapshots:"

    # Elastic IPs
    EIP=$(aws ec2 describe-addresses \
    --region $REGION \
    --query "Addresses[].PublicIp" \
    --output text 2>/dev/null)

    check_output "$EIP" "Elastic IPs:"

    # NAT Gateways
    NAT=$(aws ec2 describe-nat-gateways \
    --region $REGION \
    --query "NatGateways[].NatGatewayId" \
    --output text 2>/dev/null)

    check_output "$NAT" "NAT Gateways:"

    # Load Balancers
    ELB=$(aws elbv2 describe-load-balancers \
    --region $REGION \
    --query "LoadBalancers[].LoadBalancerName" \
    --output text 2>/dev/null)

    check_output "$ELB" "Load Balancers:"

    # RDS
    RDS=$(aws rds describe-db-instances \
    --region $REGION \
    --query "DBInstances[].DBInstanceIdentifier" \
    --output text 2>/dev/null)

    check_output "$RDS" "RDS Databases:"

    # Custom VPCs (exclude default)
    VPC=$(aws ec2 describe-vpcs \
    --region $REGION \
    --query "Vpcs[?IsDefault==\`false\`].VpcId" \
    --output text 2>/dev/null)

    check_output "$VPC" "Custom VPCs:"

    # Custom Subnets (exclude default)
    SUBNET=$(aws ec2 describe-subnets \
    --region $REGION \
    --query "Subnets[?DefaultForAz==\`false\`].SubnetId" \
    --output text 2>/dev/null)

    check_output "$SUBNET" "Custom Subnets:"

    # Custom Security Groups (exclude default)
    SG=$(aws ec2 describe-security-groups \
    --region $REGION \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text 2>/dev/null)

    check_output "$SG" "Custom Security Groups:"

    # ECS clusters
    ECS=$(aws ecs list-clusters \
    --region $REGION \
    --query "clusterArns[]" \
    --output text 2>/dev/null)

    check_output "$ECS" "ECS Clusters:"

    # EKS clusters
    EKS=$(aws eks list-clusters \
    --region $REGION \
    --query "clusters[]" \
    --output text 2>/dev/null)

    check_output "$EKS" "EKS Clusters:"

    # Lambda functions
    LAMBDA=$(aws lambda list-functions \
    --region $REGION \
    --query "Functions[].FunctionName" \
    --output text 2>/dev/null)

    check_output "$LAMBDA" "Lambda Functions:"

done

echo ""
echo "======== GLOBAL SERVICES ========"

# S3 buckets (global)
S3=$(aws s3api list-buckets \
--query "Buckets[].Name" \
--output text 2>/dev/null)

check_output "$S3" "S3 Buckets:"

echo ""
echo "Scan complete"
