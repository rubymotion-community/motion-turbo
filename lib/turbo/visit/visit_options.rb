module Turbo
  class VisitOptions
    attr_reader :action, :response

    # TODO not used for now
    def initWithAction(action, response: response)
      @action = action
      if response
        @response = VisitResponse.alloc.initWithStatusCode(response["statusCode"], responseHTML: response["innerHTML"])
      end
      self
    end

    def initFromHash(options)
      raise "options is not a Hash" unless options.is_a?(Hash) # TODO remove?
      @action = options["action"] || 'advance'
      if response = options["response"]
        @response = VisitResponse.alloc.initWithStatusCode(response["statusCode"], responseHTML: response["responseHTML"])
      end
      self
    end

    # TODO Codable, JSONCodable?
    def encode
      if response
        { action: @action, response: response.encode }
      else
        { action: @action }
      end
    end

    def inspect
      "#<VisitOptions action=#{action} response=#{response}>"
    end
  end
end
