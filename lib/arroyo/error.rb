module Arroyo
  # Generic errors thrown on gem mis-usage
  class Error < StandardError; end

  # Raised when Arroyo returns the HTTP status code 400
  class BadRequest < Error; end

  # Raised when Arroyo returns the HTTP status code 404
  class NotFound < Error; end

  # Raised when Arroyo returns the HTTP status code 500
  class InternalServerError < Error; end
end