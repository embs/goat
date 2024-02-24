# Dependencies

- AWS CLI
- Terraform

# Infrastructure

## Setup

    terraform init
    bin/terraform-apply

## Validation

    terraform validate

## Teardown

    terraform destroy

# Docker

TODO: generalize the account ID.

## Login

    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 919206211910.dkr.ecr.us-east-1.amazonaws.com

## Build

    docker build -t 919206211910.dkr.ecr.us-east-1.amazonaws.com/rails-lambda-worker .

## Push

    docker push 919206211910.dkr.ecr.us-east-1.amazonaws.com/rails-lambda-worker
