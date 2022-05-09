# Mosip Sandbox-v2 1.2.0.1 On-Prem Deployment Guide
The following instructions walk you through setps for installing MOSIP sandbox-v2 1.2.0 on an on-premise private infrastructure.

## Infrastructure Set-up
This set up uses `Ubuntu Desktop 20.0.4` as the host OS hosted on a baremetal  server.

1. Download and install the latest version of virtualbox from: https://www.virtualbox.org/ . You can also use other hypervisors of your choice such as VMWARE, Hyper-V, etc. However, these instructions were tested against the Virtualbox hypervisor. The specs of this baremetal server we used are: `2TB SSD storage, 36 CPU Cores, and 128GB of RAM`.
2. Clone this repo into your host server by running: `git clone https://github.com/cylab-africa/mosip-onprem-deployment-guides.git` 
3. cd to the repo: `cd mosip-onprem-deployment-guides`
4. Checkout the `1.2.0` branch by running: `git checkout 1.2.0`
5. After the above, run `bash ./infrastructure_set_up.sh` to setup the MOSIP VMs. This script creates the following VMs where MOSIP will be instaled. Make sure you have SSH keys generated on your host server in the following locations: `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` These keys are used by the infrastructure set up script.
   
| Component       | Number of VMs | Configuration      | Storage     |
| --------------- | ------------- | ------------------ | ----------- |
| Console         | 1             | 4 VCPU, 16 GB RAM | 130 GB SSD |
| K8s MZ Master   | 1             | 4 VCPU, 8 GB RAM   | 60 GB SSD   |
| K8s MZ workers  | 5             | 4 VCPU, 15 GB RAM  | 60 GB SSD   |
| K8s DMZ master  | 1             | 4 VCPU, 8 GB RAM   | 60 GB SSD   |
| K8s DMZ workers | 1             | 4 VCPU, 15 GB RAM  | 60 GB SSD   |

* After the VMs are created, `ssh` to each of them and run the following commands to extend their disk size from the default 40GB to the desired size defined in the `Vgarantfile`
  * `(echo d; echo n; echo p; echo ""; echo ""; echo ""; echo w) | sudo fdisk /dev/sda`
  * `sudo reboot`
  * `sudo xfs_growfs /dev/sda1`
  * Lastly, run `df -h` to confirm that the disk size has been extended.

## Installing MOSIP
1. SSH to the console VM: `ssh vagrant@console.sb`
2. Install Git: `sudo yum install git -y`
3. Clone this repo into the console VM server by running: `git clone https://github.com/cylab-africa/mosip-onprem-deployment-guides.git` 
4. cd to the repo: `cd mosip-onprem-deployment-guides`
5. Check the `1.2.0` branch by runnign: `git checkout 1.2.0`
6. Version 1.2.0.1 of MOSIP Sandbox-v2 does not work well with self-signed certiicates. 
   * Therefore, you should obtain a publicly accessible domain name from any provider of your choice and specify this domain name in the `group_vars/all.yml` file under `sandbox_domain_name: your-domain-name`.
   * After the above, you should create a DNS A record pointing the domain name to the public IP Address of MOSIP's Console VM.
7. Run `bash ./install_mosip.sh` to install MOSIP on the above created VMS.