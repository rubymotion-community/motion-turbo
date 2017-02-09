module Turbolinks
  class Error < NSError
    ERROR_DOMAIN = "com.basecamp.Turbolinks"
    ERROR_CODES = {
      http_failure: 0,
      network_failure: 1
    }

    def self.errorWithCode(code, localizedDescription: localizedDescription)
      errorWithDomain(ERROR_DOMAIN, code: ERROR_CODES[code], userInfo: { NSLocalizedDescriptionKey => localizedDescription })
    end

    def self.errorWithCode(code, statusCode: statusCode)
      errorWithDomain(ERROR_DOMAIN, code: ERROR_CODES[code], userInfo: { "statusCode" => statusCode, NSLocalizedDescriptionKey => "HTTP Error: #{statusCode}" })
    end

    def self.errorWithCode(code, error: error)
      errorWithDomain(ERROR_DOMAIN, code: ERROR_CODES[code], userInfo: { "error" => error, NSLocalizedDescriptionKey => error.localizedDescription })
    end
  end
end
