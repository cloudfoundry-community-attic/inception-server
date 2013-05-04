require "thor"
require "highline"
require "fileutils"

# for the #sh helper
require "rake"
require "rake/file_utils"

require "escape"

module Bosh::Inception
  class Cli < Thor
    include Thor::Actions
  end
end