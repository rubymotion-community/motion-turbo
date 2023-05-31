module Turbo
  class PathConfigurationDecoder
    attr_accessor :settings, :rules

    def initWithSettings(settings, rules: rules)
      self.settings = settings
      self.rules = rules
      self
    end

    def initWithJSON(json)
      # rules must be present, settings are optional
      #guard let rulesArray = json["rules"] as? [[String: AnyHashable]] else {
        #throw JSONDecodingError.invalidJSON
      #}

      rules = json["rules"].map do |rule|
        PathRule.alloc.initWithRule(rule)
      end
      settings = json["settings"]

      initWithSettings(settings, rules: rules)
    end
  end
end
