require File.expand_path('arroyo/error', File.dirname(__FILE__))
require File.expand_path('arroyo/configuration', File.dirname(__FILE__))
require File.expand_path('arroyo/client', File.dirname(__FILE__))


module Arroyo
  extend Configuration
  
  # Alias for Arroyo::Client.new
  def self.client(options={})
    Arroyo::Client.new(options)
  end

  # Delegate to Arroyo::Client
  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end

  # Delegate to Arroyo::Client
  def self.respond_to?(method)
    return client.respond_to?(method) || super
  end
end