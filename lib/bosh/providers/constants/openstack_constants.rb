# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Bosh; module Providers; module Constants; end; end; end

module Bosh::Providers::Constants::OpenStackConstants
  extend self

  # explicit value representing "no region requested"
  def no_region_code
    "no-region-requested"
  end
end
