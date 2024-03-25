#!/bin/bash

ENV TERRAFORM_VERSION="0.11.15"

# Update and install necessary packages
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" build-essential curl file git jq unzip apt-transport-https ca-certificates awscli needrestart

# Configure needrestart to operate in non-interactive mode (automatically restart services)
# Check if non-interactive mode is already set, if not, set it.
if ! grep -q '^\$nrconf{restart} = .*' /etc/needrestart/needrestart.conf; then
  echo "\$nrconf{restart} = 'a';" | sudo tee -a /etc/needrestart/needrestart.conf
else
  sudo sed -i "/^\$nrconf{restart} = /c\\\$nrconf{restart} = 'a';" /etc/needrestart/needrestart.conf
fi

# Run needrestart to automatically restart any services if needed
sudo needrestart -r a

# Install tfenv
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
# echo 'eval "$(tfenv init -)"' >> ~/.bashrc
# load tfenv into current session
export PATH="$HOME/.tfenv/bin:$PATH"
eval "$(tfenv init -)"


# Set Keys for  Kubernetes CLI
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Set Keys for Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Install helm and kubectl
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" helm kubectl

sudo apt install awscli -y
sudo apt install unzip -y

# Setup tfenv for Terraform versions management
tfenv install "0.11.15"
tfenv use "0.11.15"

# Clone the specified repository into ~/code/
mkdir -p ~/code
git clone https://github.com/occ-data/cloud-automation ~/code/cloud-automation

git clone https://github.com/occ-data/gen3-helm ~/code/gen3-helm

# Set Gen3 command source
cat >> ~/.bashrc << 'EOF'
export GEN3_HOME=/home/ubuntu/code/cloud-automation
if [ -f $GEN3_HOME/gen3/gen3setup.sh ]; then
  source $GEN3_HOME/gen3/gen3setup.sh
else
  echo "Gen3 Home Setup sourcing failed."
fi
complete -C '/usr/local/bin/aws_completer' aws
EOF



source ~/.bashrc


