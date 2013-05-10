# Cookbook for inception

Chef cookbook to convert a VM into an inception server to deploy/develop Bosh and bosh releases.

## Development

To clone the repo containing this cookbook and run the cookbook tests:

```
git clone git@github.com:drnic/inception.git
cd inception
bundle
kitchen test virtualbox
kitchen test vmware # if you have the plugin installed
```
