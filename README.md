# Ansible Workshop

## Prepare base virtual machine

Install needed software:

```bash
apt-get install virt-manager cloud-image-utils
```

Create images directory:

```bash
mkdir images
cd images
```

Download and make initial setup of some images:

- Ubuntu
  
  ```bash
  ../scripts/prepare-ubuntu-image.sh
  ```

- Fedora

  ```bash
  ../scripts/prepare-fedora-image.sh
  ```
  
Create a virtual machine:

```bash
cp my-ubuntu-jammy.qcow2 vm-01.qcow2
sudo virt-install --name vm-01 --os-variant ubuntu20.04 --import --ram 1024 --vcpus 2 --disk vm-01.qcow2
```

```bash
cp my-fedora-35.qcow2 vm-02.qcow2
sudo virt-install --name vm-02 --os-variant fedora35 --import --ram 1024 --vcpus 2 --disk vm-02.qcow2
```

To find out ip address of your VM run following command:

```bash
sudo virsh net-dhcp-leases default
```

You should see something like following output:

```
Expiry Time           MAC address         Protocol   IP address           Hostname   Client ID or DUID
------------------------------------------------------------------------------------------------------------------------------------------------
 2022-05-04 18:54:12   52:54:00:1d:87:41   ipv4       192.168.122.173/24   ubuntu     ff:b5:5e:67:ff:00:02:00:00:ab:11:70:fc:bf:3e:f7:72:e2:02`
 2022-05-04 20:22:39   52:54:00:dd:75:2e   ipv4       192.168.122.36/24    -          01:52:54:00:dd:75:2e
```

Now you can try to ssh on the VM:

```bash
ssh -l root 192.168.122.173
```

If all is correct you should now be logged into your VM.
