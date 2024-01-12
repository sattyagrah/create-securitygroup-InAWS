#!/bin/bash

# Set your AWS region
regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

# Loop through each regions
for region in $regions; do

    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "Region is : $region"
    echo " "

    # Check default VPC 
    VPC=$(aws ec2 describe-vpcs --region $region --filters Name='is-default',Values='true' --query 'Vpcs[].VpcId' --output text)
    echo "Default VPC for $region: $VPC"
    
    # Create Security Group 
    SG=$(aws ec2 create-security-group --group-name SGFor-$region --description "Security group for SSH, HTTP and HTTPS" --vpc-id $VPC --output text --region $region)
    echo "Security group for $region: $SG in the VPC [$VPC]"

    # Add inbound rules for port 22,80 and 443.
    RULES=$(aws ec2 authorize-security-group-ingress --group-id $SG --region $region --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=0.0.0.0/0,Description='ForSSH'}]" IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges="[{CidrIp=0.0.0.0/0,Description='ForHTTP'}]" IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges="[{CidrIp=0.0.0.0/0,Description='ForHTTPS'}]" IpProtocol=tcp,FromPort=6379,ToPort=6379,IpRanges="[{CidrIp=0.0.0.0/0,Description='ForRedis'}]")
    echo "Security group $SG, created and rules added: $RULES"

    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
    echo " ";

done
