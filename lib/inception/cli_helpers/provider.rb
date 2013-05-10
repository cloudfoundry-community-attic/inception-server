module Inception::CliHelpers
  module Provider
    def provider_client
      @provider_client ||= begin
        Bosh::Providers.provider_client(settings.provider)
      end
    end

    # If the +provider_client+ uses fog, then this will return its +fog_compute+ client object
    def fog_compute
      provider_client.respond_to?(:fog_compute) ? provider_client.fog_compute : nil
    end
  end
end