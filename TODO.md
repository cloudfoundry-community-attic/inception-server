## CLI

* integration test - AWS - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* integration test - OpenStack - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* observe InstanceServer#create stages and run save_settings! after each one (idempotence)
* observe InstanceServer#create stages and display STDOUT as it goes along
* interactive delete

## Cookbooks

* echo "export TMPDIR=/var/vcap/store/tmp" >> /home/#{node.user.username}/.bashrc
* echo "export EDITOR=vim" >> /home/#{node.user.username}/.bashrc
* move bosh-micro & bosh-cf installation into separate cookbooks
* place ~ubuntu/.fog for the selected provider credentials
* stuff that will go onto AMI must be installed into root volume, not /var/vcap/store
* where does btrfs need to be installed? should /var/vcap/store be btrfs instead of ext4?


## AMIs

* export an AMI in us-east-1
* copy the AMI to other regions
* use the AMIs instead of 13.04 base AMIs
