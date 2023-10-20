packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

locals {
  data_source_command = var.common_data_source == "http" ? "ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/" : "ds=nocloud;seedfrom=/cidata/"
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/http/meta-data")
    "/user-data" = file("${abspath(path.root)}/http/user-data")
  }
}

source "vmware-iso" "wordpress" {
  display_name = "wordpress"
  vm_name      = "wordpress"
  iso_url = var.iso_url
  iso_checksum = var.iso_checksum

  http_directory = "${abspath(path.root)}/http"
  // cd_content   = var.common_data_source == "disk" ? local.data_source_content : null
  // cd_files = [
  //   "${abspath(path.root)}/http/meta-data",
  //   "${abspath(path.root)}/http/user-data"
  // ]
  cd_label = "cidata"

  version       = 20
  guest_os_type = "arm-ubuntu-64"
  headless      = false

  memory = 4096
  cpus   = 2
  cores  = 2

  cdrom_adapter_type   = "sata"
  disk_adapter_type    = "nvme"
  
  disk_size         = 20 * 1024
  disk_type_id      = "0"
  skip_compaction   = true
  
  network_adapter_type = "VMXNET3"

  boot_command         = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ${local.data_source_command} --- ",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>",
    "<wait300>"
  ]

  boot_wait         = "3s"
  boot_key_interval = "5ms"
  

  communicator = "ssh"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "20m"

  shutdown_command = "sudo shutdown -h now"

  vmx_data = {
    "bios.bootDelay"                 = "0500"
    "firmware"                       = "efi"
    "powerType.powerOff"             = "hard"
    "powerType.powerOn"              = "hard"
    "powerType.reset"                = "hard"
    "powerType.suspend"              = "hard"
    "time.synchronize.continue"      = "1"
    "time.synchronize.restore"       = "1"
    "time.synchronize.resume.disk"   = "1"
    "time.synchronize.resume.host"   = "1"
    "time.synchronize.shrink"        = "1"
    "time.synchronize.tools.enable"  = "1"
    "time.synchronize.tools.startup" = "1"
    "tools.upgrade.policy"           = "manual"
    "uefi.secureBoot.enabled"        = "FALSE"
    "vhv.enable"                     = "FALSE"
    "virtualhw.productcompatibility" = "hosted"
    "vmx.allowNested"                = "FALSE"
    "vmx.buildType"                  = "release"
    "usb_xhci:4.deviceType"          = "hid"
    "usb_xhci:4.parent"              = "-1"
    "usb_xhci:4.port"                = "4"
    "usb_xhci:4.present"             = "TRUE"
    "usb_xhci:6.deviceType"          = "hub"
    "usb_xhci:6.parent"              = "-1"
    "usb_xhci:6.port"                = "6"
    "usb_xhci:6.present"             = "TRUE"
    "usb_xhci:6.speed"               = "2"
    "usb_xhci:7.deviceType"          = "hub"
    "usb_xhci:7.parent"              = "-1"
    "usb_xhci:7.port"                = "7"
    "usb_xhci:7.present"             = "TRUE"
    "usb_xhci:7.speed"               = "4"
    "usb_xhci.pciSlotNumber"         = "192"
    "usb_xhci.present"               = "TRUE"
    "ehci.present"                   = "FALSE"
  }
  
  vmx_data_post = {
    "bios.bootDelay"         = "0000"
  // //   # remove optical drives
    "sata0:0.autodetect"     = "TRUE"
    "sata0:0.deviceType"     = "cdrom-raw"
    "sata0:0.fileName"       = "auto detect"
    "sata0:0.startConnected" = "FALSE"
    "sata0:0.present"        = "TRUE"
  }
}

build {
  sources = ["sources.vmware-iso.wordpress"]
  provisioner "file" {
    source = "${abspath(path.root)}/conf/wordpress.conf"
    destination = "/tmp/wordpress.conf"
  }

  provisioner "file" {
    source = "${abspath(path.root)}/conf/wp-config.php"
    destination = "/tmp/wp-config.php"
  }
  
  provisioner "file" {
    source = "${abspath(path.root)}/conf/wordpress.sql"
    destination = "/tmp/wordpress.sql"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/wordpress.conf /etc/apache2/sites-available/wordpress.conf",
      "sudo cp /tmp/wp-config.php /etc/wordpress/wp-config.php",
      "sudo cp /tmp/wp-config.php /etc/wordpress/config-default.php",
      "sudo a2ensite wordpress",
      "sudo systemctl reload apache2.service",
      "cat /tmp/wordpress.sql | sudo mysql --defaults-extra-file=/etc/mysql/debian.cnf"
    ]
  }
}

