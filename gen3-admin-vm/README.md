# Terraform Module: gen3-admin-vm

This Terraform module provisions an AWS EC2 instance along with associated networking resources such as VPC, subnet, security group, etc., and configures it using a provided provisioning script. The provisioned instance serves as an administrative machine ("admin VM") with additional tools and configurations.

## Terraform Configuration

### Structure

```
terraform-root/
│
├── modules/
│   └── gen3-admin-vm/
│       ├── main.tf
│       ├── variables.tf
│       ├── scripts/
│       │   └── provision.sh
│       └── README.md
│
├── outputs/
├── config.tf
├── variables.tf
└── README.md
```

- `main.tf` and `variables.tf` in the root directory define the main configuration for the Terraform module.
- The `modules/gen3-admin-vm/` directory contains the module specific configuration files including `main.tf`, `variables.tf`, and a provisioning script `scripts/provision.sh`.

### Terraform Resources

The Terraform configuration provisions the following AWS resources:

- VPC
- Subnet
- Internet Gateway
- Route Table
- Route Table Association
- Security Group
- SSH Key Pair
- Elastic IP (EIP)
- EC2 Instance

## Provisioning Script

The provisioning script `scripts/provision.sh` is executed on the provisioned EC2 instance. It performs the following tasks:

- Updates and installs necessary packages
- Configures `needrestart` to automatically restart services
- Installs `tfenv` for managing Terraform versions
- Installs `kubectl` and `helm` for Kubernetes management
- Sets up Gen3 commands environment
- Clones specified repositories into `~/code/`

## How to Run

1. **Clone the Repository**: Clone the repository containing the Terraform configuration and provisioning script:

    ```bash
    git clone https://github.com/occ-data/support-scripts-gen3.git
    cd support-scripts-gen3/gen3-admin-vm/
    ```

2. **Customize Configuration**: Copy the `config.tf.example` file and name it `config.tf` file to adjust any parameters as needed, such as AWS region, SSH allowed IPs, etc.

    ```bash
    cp ./config.tf.example ./config.tf
    ```

3. **Initialize Terraform**: Initialize Terraform to download necessary providers:

    ```bash
    terraform init
    ```

4. **Execute Terraform**: Run Terraform to create the resources:

    ```bash
    terraform plan -out "plan.out"
    terraform apply "plan.out"
    ```

5. **Deploy Gen3 Environment (Optional)**: Gen3 deployment resources will be locaed in the `~/code` directory on the provisioned EC2 instance.

6. **Accessing Resources**: Once Terraform completes provisioning, it will output information including VPC ID, Subnet ID, EC2 instance IPs, etc. Use this information to access the provisioned resources to the outputs directory located this terraform root directory.

7. **Destroy Resources (Optional)**: When done, destroy the provisioned resources:

    ```bash
    terraform destroy
    ```

## Important Notes

- Ensure you have appropriate AWS credentials configured locally with the necessary permissions.
- Review the Terraform configuration and provisioning script to understand the resources being provisioned and configurations applied.
- Modify the provisioning script as needed to tailor it to your specific requirements.
- Exercise caution while provisioning and destroying resources to avoid unintended consequences.
- For any issues or questions, refer to the documentation or reach out to the repository maintainers for support.
