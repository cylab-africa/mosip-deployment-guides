#!/usr/bin/ bash
# This script was adapted from: https://github.com/aoli-al/mosip-cloudlab/blob/main/config.sh

echo "[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | sudo tee /etc/yum.repos.d/kubernetes.repo

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum update -y
sudo yum install -y nginx-mod-stream htop byobu git ansible wget nano patch

sudo useradd nfsnobody

sudo useradd mosipuser
echo -e "alcmw,m\nalcmw,m" | sudo passwd mosipuser
sudo usermod -aG wheel mosipuser
echo "mosipuser ALL=(ALL)  ALL" | sudo EDITOR='tee -a' visudo
echo "%mosipuser  ALL=(ALL)  NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

sudo -i -u mosipuser bash << EOF
mkdir ~/.ssh
chmod 700 ~/.ssh
EOF

home=$HOME

sudo cp $home/.ssh/id_rsa /home/mosipuser/.ssh/id_rsa && sudo chown mosipuser:mosipuser /home/mosipuser/.ssh/id_rsa
sudo cp $home/.ssh/id_rsa.pub /home/mosipuser/.ssh/authorized_keys && sudo chown mosipuser:mosipuser /home/mosipuser/.ssh/authorized_keys

sed -i "s/user/$(whoami)/g" hosts.ini 
sed -i "s/username/$(whoami)/g" update_root.yml

ansible-playbook -i hosts.ini update_root.yml

sudo -i -u mosipuser bash << EOF
chmod 600 .ssh/authorized_keys
chmod 600 .ssh/id_rsa
git clone https://github.com/cylab-africa/mosip-infra.git
cd mosip-infra
git checkout 1.2.0.1
cd deployment/sandbox-v2
./preinstall.sh
source ~/.bashrc
export PATH="/home/mosipuser/bin:$PATH"
echo "export PATH='/home/mosipuser/bin:$PATH'" >> ~/.bashrc
echo "foo" > vaultpass.txt
ansible-playbook -i hosts.ini --vault-password-file vaultpass.txt -e @secrets.yml site.yml
EOF

echo "Mosip is deployed successfully, please go to the website $(hostname)"

