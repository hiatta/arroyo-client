require 'faraday'

module FaradayMiddleware
  class RaiseHttpException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        case response[:status].to_i
        when 400
          raise Arroyo::BadRequest, error_message(response)
        when 404
          raise Arroyo::NotFound, error_message(response)
        when 500
          raise Arroyo::InternalServerError, error_message(response)
        end
      end
    end

    def initialize(app)
      super(app)
      @parser = nil
    end

  private
    def error_message(response)
      "#{response[:method].to_s.upcase} #{response[:url]} - [#{response[:status].to_s}] - #{error_body(response[:body])}"
    end

    def error_body(body)
      if body and (body.kind_of?(Hash) or body.kind_of?(Hashie)) and body['error'] and !body['error'].empty?
        return "#{body['error']}"
      end
      return body
    end
  end
end