module Turbo
  class ScriptMessage
    NAMES = {
      page_loaded: "pageLoaded",
      page_load_failed: "pageLoadFailed",
      error_raised: "errorRaised",
      visit_proposed: "visitProposed",
      visit_started: "visitStarted",
      visit_request_started: "visitRequestStarted",
      visit_request_completed: "visitRequestCompleted",
      visit_request_failed: "visitRequestFailed",
      visit_request_finished: "visitRequestFinished",
      visit_rendered: "visitRendered",
      visit_completed: "visitCompleted",
      form_submission_started: "formSubmissionStarted",
      form_submission_finished: "formSubmissionFinished",
      page_invalidated: "pageInvalidated",
      log: "log"
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
      identifier = data["identifier"]
      identifier if identifier.is_a?(String)
    end

    # Milliseconds since unix epoch as provided by JavaScript Date.now()
    def timestamp
      #data["timestamp"] as? TimeInterval ?? 0
      timestamp = data["timestamp"]
      timestamp.to_i || 0
    end

    def date
      NSDate.alloc.initWithTimeIntervalSince1970(timestamp / 1000.0)
    end

    def restorationIdentifier
      restorationIdentifier = data["restorationIdentifier"]
      restorationIdentifier if restorationIdentifier.is_a?(String)
    end

    def location
      NSURL.alloc.initWithString(data["location"]) if data["location"]
    end

    def options
      if options = data["options"]
        VisitOptions.alloc.initFromHash(options)
      else
        nil
      end
    end
  end
end
