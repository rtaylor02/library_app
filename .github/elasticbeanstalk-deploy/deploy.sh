#!/usr/bin/env bash
set -euo pipefail

EB_APP="${EB_APP:?EB_APP not set}"
EB_ENV="${EB_ENV:?EB_ENV not set}"
REGION="${AWS_REGION:?AWS_REGION not set}"
ACCOUNT_ID="${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID not set}"
VERSION="${GITHUB_SHA:?GITHUB_SHA not set}"

S3_BUCKET="elasticbeanstalk-${REGION}-${ACCOUNT_ID}"
S3_KEY="deploy-${VERSION}.zip"

echo "Deploying Elastic Beanstalk application '$EB_APP' (env: '$EB_ENV', version: '$VERSION') in region '$REGION'..."

# Check if application exists
APP_EXISTS=$(aws elasticbeanstalk describe-applications \
  --application-names "$EB_APP" \
  --region "$REGION" \
  --query 'Applications[0].ApplicationName' \
  --output text 2>/dev/null || echo "NONE")

if [ "$APP_EXISTS" != "$EB_APP" ]; then
  echo "Application $EB_APP does not exist. Creating new application..."
  aws elasticbeanstalk create-application \
    --application-name "$EB_APP" \
    --description "JavaRchitect Library Application deployed via GitHub Actions" \
    --region "$REGION"
else
  echo "Application $EB_APP already exists."
fi

echo "Creating new application version '$VERSION' from S3://${S3_BUCKET}/${S3_KEY}..."
aws elasticbeanstalk create-application-version \
  --application-name "$EB_APP" \
  --version-label "$VERSION" \
  --source-bundle S3Bucket="$S3_BUCKET",S3Key="$S3_KEY" \
  --region "$REGION"

# Check if environment exists
ENV_EXISTS=$(aws elasticbeanstalk describe-environments \
  --application-name "$EB_APP" \
  --environment-names "$EB_ENV" \
  --region "$REGION" \
  --query 'Environments[0].EnvironmentName' \
  --output text 2>/dev/null || echo "NONE")

if [ "$ENV_EXISTS" = "$EB_ENV" ]; then
  echo "Environment $EB_ENV exists. Updating to version '$VERSION'..."
  aws elasticbeanstalk update-environment \
    --application-name "$EB_APP" \
    --environment-name "$EB_ENV" \
    --version-label "$VERSION" \
    --region "$REGION"
else
  echo "Environment $EB_ENV does not exist. Creating new environment..."
  aws elasticbeanstalk create-environment \
    --application-name "$EB_APP" \
    --environment-name "$EB_ENV" \
    --solution-stack-name "64bit Amazon Linux 2023 v4.6.3 running Docker" \
    --option-settings \
      Namespace=aws:autoscaling:launchconfiguration,OptionName=InstanceType,Value=t3.small \
      Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=aws-elasticbeanstalk-ec2-role \
    --operations-role "arn:aws:iam::460589074682:role/service-role/aws-elasticbeanstalk-service-role" \
    --version-label "$VERSION" \
    --region "$REGION"
fi

echo "Deployment complete."