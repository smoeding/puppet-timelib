require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  # supply tests with a possibility to test for the future parser
  config.add_setting :puppet_future
  config.puppet_future = Puppet.version.to_f >= 4.0
end
