require 'faraday_middleware'
require 'faraday/raise_http_exception'

module Arroyo
  module Connection

  private
    def connection
      options = {
        :headers => {'Accept' => "#{body_mimetype}; charset=utf-8", 'User-Agent' => user_agent},
        :url => endpoint
      }
      @connection ||= Faraday::Connection.new(options) do |conn|
        conn.use Faraday::Request::UrlEncoded
        conn.use FaradayMiddleware::Mashify
        conn.use FaradayMiddleware::RaiseHttpException
        conn.use FaradayMiddleware::ParseJson if body_mimetype==Arroyo::Configuration::DEFAULT_BODY_MIMETYPE
        conn.adapter(adapter)  
      end
    end
  end
end