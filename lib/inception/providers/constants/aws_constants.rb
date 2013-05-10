# Copyright (c) 2012-2013 Stark & Wayne, LLC

module Inception; module Providers; module Constants; end; end; end

module Inception::Providers::Constants::AwsConstants
  extend self

  # http://docs.aws.amazon.com/general/latest/gr/rande.html#region
  def region_labels
    [
      { label: "US East (Northern Virginia) Region", code: "us-east-1" },
      { label: "US West (Oregon) Region", code: "us-west-2" },
      { label: "US West (Northern California) Region", code: "us-west-1" },
      { label: "EU (Ireland) Region", code: "eu-west-1" },
      { label: "Asia Pacific (Singapore) Region", code: "ap-southeast-1" },
      { label: "Asia Pacific (Sydney) Region", code: "ap-southeast-2" },
      { label: "Asia Pacific (Tokyo) Region", code: "ap-northeast-1" },
      { label: "South America (Sao Paulo) Region", code: "sa-east-1" },
    ]
  end

  def default_region_code
    "us-east-1"
  end
end
