module Turbolinks
  class ScriptMessage
    NAMES = {
      page_loaded: "pageLoaded",
      error_raised: "errorRaised",
      visit_proposed: "visitProposed",
      visit_started: "visitStarted",
      visit_request_started: "visitRequestStarted",
      visit_request_completed: "visitRequestCompleted",
      visit_request_failed: "visitRequestFailed",
      visit_request_finished: "visitRequestFinished",
      visit_rendered: "visitRendered",
      visit_completed: "visitCompleted",
      page_invalidated: "pageInvalidated"
    }

    def self.parse(message)
      body = message.body
      return unless body

      rawName = body["name"]
      return unless rawName

      name = NAMES.key(rawName)
      return unless name

      data = body["data"]
      return unless data

      return new(name, data)
    end

    attr_reader :name, :data

    def initialize(name, data)
      @name = name
      @data = data
    end

    def identifier
      data["identifier"]
    end

    def restorationIdentifier
      data["restorationIdentifier"]
    end

    def location
      NSURL.alloc.initWithString(data["location"]) if data["location"]
    end

    def action
      data["action"].to_sym
    end
  end
end
