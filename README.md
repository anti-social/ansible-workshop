# Ansible Workshop

## Prepare base virtual machine

### Install needed software

- Ubuntu

  ```bash
  sudo apt-get install --no-install-recommends qemu qemu-kvm libvirt-daemon-system libvirt-clients libguestfs-tools cloud-image-utils cloud-guest-utils virt-manager
  ```

- Arch Linux
  ```bash
  sudo pacman -S qemu libvirt libguestfs cloud-image-utils cloud-guest-utils virt-manager 
  
  # Also you need one package from AUR
  # Install it using one of aur tool or manually via makepkg
  sudo aura -A guestfs-tools
  ```

### Ensure that your user has read/write access to /dev/kvm

``` bash
sudo usermod -a -G $(stat -c '%G' /dev/kvm) $(id -n -u)
```

Adding user to a group will take effect next login.

### If you want to access you VMs via names you should set up nsswitch

Install corresponding package:

- Ubuntu

  ``` bash
  sudo apt-get install --no-install-recommends libnss-libvirt
  ```

- Arch Linux

  It is already there

Then edit your `/etc/nsswitch.conf`. You should add `libvirt` word into `hosts:` line like in following example:

```
hosts: libvirt mymachines resolve [!UNAVAIL=return] files myhostname dns
```

Or just execute a command:

``` bash
sudo sed -i 's/hosts: /hosts: libvirt /g' /etc/nsswitch.conf
```

### Check your host system to find possible problems

``` bash
virt-host-validate
```

### Start and enable libvirt daemon

``` bash
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

### Create images directory

```bash
mkdir images
cd images
```

### Download and make initial setup of some images

- Ubuntu
  
  ```bash
  ../scripts/prepare-ubuntu-image.sh
  ```

- Fedora

  ```bash
  ../scripts/prepare-fedora-image.sh
  ```

### And finally create a virtual machines

- Ubuntu
  ```bash
  ../scripts/create-vm.sh ubuntu u-01 10G
  ```

- Fedora

  ```bash
  ../scripts/create-vm.sh fedora f-01 10G
  ```
  
If you see following error:

```
error: Failed to create domain from .u-01.xml
error: Cannot access storage file '<pwd>/images/u-01.qcow2' (as uid:975, gid:975): Permission denied
```

Check that your home directory is available for reading of `libvirt-qemu` user. If it is not, you have several options: 

- add `libvirt-qemu` to the main group of your user:

  ```bash
  sudo usermod -a -G $(stat -c '%G' $HOME) libvirt-qemu
  ```

- grant to all users read access to your home directory:
 
  ```bash
  sudo chmod o+rx $HOME
  ```

- either move your images into other directory, for example `/var/lib/libvirt/images`.

### Try to login by ssh

```bash
ssh -l root u-01
```

### To find out ip address of your VM run following command

```bash
sudo virsh net-dhcp-leases default
```

You should see something like following output:

```
Expiry Time           MAC address         Protocol   IP address           Hostname   Client ID or DUID
------------------------------------------------------------------------------------------------------------------------------------------------
 2022-05-04 18:54:12   52:54:00:1d:87:41   ipv4       192.168.122.173/24   u-01       ff:b5:5e:67:ff:00:02:00:00:ab:11:70:fc:bf:3e:f7:72:e2:02`
 2022-05-04 20:22:39   52:54:00:dd:75:2e   ipv4       192.168.122.36/24    f-01       01:52:54:00:dd:75:2e
```

Now you can try to ssh on the VM:

```bash
ssh -l root 192.168.122.173
```

If all is correct you should now be logged into your VM.
