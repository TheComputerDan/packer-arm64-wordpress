# WordPress Vagrant Box Pipeline for ARM

## Prerequisites

- MacOS (arm)
  - Rosetta2
- [Packer](https://www.packer.io/downloads)
- [Vagrant](https://www.vagrantup.com/downloads)
- [VMware Fusion](https://www.vmware.com/products/fusion/fusion-evaluation.html)
- [Homebrew](https://brew.sh/)
- GNU Make
- [Devbox](https://www.jetpack.io/devbox) (optional): Can be used to install Packer & Vagrant in isolated environment

## Required Vagrant Plugins

- `vagrant-vmware-desktop` --> via Vagrent Plugins
- `vagrant-vmware-utility` --> via Homebrew Cask
  - Requires Rosetta

**To install Rosetta:**

```shell
/usr/sbin/softwareupdate --install-rosetta --agree-to-license
```

## Automatic (Make) Method

### Crate Image

```shell
make image
```

### Add Image to Vagrant

```shell
make vagrant-add 
```

## Manual Method

### Packer Commands

Initialize the Packer project:

```shell
packer init wordpress
```

Build the image and Box wuth Packer:

```shell
packer build wordpress
```

### Vagrant Commands

Add the Vagrant Box using the `packer_wordpress_vmware_arm64.box` that is a result of the Packer build.

```shell
vagrant box add DoctorDan/Wordpress packer_wordpress_vmware_arm64.box
```

(optional) If a Vagrantfile doesn't already exist use vagrant init to create one:

```shell
vagrnat init DoctorDan/Wordpress
```

Start up the Vagrant Box:

```shell
vagrant up
```



### Example Vagrant File

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "DoctorDan/Wordpress"
  config.ssh.insert_key = false
  config.ssh.password = "vagrant"
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
end
```
