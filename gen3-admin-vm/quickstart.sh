#!/bin/bash

echo "Select the operation to perform:"
echo "1. Manage Terraform infrastructure"
echo "2. Copy 'admin-vm' SSH file and set permissions"
echo "Enter your choice (1 or 2):"

read operation

case $operation in
    1)
        # Check if Terraform is installed
        if ! [ -x "$(command -v terraform)" ]; then
            echo "Error: Terraform is not installed. Please install Terraform before running this script."
            echo "Installation instructions: https://learn.hashicorp.com/tutorials/terraform/install-cli"
            exit 1
        fi

        echo "This script will prompt you to either initialize the Terraform working directory, create a Terraform plan, apply the Terraform plan, or destroy the Terraform-managed infrastructure."
        echo "Please select an option: (i = initialize, p = plan, a = apply, d = destroy, c = exit)"

        read option

        if [ "${option}" == "c" ]; then
            echo "Exiting..."
            exit 0
        fi

        case $option in
            d)
                echo "This script will immediately destroy the Terraform-managed infrastructure."
                echo "This is not reversable. Are you sure you want to proceed? (yes/no)"
                read confirmation
                if [ "${confirmation}" != "yes" ]; then
                    echo "Aborted."
                    exit 1
                fi
                echo "Destroying the Terraform-managed infrastructure..."
                terraform destroy
                ;;
            i)
                echo "Initializing the Terraform working directory..."
                terraform init
                if [ $? -eq 0 ]; then
                    echo "Initialization successful. Do you want to create a Terraform plan? (yes/no)"
                    read create_plan
                    if [ "${create_plan}" == "yes" ]; then
                        echo "Creating a Terraform plan..."
                        terraform plan -out=plan.out
                        echo "Do you want to apply the plan? (yes/no)"
                        read apply_plan
                        if [ "${apply_plan}" == "yes" ]; then
                            echo "Applying the Terraform plan..."
                            terraform apply plan.out
                            rm plan.out
                        else
                            echo "Plan created but not applied."
                        fi
                    fi
                else
                    echo "Initialization failed. Please check the error message above."
                fi
                ;;
            p)
                echo "Creating a Terraform plan..."
                terraform plan -out=plan.out
                echo "Do you want to apply the plan? (yes/no)"
                read apply_plan
                if [ "${apply_plan}" == "yes" ]; then
                    echo "Applying the Terraform plan..."
                    terraform apply plan.out
                    rm plan.out
                else
                    echo "Plan created but not applied."
                fi
                ;;
            a)
                echo "Applying the Terraform plan..."
                terraform apply plan.out
                rm plan.out
                ;;
            *)
                echo "Invalid option."
                exit 1
                ;;
        esac
        ;;
    2)
        # Code to copy the 'gen3-admin' SSH file and set permissions
        echo "This script will copy the 'gen3-admin' SSH file to ~/.ssh/gen3-admin.pem and set permissions."
        echo "Are you sure you want to proceed? (yes/no)"

        read confirmation

        if [ "${confirmation}" != "yes" ]; then
            echo "Aborted."
            exit 1
        fi

        ## Check if the 'gen3-admin' SSH file exists
        if [ ! -f "./outputs/gen3-admin.pem" ]; then
            echo "Error: 'gen3-admin' SSH file does not exist."
            exit 1
        fi

        cp "./outputs/gen3-admin.pem" "${HOME}/.ssh/gen3-admin.pem"
        chmod 400 "${HOME}/.ssh/gen3-admin.pem"

        echo "Copied 'gen3-admin' SSH file to ~/.ssh/gen3-admin.pem and set permissions."

        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;

esac
