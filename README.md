# Mosip Sandbox-v2 1.2.0-rc1 On Prem Deployment
The following instructions walk you through setps for installing MOSIP sandbox-v2 1.2.0-rc1 on an on-premise private infrastructure.

## Infrastructure Set-up
This set up uses `Ubuntu Desktop 20.0.4` as the host OS hosted on a baremetal  server.

1. Download and install the latest version of virtualbox from: https://www.virtualbox.org/ . sYou can also use other hypervisors of your choice such as VMWARE, Hyper-V, etc. However, these instructions were tested against the Virtualbox hypervisor. The specs of this baremetal server are: `2TB SSD storage, 36 CPU Cores, and 128GB of RAM`.
2. Clone this repo: https://github.com/cylab-africa/mosip-1.1.5-on-prem-deployment.git into your host server by running: `git clone https://github.com/cylab-africa/mosip-onprem-deployment-guides.git` 
3. cd to the repo: `cd mosip-onprem-deployment-guides`
4. Checkout the `1.2.0-rc1` branch by running: `git checkout 1.2.0-rc1`
5.  After the above, run `bash ./infrastructure_set_up.sh` to setup the MOSIP VMs. This script creates the following VMs where MOSIP will be instaled. Make sure you have SSH keys generated on your host server in the following locations: `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` These keys are used by infra set up script.
   
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
3. Clone this repo: https://github.com/cylab-africa/mosip-onprem-deployment-guides.git into the console VM server by running: `git clone https://github.com/cylab-africa/mosip-onprem-deployment-guides.git` 
4. cd to the repo: `cd mosip-onprem-deployment-guides`
5. Check the `1.2.0-rc1` branch by runnign: `git checkout 1.2.0-rc1`
6. Run `bash ./install_mosip.sh` to install MOSIP on the above created VMS.


### Registering biometric devices for registration

#### API to Create a Device Specification
`POST https://{{base_url}}/v1/masterdata/devicespecifications`
```
{
  "id": "string",
  "metadata": {},
  "request": {
    "brand": "Logitech C930E",
    "description": "Logitech C930E",
    "deviceTypeCode": "CMR",
    "id": "101",
    "isActive": true,
    "langCode": "eng",
    "minDriverversion": "10",
    "model": "C930E",
    "name": "Logitech C930E"
  },
  "requesttime": "2022-03-20T14:12:41.631Z",
  "version": "string"
}
```

```
{
    "id": "string",
    "version": "string",
    "responsetime": "2022-03-21T08:22:38.861Z",
    "metadata": null,
    "response": {
        "id": "2a4bb2d9-3b89-4e3f-8491-859f35148622",
        "langCode": "eng"
    },
    "errors": null
}
```

#### API to Create a Device

`POST https://{{base_url}}/v1/masterdata/devices`
```
{
  "id": "string",
  "metadata": {},
  "request": {
    "deviceSpecId": "2a4bb2d9-3b89-4e3f-8491-859f35148622",
    "id": "2a4bb2d9-3b89-4e3f-8491-859f35148622",
    "ipAddress": "192.168.1.250",
    "isActive": true,
    "langCode": "eng",
    "macAddress": "00-00-00-00",
    "name": "Logitech C930E",
    "regCenterId": "10002",
    "serialNum": "2115AP049UK8",
    "validityDateTime": "2022-03-20T14:22:50.092Z",
    "zoneCode": "NTH"
  },
  "requesttime": "2022-03-20T14:22:50.092Z",
  "version": "string"
}
```

```
{
    "id": "string",
    "version": "string",
    "responsetime": "2022-03-21T08:26:15.757Z",
    "metadata": null,
    "response": {
        "isActive": false,
        "createdBy": "110140",
        "createdDateTime": "2022-03-21T08:26:15.899Z",
        "updatedBy": null,
        "updatedDateTime": null,
        "isDeleted": null,
        "deletedDateTime": null,
        "id": "fa58db2f-1477-40b8-a282-54c8176e6f31",
        "name": "Logitech C930E",
        "serialNum": "2115AP049UK8",
        "deviceSpecId": "2a4bb2d9-3b89-4e3f-8491-859f35148622",
        "macAddress": "00-00-00-00",
        "ipAddress": "192.168.1.250",
        "langCode": "eng",
        "validityDateTime": "2022-03-20T14:22:50.092Z",
        "zoneCode": "NTH",
        "regCenterId": "10002"
    },
    "errors": null
}
```

### Adding Policy Group

```
Endpoint does not exist - We used an existing policy group
```

### Registering Device Provider
`POST https://{{base_url}}/v1/partnermanager/partners`

```
{
  "id": "string",
  "metadata": {},
  "request": {
    "address": "Kigali",
    "contactNumber": "9876543210",
    "emailId": "test@mosip.io",
    "organizationName": "Logitech",
    "partnerId": "Logitech",
    "partnerType": "Device_Provider",
    "policyGroup": "mmpolicygroup-default-mockdevice"
  },
  "requesttime": "2020-10-23T07:30:27.674Z",
  "version": "string"
}
```

```
{
    "id": "string",
    "version": "string",
    "responsetime": "2022-03-21T09:08:16.933Z",
    "metadata": null,
    "response": {
        "partnerId": "Logitech",
        "status": "InProgress"
    },
    "errors": []
}
```

#### Add Device Details
`POST https://{{base_url}}/v1/partnermanager/devicedetail` 

Request
```
{
    "request": {
        "deviceProviderId": "DP2",
        "deviceSubTypeCode": "Full face",
        "deviceTypeCode": "Face",
        "id": "LG_Face",
        "isItForRegistrationDevice": false,
        "make": "Logitech",
        "model": "C930E",
        "partnerOrganizationName": "DP2"
    },
    "metadata": "",
    "requesttime": "2022-03-21T07:10:57.208Z",
    "id": "String",
    "version": "1.0"
}
```

Response
```
{
    "id": null,
    "version": null,
    "responsetime": "2022-03-22T15:30:59.002Z",
    "metadata": null,
    "response": {
        "id": "LG_Face"
    },
    "errors": []
}
```

#### SBI
`POST https://{{base_url}}/v1/partnermanager/securebiometricinterface`

Request
```
{
    "request": {
        "deviceDetailId": "LG_Face",
        "isItForRegistrationDevice": false,
        "swBinaryHash": "1",
        "swCreateDateTime": "2021-12-21T18:26:02.275Z",
        "swExpiryDateTime": "2022-11-23T15:09:57.866Z",
        "swVersion": "0.9.5.1.1"
    },
    "metadata": "",
    "requesttime": "2022-03-21T05:36:19.276Z",
    "id": "String",
    "version": "1.0"
}
```

Response 
```
{
    "id": null,
    "version": null,
    "responsetime": "2022-03-22T16:10:06.388Z",
    "metadata": null,
    "response": {
        "id": "94042863-a6cb-40c1-a368-eed9c20f78b7"
    },
    "errors": []
}
```

### SBI Approval
`PATCH https://{{base_url}}/v1/partnermanager/securebiometricinterface`

Request
```
{
    "request": {
        "approvalStatus": "Activate",
        "id": "94042863-a6cb-40c1-a368-eed9c20f78b7",
        "isItForRegistrationDevice": false
    },
    "metadata": "",
    "requesttime": "2022-03-21T05:36:20.659Z",
    "id": "String",
    "version": "1.0"
}
```

Response
```
{
    "id": null,
    "version": null,
    "responsetime": "2022-03-22T16:13:30.575Z",
    "metadata": null,
    "response": "Secure biometric details approved successfully.",
    "errors": []
}
```