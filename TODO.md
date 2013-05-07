## CLI

* integration test - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* port bosh-bootstrap helpers across

## Cookbooks

* get `~ubuntu/.ssh/authorized_keys` and add to `~vcap/.ssh/authorized_keys`
* echo "export TMPDIR=/var/vcap/store/tmp" >> /home/vcap/.bashrc
* echo "export EDITOR=vim" >> /home/vcap/.bashrc
* remount volumes on reboot
* move bosh-micro & bosh-cf installation into separate cookbooks
* move hub into separate cookbooks