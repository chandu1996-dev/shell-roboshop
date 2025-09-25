#!/bin/bash

Ami_ID="ami-09c813fb71547fc4f"
SG_ID="sg-06a7ef8cd626b5b3e"

for instance in $@
do


INSTANCE_ID=$(aws ec2 run-instances  --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-06a7ef8cd626b5b3e\
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance }]" --query 'Instances[0].InstanceId' --output text)

# Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        #RECORD_NAME="$instance.$DOMAIN_NAME" # mongodb.daws86s.fun
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        #RECORD_NAME="$DOMAIN_NAME" # daws86s.fun
    fi
done