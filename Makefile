image-init:
	packer init wordpress

image-build:
	packer build wordpress

image: image-init image-build

vagrant-add:
	vagrant box add --name DoctorDan/Wordpress packer_wordpress_vmware_arm64.box --force

vagrant-init:
	@if [ -e Vagrantfile ]; then echo "Vagrantfile exists skipping..."; fi
	@if [ ! -e Vagrantfile ]; then vagrant init DoctorDan/Wordpress; fi

vagrant: vagrant-add vagrant-init

up:
	vagrant up

destroy: 
	vagrant destroy -f

clean:
	rm -rf output-wordpress
	rm packer_wordpress_vmware_arm64.box
	vagrant box remove DoctorDan/Wordpress

