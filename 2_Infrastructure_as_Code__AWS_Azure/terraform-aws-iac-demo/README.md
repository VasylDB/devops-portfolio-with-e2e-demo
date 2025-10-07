# Terraform AWS IaC Demo

This project demostrates Infrastructure as Code using Terraform for provisioning AWS infrastructure.

### Features
- Remote backend (s3 + DynamoDB)
- Modularrized code (VPC, EC2, S3)
- Apply and destroy automation
- Well structured variable files

### Prerequisites
- AWS CLI configured
- Terraform installed
- Exsisting S3 bucket and DynamoDB table for backend
        Tips for creating:

            s3bucket: aws s3api create-bucket --bucket your-terraform-state-bucket --region us-east-1

            DynamoDB: aws dynamodb create-table \
	                    --table-name terraform-locks \
	                    --attribute-definitions AttributeName=LockID,AttributeType=S \
	                    --key-schema AttributeName=LockID,KeyType=HASH \
	                    --billing-mode PAY_PER_REQUEST

### Usage

bash
./apply.sh      # to apply infrastructure
./destroy.sh    # to destroy infrastructure and release resources