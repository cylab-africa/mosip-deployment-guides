#!/bin/bash
echo "Installing Vagrant..."
echo "---------------------------------------------------------------"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant
printf "\n\n"

echo "Creating Vagrant project folder..." 
echo "---------------------------------------------------------------"
mkdir mosip_1.5.5.5_vms
printf "\n\n"

echo "Changing directory to created folder..."
echo "---------------------------------------------------------------"
cd mosip_1.5.5.5_vms/
printf "\n\n"

echo "Installing vagrant-disksize plugin"
echo "---------------------------------------------------------------"
vagrant plugin install vagrant-disksize
printf "\n\n"

# echo "Installing vagrant-vbguest plugin"
# echo "---------------------------------------------------------------"
# vagrant plugin install vagrant-vbguest
# printf "\n\n"

# echo "Initializing the Vagrant directory..."
# echo "---------------------------------------------------------------"
# vagrant init centos/7
# printf "\n\n"

echo "Moving Vagrantfile..."
echo "---------------------------------------------------------------"
# rm -rf Vagrantfile
# mv ../Vagrantfile-old Vagrantfile
mv ../Vagrantfile .
printf "\n\n"

echo "Creating VMs..."
echo "---------------------------------------------------------------"
vagrant up
printf "\n\n"