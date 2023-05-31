module Turbo
  class VisitResponse
    attr_reader :statusCode, :responseHTML

    def initWithStatusCode(statusCode, responseHTML: responseHTML)
      @statusCode = statusCode
      @responseHTML = responseHTML
      self
    end

    # TODO Codable, JSONCodable?
    def encode
      { statusCode: statusCode, responseHTML: responseHTML }
    end

    def inspect
      "#<VisitResponse statusCode=#{statusCode} responseHTML=#{responseHTML.inspect}>"
    end

    #TODO public var isSuccessful: Bool {
        #switch statusCode {
        #case 200...299:
            #return true
        #default:
            #return false
        #}
    #}
  end
end
