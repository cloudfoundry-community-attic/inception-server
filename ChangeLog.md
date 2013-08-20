# Change Log for Inception Server

`inception-server` lets you create an inception server - a general purpose server on AWS or OpenStack that is great for deploying/developing/testing bosh and bosh releases

## v0.3.0

* `inception share-ssh` makes it really easy to share access to an inception server. It displays text that can be copied & pasted to any person explaining how to setup local SSH config and a private key.

## v0.2.0

* Settings stored in `~/.inception_server` instead of `~/.bosh_inception`
* Using [readwritesettings](https://github.com/drnic/readwritesettings) instead of settingslogic for access/save settings
* install bosh-bootstrap & latest bosh-cloudfoundry --pre (v0.2.1)
* using bosh-cloudfoundry 0.7.0 (not --pre releases) (v0.2.2)

Fixes:

* Fixed running `deploy` after `delete` by removing `cookbooks.prepared` setting
* Do not destroy local ~/.gitconfig when running tests

## v0.1.0

* Initial release to mailing list
* Extracted from bosh-bootstrap v0.10.2
* Settings stored in `~/.bosh_inception`
* Chef cookbook `bosh_inception` replacing old bosh-bootstrap shell scripts
* Using [cyoi](https://github.com/drnic/cyoi) to prompt for infrastructure/provider credentials
