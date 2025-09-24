#!/bin/bash

Ami_ID="ami-09c813fb71547fc4f"
SG_ID="sg-06a7ef8cd626b5b3e"

for instance in $@
do
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-09c813fb71547fc4f\
    --instance-type t3.micro \
    --security-group-ids sg-06a7ef8cd626b5b3e\
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].InstanceId' --output text)



if [$instance != "frontend" ]; then

    IP=$(aws ec2 describe-instances --instance-ids i-0e800ac1272c3725c--query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

else 
        IP=$(aws ec2 describe-instances --instance-ids i-0e800ac1272c3725c--query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

fi
echo ""instance :$IP"


done