require 'rubygems'
require 'bundler'
Bundler.require

require 'arroyo'
require 'yajl/json_gem'

module SpecHelpers
  def stub_faraday(&b)
    return Faraday.default_adapter unless block_given?

    Arroyo::Client.reset
    Arroyo::Client.config = {
      adapter: [:test, Faraday::Adapter::Test::Stubs.new(&b)]
    }
  end

  def response(args={})
    [args.delete(:code) || 200, {:content_type => 'application/json'}, JSON.dump(args)]
  end
end

RSpec.configure do |config|
  config.mock_framework = :rr
  config.include SpecHelpers
end
