## CLI

* create CLI action stubs
* setup unit tests & integration tests
* integration test - create VM, use busser (?) to run remote SSH bats tests, destroy VM
* port bosh-bootstrap helpers across
* CLI create
* CLI update

## Cookbooks

* echo "export TMPDIR=/var/vcap/store/tmp" >> /home/vcap/.bashrc
* echo "export EDITOR=vim" >> /home/vcap/.bashrc
* mount/remount /var/vcap/store volume (other volumes mentioned in `node`)
* remount volumes on reboot
* convert TODO.rb ideas
* move bosh-micro & bosh-cf installation into separate cookbooks
* move hub into separate cookbooks