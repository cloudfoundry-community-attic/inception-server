# Change Log for Inception Server

## v0.2.0

* Settings stored in `~/.inception_server` instead of `~/.bosh_inception`
* Using [readwritesettings](https://github.com/drnic/readwritesettings) instead of settingslogic for access/save settings
* install bosh-bootstrap & latest bosh-cloudfoundry --pre (v0.2.1)

Fixes:

* Fixed running `deploy` after `delete` by removing `cookbooks.prepared` setting
* Do not destroy local ~/.gitconfig when running tests

## v0.1.0

* Initial release to mailing list
* Extracted from bosh-bootstrap v0.10.2
* Settings stored in `~/.bosh_inception`
* Chef cookbook `bosh_inception` replacing old bosh-bootstrap shell scripts
* Using [cyoi](https://github.com/drnic/cyoi) to prompt for infrastructure/provider credentials
