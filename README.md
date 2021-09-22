**MOSIP Sandbox-v2 1.1.2 On-Premise Detailed Deployment Guide**
**by: CyLab-Africa**

Table of Contents  
- [Introduction](#introduction)
- [Note:](#note)
- [1. Hardware Setup](#1-hardware-setup)
- [2. Setting up the machine environments for MOSIP](#2-setting-up-the-machine-environments-for-mosip)
- [3.Give the `mosipuser` user ssh permissions as root to all other machines](#3give-the-mosipuser-user-ssh-permissions-as-root-to-all-other-machines)
- [4. Disable the firewall and set time to UTC on all machines](#4-disable-the-firewall-and-set-time-to-utc-on-all-machines)
- [5. Installing dependencies and downloading the MOSIP repo](#5-installing-dependencies-and-downloading-the-mosip-repo)
- [6. Configuring and Installing MOSIP](#6-configuring-and-installing-mosip)
- [7. Email Configuration](#7-email-configuration)
  - [7.1 References](#71-references)
  - [7.2 Configuration files to be Edited](#72-configuration-files-to-be-edited)
  - [7.3 Configuration Steps](#73-configuration-steps)
  - [7.4 Troubleshooting Tips](#74-troubleshooting-tips)
- [8. Ansible vault](#8-ansible-vault)
- [9. Windows Registration Client + Mock MDS Setup](#9-windows-registration-client--mock-mds-setup)
  - [9.1 Windows Registration Client Set Up](#91-windows-registration-client-set-up)
  - [9.2 Mock-MDS Set Up](#92-mock-mds-set-up)
- [10. Appendix](#10-appendix)
  - [Installation Errors](#installation-errors)
  - [Error 1](#error-1)
    - [Output](#output)
    - [Fix](#fix)
    - [Resources Used](#resources-used)
  - [Error2](#error2)
    - [Output](#output-1)
    - [Fix](#fix-1)
  - [Error 3](#error-3)
    - [Output](#output-2)
    - [Fix](#fix-2)
  - [Error 4](#error-4)
    - [Output](#output-3)
    - [Fix](#fix-3)
  - [Error 5](#error-5)
    - [Fix](#fix-4)
  - [Usage Errors](#usage-errors)
  - [Error 1](#error-1-1)
    - [Fix](#fix-5)
  - [Error 2](#error-2)
    - [Output 'Failed: No Internet Connection' on Windows Reg-lient](#output-failed-no-internet-connection-on-windows-reg-lient)
    - [Fix:](#fix-6)
  - [Error 3](#error-3-1)
    - [Output:](#output-4)


## Introduction
This guide is based on the official MOSIP deployment [https://github.com/mosip/mosip-infra/tree/1.1.2/deployment/sandbox-v2] instructions and adapted from this [https://github.com/fretbuzz/MOSIP-Setup-Instructions/blob/main/MOSIP%20Deployment%20Guide.pdf] and this [https://github.com/luker983/MOSIP-Setup-Instructions/tree/1.1.2] cloudlab deployment guides. We recommend that you skim through the official guide to gain context before following this deployment guide.

## Note:
1. This guide assumes that the installation should not be internet-facing and that it can only be accessed over VPN or the internal network.
2. It also assumes that self-signed SSL/TLS certificates will be used.

## 1. Hardware Setup
* Create 7 Virtual Machines (VMs) and install CentOS 7 on all of them. 
    * The VMs should be created with the following compute resources:

| Component       | Number of VMs | Configuration      | Storage     |
| --------------- | ------------- | ------------------ | ----------- |
| Console         | 1             | 4 VCPU*, 16 GB RAM | 128 GB SSD* |
| K8s MZ Master   | 1             | 4 VCPU, 8 GB RAM   | 32 GB SSD   |
| K8s MZ workers  | 3             | 4 VCPU, 16 GB RAM  | 32 GB SSD   |
| K8s DMZ master  | 1             | 4 VCPU, 8 GB RAM   | 32 GB SSD   |
| K8s DMZ workers | 1             | 4 VCPU, 16 GB RAM  | 32 GB SSD   |


*VCPU: Virtual CPU             *SSD: Solid State Drive 

* Assign the following hostnames to your VMs using the command: `sudo hostnamectl set-hostname <hostname>`
    * `console.sb`
    * `mzmaster.sb`
    * `mzworker0.sb`
    * `mzworker1.sb`
    * `mzworker2.sb`
    * `dmzmaster.sb`
    * `dmzworker0.sb`

* Enable Internet connectivity on all machines.

## 2. Setting up the machine environments for MOSIP
* Create a new user on the console machine
    * Connect to the shell of the console machine.
    * Create the `mosipuser` account and set its password
        * `sudo useradd mosipuser`
        * `sudo passwd mosipuser`
    * Add mosipuser to the sudoers
        *  `sudo usermod -aG wheel mosipuser`
    * Open the sudoers file using
        * `sudo visudo`
    * And append these lines to it to give mosipuser unlimited access and prevent applications to prompt for a password
        * `mosipuser ALL=(ALL) ALL`
        * `%mosipuser ALL=(ALL) NOPASSWD:ALL`

## 3.Give the `mosipuser` user ssh permissions as root to all other machines

* Keep running these commands on the console machines:
    * Switch to the mosipuser account using the password you created for it.
        * `su - mosipuser`
* Generate the ssh keys (just tap return three times)
    * `ssh-keygen -t rsa`
* And copy the ssh public key to clipboard manually (ctrl+c; copying using mouse or browser causes issues later on when pasting, so don’t do it! )
    * `cat .ssh/id_rsa.pub`
* Store the ssh keys in the authorized keys of the console VM and the root of all other VMs as shown below:
    * Run this on the console machine and add the copied ssh public key to the file
        *  `nano .ssh/authorized_keys`
    * Then change the permissions
        * `chmod 644 .ssh/authorized_keys`
    * Run this on all other machines and add the copied ssh public key to the file 
        * `sudo nano /root/.ssh/authorized_keys`
* Test if the ssh keys were shared correctly by running the below commands on the console machine.
    * `ssh mosipuser@console`
    * `ssh root@[all other hosts]`

## 4. Disable the firewall and set time to UTC on all machines
* Run the below commands on all machines to disable their firewall
    * `sudo systemctl stop firewalld`
    * `sudo systemctl disable firewalld`
* Set the date and time of the VMs to the correct UTC time
    * `sudo yum install ntp ntpdate -y && sudo systemctl enable ntpd && sudo ntpdate -u -s 0.centos.pool.ntp.org 1.centos.pool.ntp.org 2.centos.pool.ntp.org && sudo systemctl restart ntpd && sudo timedatectl`

## 5. Installing dependencies and downloading the MOSIP repo
* Follow these instructions on the Console VM:
    * Install Git
        * `sudo yum install -y git`
    * Clone the mosip-infra repo and switch to the appropriate branch
        * `cd ~/`
        * `git clone https://github.com/mosip/mosip-infra`
        * `cd mosip-infra`
        * `git checkout 1.1.2`
        * `cd mosip-infra/deployment/sandbox-v2`
    * Change ownership of the cloned repo (if not the owner)
        * `sudo chown -R mosipuser mosip-infra/`
    * Install Ansible and create shortcuts:
        * `./hpreinstall.sh`
        * `source ~/.bashrc`

## 6. Configuring and Installing MOSIP
* Update the `hosts.ini` as per your setup. Make sure the machine names and IP addresses match your setup.
* Follow these instructions on the Console VM
    * Open `group_vars/all.yml` using `nano mosip-infra/deployment/sandbox-v2/group_vars/all.yml` and replace the following values as below:
        * `sandbox_domain_name: '{{inventory_hostname}}'`
        * `site:`
        * `sandbox_public_url: 'https://{{sandbox_domain_name}}'`
        * `ssl:`
        * `ca: 'selfsigned'`   # The ca to be used in this deployment
* Open both of the files below
    * `nano mosip-infra/deployment/sandbox-v2/group_vars/mzcluster.yml`
    * `nano mosip-infra/deployment/sandbox-v2/group_vars/dmzcluster.yml`
    and replace the value of `network_interface` found in both files with `enp0s3`  or the configured network interface on the CentOS VMs.
* Run the ansible scripts that will install MOSIP
    * `cd mosip-infra/deployment/sandbox-v2/`
    * `an site.yml`
* The main MOSIP web interface can be accessed by typing the console VM's hostname into a web browser.
* To access the Pre-Registration UI after the installation is complete, use the below link:
    * `<your console hostname>/pre-registration-ui`
    * To avoid issues with the pre-registration page not loading properly. Make sure you access the page using the domain name of the console VM and not its IP Address. If you do not have a DNS server on your network to translate the console VM domain name to its IP Address, you can add a static DNS mapping of the console machine’s domain name and IP Address on your machine. In Linux/MAC, this mapping can be done in the `/etc/hosts` file. In Windows this can be done in the `C:\Windows\System32\drivers\etc\hosts` file.

* While testing:
    * You can connect to the pre-registration interface using static OTP value: `111111`. To set up random OTPs to be sent to the user's email, see the below email configuration instructions.
    * You can use this fake valid postal code: `14022` when registering on the pre-registration interface.

## 7. Email Configuration
### 7.1 References 
1. OTP Email Settings: https://docs.mosip.io/platform/build-and-deploy/sandbox-installer#otp-setting
2. OTP Notification Services: https://docs.mosip.io/platform/modules/kernel/common-services-functionality#notification

### 7.2 Configuration files to be Edited
1. kernel-mz.properties (Configure email OTP)
    ```
    mosip.kernel.notification.email.from=emailfrom
    spring.mail.host=smtphost
    spring.mail.username=username
    spring.mail.password=password

    ```
2. application-mz.properties (Disable Proxy OTP settings so default OTP is not allowed)

```
    mosip.kernel.sms.proxy-sms=true
    mosip.kernel.auth.proxy-otp=true
    mosip.kernel.auth.proxy-email=true
```

Configuration files are located in: `/srv/nfs/mosip/mosip-config/sandbox/`

### 7.3 Configuration Steps

1. Configure Email SMTP in `kernel-mz.properties`. Current SMTP server running unsecure services at port 587 hence TLS has been disabled

```
[root@console sandbox]# cat kernel-mz.properties | grep spring.mail
spring.mail.host=mail.acelma.com
spring.mail.username=mosip@acelma.com
spring.mail.password=<password>
spring.mail.port=587
spring.mail.properties.mail.transport.protocol=smtp
spring.mail.properties.mail.smtp.starttls.required=false
spring.mail.properties.mail.smtp.starttls.enable=false
spring.mail.properties.mail.smtp.auth=true
spring.mail.debug=false
```

2. Disable Proxy OTP settings

```
[root@console sandbox]# vi application-mz.properties
mosip.kernel.sms.proxy-sms=false
mosip.kernel.auth.proxy-otp=false
mosip.kernel.auth.proxy-email=false
```

3. Commit the changes done in the configuration files for the changes to take effect
   1. checking git status

        ```
        [mosipuser@console ~]$ cd /srv/nfs/mosip/mosip-config
        [mosipuser@console mosip-config]$ git status
        ```

   2. commit config changes

        ```
        [mosipuser@console mosip-config]$ sudo git commit -am "smtp details added"
        ```

4. Restart Kernel Notification and OTP Manager Services

   1. Identify the containers running these services

        ```
        [mosipuser@console ~]$ kc1 get pods -A
        NAMESPACE              NAME                                                        READY   STATUS    RESTARTS   AGE
        default                activemq-5dc5dc7c86-sbdt4                                   1/1     Running   1          32d
        default                admin-service-fbf5996f8-8lhlp                               1/1     Running   0          32d
        default                admin-ui-6bb7f9957f-82pcj                                   1/1     Running   0          32d
        .
        .
        .
        [mosipuser@console ~]$
        ```

    2. Restart the containers/pods, both notification and OTP Manager

        ```
        [mosipuser@console mosip-config]$ kc1 delete pod <name>
        pod "<name>" deleted
        [mosipuser@console mosip-config]$
        ```

5. OTP tests can be done to confirm successful configuration


### 7.4 Troubleshooting Tips
1. Testing connection from Kernel notification service container

    ````
    [mosipuser@console ~]$ kc1 exec -it kernel-notification-service-8465bff54f-t6tjf /bin/bash
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    root@kernel-notification-service-8465bff54f-t6tjf:/# ping mail.acelma.com
    PING acelma.com (209.99.16.30) 56(84) bytes of data.
    64 bytes from md-87.webhostbox.net (209.99.16.30): icmp_seq=1 ttl=43 time=338 ms
    64 bytes from md-87.webhostbox.net (209.99.16.30): icmp_seq=2 ttl=43 time=330 ms
    64 bytes from md-87.webhostbox.net (209.99.16.30): icmp_seq=3 ttl=43 time=334 ms
    64 bytes from md-87.webhostbox.net (209.99.16.30): icmp_seq=4 ttl=44 time=336 ms
    64 bytes from md-87.webhostbox.net (209.99.16.30): icmp_seq=5 ttl=43 time=336 ms
    ^C
    --- acelma.com ping statistics ---
    6 packets transmitted, 5 received, 16.6667% packet loss, time 25ms
    rtt min/avg/max/mdev = 330.233/334.524/337.539/2.581 ms
    root@kernel-notification-service-8465bff54f-t6tjf:/#
    ````

2. Test if telnet to the SMTP Port works fine as well from within Notification container

    ````
    root@kernel-notification-service-8465bff54f-t6tjf:/etc/apt# telnet mail.acelma.com 587
    Trying 209.99.16.30...
    Connected to acelma.com.
    Escape character is '^]'.
    ````

3. Monitor live logs

    ```
    kc1 logs -f <name of container>
    ```

## 8. Ansible vault
* All secrets (passwords) used by the MOSIP installation are stored in Ansible vault file `secrets.yml`. The default password to access the file is `foo`. It is recommended that you change this password with following command:
    `av rekey secrets.yml`
* You may view and edit the contents of secrets.yml:
    * `av view secrets.yml`
    * `av edit secrets.yml`

## 9. Windows Registration Client + Mock MDS Setup
### 9.1 Windows Registration Client Set Up
* Go through the official MOSIP Guide located here: https://docs.mosip.io/platform/modules/registration-client/registration-client-setup to familiarize yourself with the registration client functionality and installation process.
* Make sure you have JAVA 11 is installed on the Windows Machine where you are instllating Reg-Client
* Set `mosip.hostname` environment variable on your machine with the host name of the console VM.
* On the console VM, copy the maven-metadata.xml file from `/home/mosipuser/mosip-infra/deployment/sandbox-v2/roles/reg-client-prep/templates/` to `/usr/share/nginx/html/`
* Login to the console VM and change the configs of the file: `/home/mosipuser/mosip-infra/deployment/sandbox-v2/tmp/registration/registration/registration-libs/src/main/resources/props/mosip-application.properties` to the below configuration:

```
mosip.reg.healthcheck.url=https\://<console VM hostname>/v1/authmanager/actuator/health
mosip.reg.rollback.path=../BackUp
mosip.reg.cerpath=/cer//mosip_cer.cer
mosip.reg.db.key=bW9zaXAxMjM0NQ\=\= # This key might be different on your set up
mosip.reg.xml.file.url=https\://<console VM hostname>/maven-metadata.xml
mosip.reg.app.key=bBQX230Wskq6XpoZ1c+Ep1D+znxfT89NxLQ7P4KFkc4\= # This key might be different on your set up
mosip.reg.client.tpm.availability=N
mosip.reg.env=qa
mosip.reg.dbpath=db/reg
mosip.reg.logpath=../logs
mosip.reg.mdm.server.port=8080
mosip.reg.version=1.1.2-rc2
mosip.reg.packetstorepath=../PacketStore
mosip.reg.client.url=https\://console VM hostname/registration-client/1.1.2/reg-client.zip
```

* Download the client zip file from `https://<your console hostname>/registration-client/1.1.2/reg-client.zip`
* Unzip the downloaded client
* Execute the run.bat file inside the unzipped folder.
* Once the above file is executed, certain keys are generated and stored under this file:  `C:\Users\<Your User Name>\.mosipkeys\readme`
* Copy the machine name, public key, and key index values together with other details about your machine such as MAC Address, Serial Number, and IP address and append them to this file: `/home/mosipuser/mosip-infra/deployment/sandbox-v2/tmp/commons/db_scripts/mosip_master/dml/master-machine_master.csv` located on the MOSIP console VM.
* Create a user and a role on keycloak to be used on the reg-client for on-boarding purposes.
  * Refernce: https://docs.mosip.io/platform/modules/registration-client/first-user-registration-and-onboarding
  * Created the `Default` role on keycloak
  * Creat user `110140`
  * Set the password `mosip` for the user on keycloak.
  * Map the earlier created `Default` role to the user.
  * Also, map the following roles to the user: `registration-processor` , `reg-admin`, and `reg-superviser`
  * On the `Attributes` tab of the user, add the  following attributes:
    * `rid` : `27841452330002620190527095023`
    * `userPassword` : `e1NTSEEyNTZ9NXo3aTlwZ3MvdzBSdTJyeGdRcEM3RkFBOXZsTU1hZHRLbG1SSDIyTldxeDB3ZXV2aXgxWGJRPT0=`
* Go to the console vm and add the created user details to `master-user_detail.csv` and `zone-user` files.
* Then, cd to `/home/mosipuser/mosip-infra/deployment/sandbox-v2/test/regclient` and run the script: `./update_masterdb.sh /home/mosipuser/mosip-infra/deployment/sandbox-v2/tmp/commons/db_scripts/mosip_master` to update the master database
* After doing the above, you can login to the Windows client using the username `110140` and password `mosip`. You will see an application restart prompt. Close the application and rerun the run.bat file and login again with the same username and password.

### 9.2 Mock-MDS Set Up
Reference: https://github.com/mosip/mosip-mock-services/tree/1.1.5/MockMDS

The Mock MOSIP Device service (Mock-MDS) helps in simulating (mock) biometric devices for capturing user biometric details when on-boarding in the event that you do not have access to biometric devices.

* Make sure that you install Apache Maven for building Mock MDS on the windows machine
* To install Mock-MDS, download the `.zip` file from https://github.com/mosip/mosip-mock-services/tree/1.1.5
* Unzip the downloaded folder.
  * `cd` to MockMDS
  * `mvn clean install`
* After running the above, `target` folder is created on successful build. Go to this directory and run `run.bat` file.
* Once this is running, the reg-client is able to detect the Mock-MDS and will be able to capture the mock biometric of users during on-boarding.
  
## 10. Appendix
### Installation Errors

Below are the installation errors encountered when installing of MOSIP Sandbox-v2 1.1.2 whose installation instructions are specified here: https://github.com/mosip/mosip-infra/tree/1.1.2/deployment/sandbox-v2

### Error 1
#### Output
```
TASK [k8scluster/cni : Create flannel network daemonset] ***************************************************************************************************
fatal: [dmzmaster.sb -> 172.29.108.22]: FAILED! => {"changed": true, "cmd": ["kubectl", "apply", "--kubeconfig=/etc/kubernetes/admin.conf", "-f", "/etc/kubernetes/network/"], "delta": "0:00:00.083852", "end": "2021-04-27 13:42:54.099146", "msg": "non-zero return code", "rc": 1, "start": "2021-04-27 13:42:54.015294", "stderr": "The connection to the server 172.29.108.22:6443 was refused - did you specify the right host or port?", "stderr_lines": ["The connection to the server 172.29.108.22:6443 was refused - did you specify the right host or port?"], "stdout": "", "stdout_lines": []}
```
#### Fix
* Run the following commands on `dmzmaster.sb` (or on the node where the error happened). his issue happens when the MOSIP installation script is executed following a cluster reset instruction (an reset.yml). The cluster reset script does not release the k8s port on the node to be used in the subsequent installation.
```
systemctl stop docker && systemctl stop kubelet
kubeadm reset
rm -rf /etc/cni/net.d
rm -rf  $HOME/.kube/config
```

#### Resources Used
https://stackoverflow.com/questions/56737867/the-connection-to-the-server-x-x-x-6443-was-refused-did-you-specify-the-right 

### Error2
#### Output
```
TASK [packages/helm-cli: Add stable repo]
fatal: [console]: FAILED! => {"changed": true, "cmd": "/home/mosipuser/bin/helm repo add stable https://kubernetes-charts.storage.googleapis.com", "delta": "0:00:00.238782", "end": "2021-04-21 09:54:07.660850", "msg": "non-zero return code", "rc": 1, "start": "2021-04-21 09:54:07.422068", "stderr": "Error: looks like \"https://kubernetes-charts.storage.googleapis.com\" is not a valid chart repository or cannot be reached: failed to fetch https://kubernetes-charts.storage.googleapis.com/index.yaml : 403 Forbidden", "stderr_lines": ["Error: looks like \"https://kubernetes-charts.storage.googleapis.com\" is not a valid chart repository or cannot be reached: failed to fetch https://kubernetes-charts.storage.googleapis.com/index.yaml : 403 Forbidden"], "stdout": "", "stdout_lines": []}
```

#### Fix
* Refer to: https://stackoverflow.com/a/65404574/15117449
* In roles/packages/helm-cli/tasks/main.yml, replace the stable repo https://kubernetes-charts.storage.googleapis.com with https://charts.helm.sh/stable

### Error 3
#### Output
```
TASK [packages/crypto : Install python3 cryptography]
fatal: [console]: FAILED! => {"changed": false, "cmd": ["/bin/pip3", "install", "cryptography"], "msg": "stdout: Collecting cryptography\n  Downloading https://files.pythonhosted.org/packages/9b/77/461087a514d2e8ece1c975d8216bc03f7048e6090c5166bc34115afdaa53/cryptography-3.4.7.tar.gz (546kB)\n Complete output from command python setup.py egg_info:\n        	\n    	 =============================DEBUG ASSISTANCE==========================\n          	If you are seeing an error here please try the following to\n               	successfully install cryptography:\n	\n    	        	Upgrade to the latest pip and try again. This will fix errors for most\n                	users. See: https://pip.pypa.io/en/stable/installing/#upgrading-pip\n    	        	=============================DEBUG ASSISTANCE==========================\n \n     	Traceback (most recent call last):\n  	File \"<string>\", line 1, in <module>\n       	File \"/tmp/pip-build-ifd1g9v2/cryptography/setup.py\", line 14, in <module>\n	 from setuptools_rust import RustExtension\n       	ModuleNotFoundError: No module named 'setuptools_rust'\n   	\n     	----------------------------------------\n\n:stderr: WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.\nCommand \"python setup.py egg_info\" failed with error code 1 in /tmp/pip-build-ifd1g9v2/cryptography/\n"}
```
#### Fix
```
pip3 install --upgrade pip
pip3 install cryptography
	.source /home/mosipuser/.venv-py3/bin/activate
	python3 -m pip install setuptools_rust
	pip install --upgrade pip
	python3 -m pip install certbot
	Deactivate
```
### Error 4
#### Output
```
TASK [k8scluster/kubernetes/master : Init Kubernetes cluster]
fatal: [mzmaster]: FAILED! => {"changed": true, "cmd": "kubeadm init --service-cidr 10.96.0.0/12     	   	--kubernetes-version v1.19.0     		--pod-network-cidr 10.244.0.0/16     		--token b0f7b8.8d1767876297d85c     	  	--apiserver-advertise-address 172.17.33.3                  	 \n", "delta": "0:00:00.476187", "end": "2021-04-21 11:09:42.787299", "msg": "non-zero return code", "rc": 1, "start": "2021-04-21 11:09:42.311112", "stderr": "this version of kubeadm only supports deploying clusters with the control plane version >= 1.20.0. Current version: v1.19.0\nTo see the stack trace of this error execute with --v=5 or higher", "stderr_lines": ["this version of kubeadm only supports deploying clusters with the control plane version >= 1.20.0. Current version: v1.19.0", "To see the stack trace of this error execute with --v=5 or higher"], "stdout": "", "stdout_lines": []}
```
#### Fix
* Replace package names with `package-name-1.19.0` in `roles/k8scluster/kubernetes/node/meta/main.yml` and `roles/k8scluster/kubernetes/master/meta/main.yml`, e.g., `kubeadm-1.19.0`, then add `allow_downgrade: true` to the apt section of RHEL/Centos pkg install in `roles/k8scluster/commons/pre-install/tasks/pkg.yml`

### Error 5
The admin helm release fails to deploy.
#### Fix
* The docker image version for the admin playbook is incorrect. Find the relevant docker images in `versions.yml` file, replace `1.1.3` with `1.1.2`

### Usage Errors
### Error 1
Default OTP of 111111 is not valid on the pre-registration-ui as shown below

![alt text](https://user-images.githubusercontent.com/17492419/120472756-92cfa000-c3a6-11eb-857d-d756c0160f95.png)
#### Fix
Make sure all the VM clocks are synchronized and set to the correct UTC date and time.
If the above does not work, Reinstall the Keycloak helm release by running helm1 delete keycloak and then `an playbooks/keycloak.yml`

### Error 2
#### Output 'Failed: No Internet Connection' on Windows Reg-lient
![alt text](https://user-images.githubusercontent.com/17492419/121894774-d075e680-cd1f-11eb-8f9b-84f24b349791.png)

#### Fix:
Generate a new self-signed certificate for nginx and adding `console.sb` as the certificate's `Common Name (CN)`. The reason being, by default, MOSIP uses the server's IP address as the CN when it is generating the self-signed certificate and as mentioned here: https://stackoverflow.com/questions/29157861/java-certificateexception-no-subject-alternative-names-matching-ip-address and here: https://web.archive.org/web/20160201235032/http://www.jroller.com/hasant/entry/no_subject_alternative_names_matching , JAVA has issues with using an IP address as a CN in certificates. Here is a link on how to generate a self-signed certificate for nginx: https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7. This should not be an issue when using a trusted CA-issued certificate since this is issued to the domain name registered under MOSIP and not the IP address.

### Error 3
#### Output: 

'`Failed: Sync Configuration Failure`' on Windows Reg-client
![alt text](https://user-images.githubusercontent.com/17492419/124417869-6c60a400-dd5a-11eb-89ef-290af1d38a29.png)

Thi is related to your machine details not added to the `mosip_master` database. Add your machine details in the `master-machine_master.csv` file and run the `update_masterdb.sh` script to update the details in the database. The reg-client application should restart and you should be able to login with the user `110118` and Password `Techno@123`.




