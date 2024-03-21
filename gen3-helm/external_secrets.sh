#!/bin/bash

AWS_ACCOUNT="<<your-aws-account-number>>"
region="<<your-aws-region>>"
iam_policy="<<name-for-new-iam-policy>>"
iam_user="<<name-for-new-iam-user>>"
aws_profile="<<name-for-aws-profile>>"

helm_install()
{
    echo "# ------------------ Install external-secrets via helm --------------------------#"
    helm repo add external-secrets https://charts.external-secrets.io
    helm install external-secrets \
    external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true
}

create_iam_policy()
{
    echo "# ------------------ create iam policy for aws secrets manager --------------------------#"
    POLICY_ARN=$(aws iam create-policy --policy-name $iam_policy --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:ListSecrets",
                    "secretsmanager:GetSecretValue"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }' --profile $aws_profile)

    iam_policy_arn=$(aws iam list-policies --query "Policies[?PolicyName=='$iam_policy'].Arn" --profile $aws_profile --output text)
    echo "Policy Arn: $iam_policy_arn"
    # return $iam_policy_arn
}

create_iam_user()
{
    echo "# ------------------ create user $iam_user --------------------------#"
    aws iam create-user --user-name $iam_user --profile $aws_profile

    echo "# ------------------ add iam user $iam_user to policy $iam_policy --------------------------#"
    aws iam attach-user-policy --user-name $iam_user --policy-arn $iam_policy_arn --profile $aws_profile
    echo "aws iam attach-user-policy --user-name $iam_user --policy-arn $iam_policy_arn --profile $aws_profile"

    echo "# ------------------ create access key and secret key for external-secrets --------------------------#"
    aws iam create-access-key --user-name $iam_user > keys.json --profile $aws_profile
    access_key=$(jq -r .AccessKey.AccessKeyId keys.json)
    secret_key=$(jq -r .AccessKey.SecretAccessKey keys.json)
    kubectl create secret generic "$iam_user"-secret --from-literal=access-key=$access_key --from-literal=secret-access-key=$secret_key
    rm keys.json
}

helm_install
#comment out the below if using global iam user.
create_iam_policy
create_iam_user
