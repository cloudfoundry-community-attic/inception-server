# Cookbook for bosh-inception

Chef cookbook to convert a VM into an Inception VM to deploy/develop Bosh and bosh releases.

## Development

To clone the repo containing this cookbook and run the cookbook tests:

```
git clone git@github.com:drnic/bosh-inception.git
cd bosh-inception
bundle
kitchen test virtualbox
kitchen test vmware # if you have the plugin installed
```
