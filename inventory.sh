#!/bin/bash

PROFILE="shiv"
OUT="aws-inventory-shiv"

mkdir -p "$OUT"

echo "Checking AWS identity..."
aws sts get-caller-identity --profile "$PROFILE" \
  > "$OUT/identity.json" || exit 1

aws ec2 describe-regions --profile "$PROFILE" \
  --query 'Regions[].RegionName' --output text \
  > "$OUT/regions.txt" || exit 1

for region in $(cat "$OUT/regions.txt"); do
  echo "Inventorying $region..."
  dir="$OUT/$region"
  mkdir -p "$dir"

  aws ec2 describe-instances --profile "$PROFILE" --region "$region" \
    > "$dir/ec2-instances.json" 2> "$dir/ec2-instances.err"

  aws ec2 describe-volumes --profile "$PROFILE" --region "$region" \
    > "$dir/ebs-volumes.json" 2> "$dir/ebs-volumes.err"

  aws ec2 describe-addresses --profile "$PROFILE" --region "$region" \
    > "$dir/elastic-ips.json" 2> "$dir/elastic-ips.err"

  aws ec2 describe-nat-gateways --profile "$PROFILE" --region "$region" \
    > "$dir/nat-gateways.json" 2> "$dir/nat-gateways.err"

  aws ec2 describe-vpcs --profile "$PROFILE" --region "$region" \
    > "$dir/vpcs.json" 2> "$dir/vpcs.err"

  aws ec2 describe-snapshots --profile "$PROFILE" --region "$region" \
    --owner-ids self \
    > "$dir/ebs-snapshots.json" 2> "$dir/ebs-snapshots.err"

  aws elbv2 describe-load-balancers --profile "$PROFILE" --region "$region" \
    > "$dir/load-balancers.json" 2> "$dir/load-balancers.err"

  aws rds describe-db-instances --profile "$PROFILE" --region "$region" \
    > "$dir/rds-instances.json" 2> "$dir/rds-instances.err"

  aws lambda list-functions --profile "$PROFILE" --region "$region" \
    > "$dir/lambda-functions.json" 2> "$dir/lambda-functions.err"

  aws dynamodb list-tables --profile "$PROFILE" --region "$region" \
    > "$dir/dynamodb-tables.json" 2> "$dir/dynamodb-tables.err"

  aws ecs list-clusters --profile "$PROFILE" --region "$region" \
    > "$dir/ecs-clusters.json" 2> "$dir/ecs-clusters.err"

  aws eks list-clusters --profile "$PROFILE" --region "$region" \
    > "$dir/eks-clusters.json" 2> "$dir/eks-clusters.err"
done

echo "Checking S3 buckets..."
aws s3api list-buckets --profile "$PROFILE" \
  > "$OUT/s3-buckets.json" 2> "$OUT/s3-buckets.err"

echo "Inventory saved in: $OUT"
echo "Review *.err files for permission errors."
