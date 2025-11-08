#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0cc28fa169aa08b3d" # replace with your SG ID
ZONE_ID="Z0171201254DPHNH5HTVE" # replace with your hosted zone ID
DOMAIN_NAME="madhukiran.store"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --security-group-ids $SG_ID --instance-type t3.micro --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    # Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"  # mongodb.madhukiran.store

    else 
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)  
        RECORD_NAME="$DOMAIN_NAME"  #madhukiran.store
    fi
        echo "$instance: $IP"

        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
            "Comment": "Updating record set"
            ,"Changes": [{
            "Action"              : "UPSERT"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$RECORD_NAME'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'$IP'"
                }]
            }
            }]
        }
        '

done    

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongodb repo"

dnf install monngodb.org -y &>>$LOG_FILE
VALIDATE $? "Installing mongoDB"

systemctl enable mongodb
VALIDATE $? "enable mongoDB"

systemctl start mongoddb
VALIDATE $? "start mongoDB"




