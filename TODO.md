## CLI

* integration test - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* observe InstanceServer#create stages and run save_settings! after each one (idempotence)
* observe InstanceServer#create stages and display STDOUT as it goes along

## Cookbooks

* get `~ubuntu/.ssh/authorized_keys` and add to `~vcap/.ssh/authorized_keys`
* echo "export TMPDIR=/var/vcap/store/tmp" >> /home/vcap/.bashrc
* echo "export EDITOR=vim" >> /home/vcap/.bashrc
* remount volumes on reboot
* move bosh-micro & bosh-cf installation into separate cookbooks
* move hub into separate cookbooks