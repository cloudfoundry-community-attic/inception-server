guard :rspec, spec_paths: ["spec/unit"] do
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^lib/})     { |m| "spec/unit" }
  watch('spec/spec_helper.rb')  { "spec/unit" }
end

