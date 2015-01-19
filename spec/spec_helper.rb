require 'fastlane'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
  
end

# WebMock.disable_net_connect!(:allow => 'codeclimate.com')
WebMock.allow_net_connect!



module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end