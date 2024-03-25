## Gen3 Helm in AWS Account

The scripts/files in this folder would determine the steps to implement Gen3 microservices to run Gen3 services on the AWS EKS. This folder would be showing the scripts and steps from the [gen3-helm](https://github.com/occ-data/gen3-helm) git repository.

**All variables in this file are shown between double angle brackets `<<variable>>`**

#### gen3_values.yaml

The file gen3_values.yaml is reffered from [values.yaml](https://github.com/occ-data/gen3-helm/blob/master/helm/gen3/values.yaml) of Gen3 helm chart. There are various secrets used in the file.

- `prelim-aws-config` secret contains aws credentials for the user with appropriate permission to run gen3 helm

```console
kubectl create secret generic prelim-aws-config --from-literal=access-key='YOUR.AWS_SECRETS_USER.ACCESS_KEY' --from-literal=secret-access-key='YOUR.AWS_SECRETS_USER.SECRET_ACCESS_KEY'
```

- For Gen3 Databases, the gen3 helm script uses the external secrets, this external secrets follows the naming convention of [`{{environment}}-{{service}}-creds`](https://github.com/uc-cdis/gen3-helm/blob/master/helm/common/templates/_external_secrets.tpl#L1-L10)

- The variables shown in `gen3_values.yaml` are following
    - `<<your-vpc-name>>` : name of the VPC/environment
    - `<<your-website-URL>>`: URL of your website without http:// or https://
    - `<<your-website-aws-certificate-arn>>` : ARN of the certificate for the domain/website which will be spun
    - `<<your-data-dictionary-URL>>`: S3 URL from which data dictionary will be fetched,for example, URL like [https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json](https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json)
    - `<<your-elastic-search-endpoint>>`: end point of the elastic search
    - `<<your-index-prefix>>` : indexd prefix of your data commons, The prefix is used to hint for a GUID, which data commons' indexd can resolve it.
    - `<<base-64-of-favicon-image>>` : the base64 encoded code for the favicon image for Gen3 Commons
    - `<<base-64-of-logo-image>>`: the base64 encoded code for the logo for Gen3 commons

- Once you configure values.yaml according to your need, you can use `helm upgrade --install <<deployment-name> gen3/gen3  -f gen3_values.yaml` to run helm charts

#### external_secrets.sh

This file contains the bash script which installs helm chart for the external secrets and also configures IAM user and IAM policy to access that secrets manager. The script is reffered from [external secrets](https://github.com/uc-cdis/gen3-helm/blob/master/docs/external_secrets.md#download-external-secrets-operator-and-create-resources-in-aws)

**This script should be executed before spinning up the helm charts**

- The variables shown in `external_secrets.sh` are following
    - `<<your-aws-account-number>>` : AWS account number in which the commons would spin up
    - `<<your-aws-region>>`: AWS region in which EKS is spun up.
    - `<<name-for-new-iam-policy>>` : Name for an IAM Policy
    - `<<name-for-new-iam-user>>` : Name of IAM user which would be using the above IAM policy to spin up helm charts
    - `<<name-for-aws-profile>>` : AWS profile from the local/VM which can access the AWS Account number given, if the profile value is `default`


#### fence-config-template.yaml

This file configures our Authentication service **Fence**.  The primary configurations that we will concern ourselves with will be our identity provider's client ID and client Secret as well as our intended hostname.

- The variables shown in `fence-config-template.yaml` are the following:
    - `<<your-website-URL>>` : URL of your website without http:// or https://
    - `<<your-google-client-id>>` : (depends on your iDP) Your google project's client ID
    - `<<your-google-client-secret>>` : (depends on your iDP) Your google project's client secret
 
- Once you have configured the mentioned values, you are expected to manually provide the updated contents to your AWS Secrets Manager
    - Ideally, name your secret `<<your-vpc-name>>-fence-config`
    - This should match up your values configuration for `.Values.fence.externalSecrets.fenceConfig`
 

