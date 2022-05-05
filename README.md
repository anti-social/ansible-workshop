# Ansible Workshop

## Prepare base virtual machine

Create images directory:

```bash
mkdir images
cd images
```

Download and make initial setup of some images:

```bash
SSH_PUB_KEY_FILE=id_ed25519.pub
# if you use rsa key
# SSH_PUB_KEY_FILE=id_rsa.pub
```

- Ubuntu
  
  ```bash
  wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
  
  BASE_UBUNTU_IMAGE=my-ubuntu-jammy.qcow2
  qemu-img create $BASE_UBUNTU_IMAGE 10G
  virt-resize --format=qcow2 --expand /dev/sda1 jammy-server-cloudimg-amd64.img $BASE_UBUNTU_IMAGE

  virt-customize -a $BASE_UBUNTU_IMAGE --ssh-inject root:file:$HOME/.ssh/$SSH_PUB_KEY_FILE
  guestfish -i -a $BASE_UBUNTU_IMAGE \
    copy-in ../99-config.yaml /etc/netplan/ : \
    chown 0 0 /etc/netplan/99-config.yaml : \
    copy-in ../regenerate-ssh-host-keys.service /etc/systemd/system/ : \
    chown 0 0 /etc/systemd/system/regenerate-ssh-host-keys.service : \
    ln-sf /etc/systemd/system/regenerate-ssh-host-keys.service /etc/systemd/system/multi-user.target.wants/regenerate-ssh-host-keys.service
  ```

- Fedora

  ```bash
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/35/Cloud/x86_64/images/Fedora-Cloud-Base-35-1.2.x86_64.qcow2
  
  virt-customize -a Fedora-Cloud-Base-35-1.2.x86_64.qcow2 --ssh-inject root:file:$HOME/.ssh/$SSH_PUB_KEY_FILE --selinux-relabel
  ```
  
Create a virtual machine:

```bash
cp $BASE_UBUNTU_IMAGE vm-01.qcow2
sudo virt-install --name vm-01 --import --ram 1024 --vcpus 2 --disk vm-01.qcow2
```

```bash
cp Fedora-Cloud-Base-35-1.2.x86_64.qcow2 vm-02.qcow2
sudo virt-install --name vm-02 --import --ram 1024 --vcpus 2 --disk vm-02.qcow2
```

To find out ip address of your VM run following command:

```bash
sudo virsh net-dhcp-leases default
```

You should see something like following output:

```
Expiry Time           MAC address         Protocol   IP address           Hostname   Client ID or DUID
------------------------------------------------------------------------------------------------------------------------------------------------
 2022-05-04 18:54:12   52:54:00:1d:87:41   ipv4       192.168.122.50/24    ubuntu     ff:b5:5e:67:ff:00:02:00:00:ab:11:70:fc:bf:3e:f7:72:e2:02`
 2022-05-04 20:22:39   52:54:00:dd:75:2e   ipv4       192.168.122.36/24    -          01:52:54:00:dd:75:2e
```

Now you can try to ssh on the VM:

```bash
ssh -l root 192.168.122.50
```

If all is correct you should now be logged into your VM.
