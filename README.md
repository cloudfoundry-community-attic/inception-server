# Bosh Inception

Create an Inception VM for Bosh.

Includes a CLI for creating and preparing an Inception VM for deploying/developing a Bosh universe. The created or targeted VM is upgraded into an Inception VM via a Chef cookbook.

[![Build Status](https://travis-ci.org/drnic/bosh-inception.png?branch=master)](https://travis-ci.org/drnic/bosh-inception)

## Installation

Currently, install and use the tool via this Git repo (due to its dependency on other unreleased RubyGems).

```
git clone https://github.com/drnic/bosh-inception.git
cd bosh-inception
bundle
bundle exec bin/bosh-inception deploy
```

In future, this tool will be distributed as a RubyGem. It requires Ruby 1.9+.

```
gem install bosh-inception
```

## Usage

This project includes both a standalone CLI to create an Inception VM or transform an existing VM into an Inception VM; and the internal Chef cookbooks that can be used outside of the CLI.

### CLI usage - create a remote Inception VM

To create a remote Inception VM, normally in the IaaS/region that you will be working with BOSH:

```
$ bosh-inception deploy

Stage 1: Choose infrastructure

Found infrastructure API credentials at ~/.fog (override with --fog)
1. AWS (default)
2. AWS (bosh)
3. Openstack (default)
Choose infrastructure:  1

Confirming: using AWS infrastructure.

1. ap-northeast-1
2. ap-southeast-1
3. eu-west-1
4. us-east-1
5. us-west-1
6. us-west-2
7. sa-east-1
Choose AWS region:  6
Confirming: Using AWS us-west-2 region.


Stage 2: Networking

Confirming: Inception VM will be named inception-us-west-2

Creating security group "inception"...
Opening port: 22

Confirming: Inception VM will will use security group inception

Creating keypair "drnic-inception"...

Confirming: Inception VM will include keypair drnic-inception

Stage 3: Create/Allocate the Inception VM

creating m1.small...
Confirming: Inception VM has been created

Stage 4: Preparing the Inception VM

Running: knife solo bootstrap...
... lots of chef output...

```

### CLI usage - upgrade existing remote Inception VM

You can upgrade your remote Inception VM at any time by re-running the `deploy` command.

```
$ bosh-inception deploy
... lots of chef output ...
```


### Chef cookbook usage - remote VM

This project includes a `bosh_inception` Chef cookbook.

You can apply the cookbook to a preexisting remote VM using [knife solo](http://matschaffer.github.io/knife-solo/ "knife-solo"):

```
$ bundle
$ bundle exec knife solo bootstrap ubuntu@HOST -r 'bosh_inception'
$ bundle exec knife solo bootstrap ubuntu@HOST -j '{"disk": {"mounted": true, "device": "/dev/xvdf"}}' -r 'bosh_inception'

# for more help information:
$ knife solo bootstrap -h
```

See `cookbooks/bosh_inception/attributes/default.rb` for available JSON overrides.

### Chef cookbook usage - local VM

You can also apply the cookbooks to the local VM (or a remote VM that you've shelled into) using your favourite Chef toolchain.

See `cookbooks/bosh_inception/attributes/default.rb` for available JSON overrides.

## Development

One half of the functionality is in a Chef cookbook `bosh_inception`. To load this cookbook into a Vagrant VM and run a series of integration tests (via `test-kitchen`):

```
$ bundle
$ kitchen test virtualbox
$ kitchen test vmware # if you have vagrant vmware plugin
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
