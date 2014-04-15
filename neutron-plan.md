
The following method comes from bosh-bootstrap to provision an address or select a subnet & choose an address from the subnet.

``` ruby
  # public_ip or ip/network/gateway
  def select_or_provision_public_networking
    address = Cyoi::Cli::Address.new([settings_dir])
    address.execute!
    reload_settings!

    # TODO why passing provider_client rather than a Cyoi::Cli::Network object?
    network = Bosh::Bootstrap::Network.new(settings.provider.name, provider_client)
    network.deploy
  end
```

Also in bosh-bootstrap:

* `Bosh::Bootstrap::Network`
* `Bosh::Bootstrap::NetworkProviders` & provider specific classes
* corresponding specs


Currently, inception-server `cli.rb` `prepare_deploy_settings` method performs `provision_or_reuse_public_ip_address_for_inception`:

``` ruby
provision_or_reuse_public_ip_address_for_inception unless settings.exists?("inception.provisioned.ip_address")
```

The method `provision_or_reuse_public_ip_address_for_inception` is a mixin module method in `PrepareDeploySettings`.

Replace `provision_or_reuse_public_ip_address_for_inception` with the Network/NetworkProviders classes from Bosh Bootstrap.

## Questions

What are `Inception::Providers` for? Should they be removed and use Cyoi instead?

They also have the bootstrap script, which is specific to inception-server.

Also include creating key pairs; which could be done via Cyoi?



## Actions

1. remove all the existing tests for security groups
1. copy across `Bosh::Bootstrap::Network` & specs & change namespace
1. copy across `Bosh::Bootstrap::NetworkProviders` & provider specific classes; copy specs; change namespaces
1. change ports to open to [22] only

Then?

1. add a `select_or_provision_public_networking` method?
