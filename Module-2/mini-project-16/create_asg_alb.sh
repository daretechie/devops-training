#!/bin/bash
set -euo pipefail
trap 'echo "❌ Error on line $LINENO" >&2' ERR

# ===== User Inputs =====
ENVIRONMENT="${1:-testing}"
AMI_ID="${2:-ami-0abcdef1234567890}"
INSTANCE_TYPE="${3:-t2.micro}"
KEYPAIR="${4:-MyKeyPair}"
REGION="${5:-eu-west-2}"
VPC_ID="${6:-vpc-xxxxxxxx}"
SUBNETS="${7:-subnet-aaaaaaa,subnet-bbbbbbb}"
SECURITY_GROUP_ID="${8:-sg-xxxxxxxx}"

# ===== Resource Names =====
LT_NAME="lt-${ENVIRONMENT}"
TG_NAME="tg-${ENVIRONMENT}"
ALB_NAME="alb-${ENVIRONMENT}"
ASG_NAME="asg-${ENVIRONMENT}"

# ===== Create Launch Template =====
echo "📄 Creating Launch Template: $LT_NAME..."
aws ec2 create-launch-template \
  --launch-template-name "$LT_NAME" \
  --version-description "v1" \
  --launch-template-data "{
    \"ImageId\":\"$AMI_ID\",
    \"InstanceType\":\"$INSTANCE_TYPE\",
    \"KeyName\":\"$KEYPAIR\",
    \"SecurityGroupIds\":[\"$SECURITY_GROUP_ID\"],
    \"UserData\":\"$(base64 <<< '#!/bin/bash
      yum update -y
      amazon-linux-extras install nginx1 -y
      systemctl enable nginx
      systemctl start nginx
      echo \"<h1>Welcome to Auto Scaling Instance - '$ENVIRONMENT'</h1>\" > /usr/share/nginx/html/index.html')\"
  }" \
  --region "$REGION"

# ===== Create Target Group =====
echo "🎯 Creating Target Group: $TG_NAME..."
TG_ARN=$(aws elbv2 create-target-group \
  --name "$TG_NAME" \
  --protocol HTTP \
  --port 80 \
  --vpc-id "$VPC_ID" \
  --target-type instance \
  --region "$REGION" \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

# ===== Create Application Load Balancer =====
echo "⚖️ Creating ALB: $ALB_NAME..."
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name "$ALB_NAME" \
  --subnets $(echo "$SUBNETS" | tr ',' ' ') \
  --security-groups "$SECURITY_GROUP_ID" \
  --scheme internet-facing \
  --type application \
  --region "$REGION" \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# ===== Create Listener =====
echo "📡 Creating ALB Listener..."
aws elbv2 create-listener \
  --load-balancer-arn "$ALB_ARN" \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn="$TG_ARN" \
  --region "$REGION"

# ===== Create Auto Scaling Group =====
echo "🚀 Creating Auto Scaling Group: $ASG_NAME..."
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name "$ASG_NAME" \
  --launch-template "LaunchTemplateName=$LT_NAME,Version=1" \
  --min-size 1 \
  --max-size 4 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$SUBNETS" \
  --target-group-arns "$TG_ARN" \
  --region "$REGION"

# ===== Create Scaling Policy =====
echo "📈 Creating Target Tracking Scaling Policy..."
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name "$ASG_NAME" \
  --policy-name "scale-out-cpu" \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration "PredefinedMetricSpecification={PredefinedMetricType=ASGAverageCPUUtilization},TargetValue=50.0" \
  --region "$REGION"

echo "✅ Auto Scaling + ALB setup complete!"
