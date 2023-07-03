module Turbo
  class TurboError < NSError
    ERROR_DOMAIN = "com.basecamp.Turbolinks"
    ERROR_CODES = {
      http_failure: 0,
      network_failure: -1,
      content_type_mismatch: -2
    }
    attr_accessor :statusCode

    def self.pageLoadFailure
      localizedDescription = "The page could not be loaded due to a configuration error."
      errorWithDomain(ERROR_DOMAIN, code: 123, userInfo: { NSLocalizedDescriptionKey => localizedDescription })
    end

    def self.errorWithCode(code, localizedDescription: localizedDescription)
      errorWithDomain(ERROR_DOMAIN, code: ERROR_CODES[code], userInfo: { NSLocalizedDescriptionKey => localizedDescription })
    end

    def self.errorWithCode(code, statusCode: statusCode)
      error = errorWithDomain(ERROR_DOMAIN, code: ERROR_CODES[code], userInfo: { "statusCode" => statusCode, NSLocalizedDescriptionKey => "HTTP Error: #{statusCode}" })
      error.statusCode = statusCode
      error
    end

    def self.errorWithCode(code, error: error)
      errorWithDomain(ERROR_DOMAIN, code: ERROR_CODES[code], userInfo: { "error" => error, NSLocalizedDescriptionKey => error.localizedDescription })
    end
  end
end
