# Bosh Inception

Create an inception server for Bosh.

Includes a CLI for creating and preparing an inception server for deploying/developing a Bosh universe. The created or targeted VM is upgraded into an inception server via a Chef cookbook.

[![Build Status](https://travis-ci.org/drnic/bosh-inception.png?branch=master)](https://travis-ci.org/drnic/bosh-inception)
[![Code Climate](https://codeclimate.com/github/drnic/bosh-inception.png)](https://codeclimate.com/github/drnic/bosh-inception)

## Installation

Currently, install and use the tool via this Git repo (due to its dependency on other unreleased RubyGems).

```
git clone https://github.com/drnic/bosh-inception.git
cd bosh-inception
bundle
bundle exec bin/bosh-inception deploy
```

Waiting on the following projects to ship a new gem:

* https://github.com/matschaffer/knife-solo/issues/243

In future, this tool will be distributed as a RubyGem. It requires Ruby 1.9+.

```
gem install bosh-inception
```

## Usage

This project includes both a standalone CLI to create an inception server or transform an existing VM into an inception server; and the internal Chef cookbooks that can be used outside of the CLI.

### CLI usage - create a remote inception server

To create a remote inception server, normally in the IaaS/region that you will be working with BOSH:

```
$ bosh-inception deploy
✗ bundle exec bin/bosh-inception delete -n

Deleting inception server, volumes and releasing IP address

Server already destroyed
Volume already destroyed
Deleting key pair 'inception'
Releasing IP address 54.245.246.122
➜  bosh-inception git:(master) ✗ rm ~/.bosh_inception/settings.yml
➜  bosh-inception git:(master) ✗ bundle exec bin/bosh-inception deploy   

Found infrastructure API credentials at ~/.fog (override with $FOG)
1. AWS (default)
2. AWS (starkandwayne)
3. Alternate credentials
Choose infrastructure:  3

1. AWS
2. OpenStack
Choose infrastructure:  1


Using provider aws:

1. *US East (Northern Virginia) Region (us-east-1)
2. US West (Oregon) Region (us-west-2)
3. US West (Northern California) Region (us-west-1)
4. EU (Ireland) Region (eu-west-1)
5. Asia Pacific (Singapore) Region (ap-southeast-1)
6. Asia Pacific (Sydney) Region (ap-southeast-2)
7. Asia Pacific (Tokyo) Region (ap-northeast-1)
8. South America (Sao Paulo) Region (sa-east-1)
Choose AWS region: 2

Access key: KEYGOESHERE
Secret key: SECRETGOESHERE

Confirming: Using aws/us-west-2

Preparing deployment settings

Using your git user.name (Dr Nic Williams)
Acquiring a public IP address... 54.245.246.122

Provision inception server


... lots of chef output...

```

### CLI usage - upgrade existing remote inception server

You can upgrade your remote inception server at any time by re-running the `deploy` command.

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
