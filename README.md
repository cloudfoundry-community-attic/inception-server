# Bosh Inception

Create an Inception VM for Bosh.

Includes a CLI for creating and preparing an Inception VM for deploying/developing a Bosh universe. The created or targeted VM is upgraded into an Inception VM via a Chef cookbook.

## Installation

This tool is distributed as a RubyGem. It requires Ruby 1.9+.

    $ gem install bosh-inception

## Usage

TODO: Write usage instructions here

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
