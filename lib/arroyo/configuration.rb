require 'faraday'

module Arroyo
  module Configuration
    VALID_OPTIONS_KEYS = [
      :endpoint,
      :adapter,
      :user_agent,
      :body_mimetype
    ]

    DEFAULT_ENDPOINT = nil
    DEFAULT_ADAPTER = Faraday.default_adapter
    DEFAULT_USER_AGENT = "Arroyo Ruby Client - #{Arroyo::VERSION}"
    DEFAULT_BODY_MIMETYPE='application/json'.freeze
    
    attr_accessor *VALID_OPTIONS_KEYS
    
    # Reset values to prevent stepping on the toes of other users of this module
    def self.extended(parent)
      parent.reset
    end
    
    # Allow options to be set in a block
    def configure
      yield self
    end
   
    # Create a hash of options and their values
    def options
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end
       
    # Reset configuration to defaults
    def reset
      self.endpoint = DEFAULT_ENDPOINT
      self.adapter = DEFAULT_ADAPTER
      self.user_agent = DEFAULT_USER_AGENT
      self.body_mimetype = DEFAULT_BODY_MIMETYPE
    end
  end
end