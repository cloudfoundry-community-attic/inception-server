## CLI

* delete action
* integration test - AWS - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* integration test - OpenStack - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* observe InstanceServer#create stages and run save_settings! after each one (idempotence)
* observe InstanceServer#create stages and display STDOUT as it goes along

## Cookbooks

* echo "export TMPDIR=/var/vcap/store/tmp" >> /home/vcap/.bashrc
* echo "export EDITOR=vim" >> /home/vcap/.bashrc
* move bosh-micro & bosh-cf installation into separate cookbooks
* move hub into separate cookbooks
* place ~ubuntu/.fog for the selected provider credentials