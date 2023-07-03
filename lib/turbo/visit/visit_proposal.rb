module Turbo
  class VisitProposal
    attr_reader :url, :options, :properties

    def initWithURL(url, options: options, properties: properties)
      @url = url
      raise unless options.is_a?(VisitOptions)
      @options = options
      @properties = properties || {}
      self
    end
  end
end
