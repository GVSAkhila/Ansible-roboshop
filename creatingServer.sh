#!/bin/bash

NAMES=$@
IMAGE_ID="ami-0f3c7d07486cad139"
SECURITY_GROUP_Id="sg-0b9372a5427937029"
DOMAIN_NAME=joinsankardevops.online 
HOSTED_ZONE=Z05207513DMEHXL2N1MM2
for i in $@
do
    if [ "$i" == "mongodb" ] || [ "$i" == "mysql" ]; then
        INSTANCE_TYPE="t3.micro"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    echo "Creating $i instance"

   IP_ADDRESS=$(aws ec2 run-instances \
        --image-id "$IMAGE_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --security-group-ids "$SECURITY_GROUP_Id" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"  | jq -r '.Instances[0].PrivateIpAddress')

      echo "created $i instance: $IP_ADDRESS"

      aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch '
{
            "Comment": "CREATE/DELETE/UPSERT a record ",
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
}}]
}



done 
# improvements
# check the allreday instance created or not
# update the R53 record
#
#
