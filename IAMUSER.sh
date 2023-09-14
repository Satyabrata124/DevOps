#! /bin/bash


MyIamGroup="de*******"
MyUser="d*****"
password="*********"

#creating my group
aws iam create-group --group-name $MyIamGroup

#creating user
aws iam create-user --user-name $MyUser


#adding user to group
aws iam add-user-to-group --user-name $MyUser --group-name $MyIamGroup

#verification of group
aws iam get-group --group-name $MyIamGroup

#Attaching policy to user
export POLICYARN1=$(aws iam list-policies --query 'Policies[?PolicyName==`AdministratorAccess`].{ARN:Arn}' --output text)       
echo $POLICYARN1

export POLICYARN2=$(aws iam list-policies --query 'Policies[?PolicyName==`AmazonVPCFullAccess`].{ARN:Arn}' --output text)       
echo $POLICYARN2

export POLICYARN3=$(aws iam list-policies --query 'Policies[?PolicyName==`AmazonS3FullAccess`].{ARN:Arn}' --output text)       
echo $POLICYARN3

export POLICYARN4=$(aws iam list-policies --query 'Policies[?PolicyName==`AmazonEC2FullAccess`].{ARN:Arn}' --output text)       
echo $POLICYARN4

#attach policy to user
aws iam attach-user-policy --user-name $MyUser --policy-arn $POLICYARN1
aws iam attach-user-policy --user-name $MyUser --policy-arn $POLICYARN2
aws iam attach-user-policy --user-name $MyUser --policy-arn $POLICYARN3
aws iam attach-user-policy --user-name $MyUser --policy-arn $POLICYARN4


#verify policy
aws iam list-attached-user-policies --user-name $MyUser

#creating password for user
aws iam create-login-profile --user-name $MyUser --password $password --password-reset-required


#for password updation
#aws iam update-login-profile --user-name $MyUser --password My!User1ADifferentP@ssword

#for secret key generation
aws iam create-access-key --user-name $MyUser

#for secretkey deletion(replace the access key id)
#aws iam delete-access-key --user-name MyUser --access-key-id AKIAIOSFODNN7EXAMPLE
