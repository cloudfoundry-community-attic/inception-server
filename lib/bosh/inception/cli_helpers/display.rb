module Bosh::Inception::CliHelpers
  module Display
    # Display header for a new section of the bootstrapper
    def header(title, options={})
      say "" # golden whitespace
      if skipping = options[:skipping]
        say "Skipping #{title}", [:yellow, :bold]
        say skipping
      else
        say title, [:green, :bold]
      end
      say "" # more golden whitespace
    end

    def error(message)
      say message, :red
      exit 1
    end

    def confirm(message)
      say "Confirming: #{message}", green
      say "" # bonus golden whitespace
    end

  end
end