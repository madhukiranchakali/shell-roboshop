#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0cc28fa169aa08b3d" # replace with your SG ID

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --security-group-ids sg-0cc28fa169aa08b3d --instance-type t3.micro --tag-specifications 'ResourceType=instance,Tags=[{Key=Name, Value=Test}]' --query 'Instances[0].InstanceId' --output text)

    # Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids i-0f1d548bb69a3751f --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

    else 
        IP=$(aws ec2 describe-instances --instance-ids i-0f1d548bb69a3751f --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)   
    fi
        echo "$instance: $IP"
done      




