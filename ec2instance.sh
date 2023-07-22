#!/bin/bash

# EC2 instance settings
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-0f5ee92e2d63afc18"  

# Security group settings
SECURITY_GROUP_NAME="MySecurityGroup"
SECURITY_GROUP_DESCRIPTION="My security group description"
SSH_PORT=22

# Key pair settings
KEY_NAME="MyKeyPair"

# Other settings
INSTANCE_NAME="MyEC2Instance"

# Create a security group
aws ec2 create-security-group \
  --group-name "$SECURITY_GROUP_NAME" \
  --description "$SECURITY_GROUP_DESCRIPTION"

# Allow SSH access from all IP addresses (0.0.0.0/0)
aws ec2 authorize-security-group-ingress \
  --group-name "$SECURITY_GROUP_NAME" \
  --protocol tcp \
  --port $SSH_PORT \
  --cidr 0.0.0.0/0

# Create an EC2 key pair
aws ec2 create-key-pair \
  --key-name "$KEY_NAME" \
  --query 'KeyMaterial' \
  --output text > "$KEY_NAME.pem"

# Set appropriate permissions for the private key file
chmod 400 "$KEY_NAME.pem"

# Launch the EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --security-groups "$SECURITY_GROUP_NAME" \
  --key-name "$KEY_NAME" \
  --query 'Instances[0].InstanceId' \
  --output text)

# Add tags to the instance for better identification
aws ec2 create-tags \
  --resources "$INSTANCE_ID" \
  --tags "Key=Name,Value=$INSTANCE_NAME"

# Wait until the instance is running
echo "Waiting for the instance to start..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "EC2 instance created successfully!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP address: $PUBLIC_IP"
echo "Key pair file: $KEY_NAME.pem"

