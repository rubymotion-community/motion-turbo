module Turbo
  class PathRule
    # Array of regular expressions to match against
    attr_accessor :patterns

    # The properties to apply for matches
    attr_accessor :properties

    # Convenience method to retrieve a String value for a key
    # Access `properties` directly to get a different type
    def subscript(key)
      properties[key].to_s
    end

    def initWithRule(rule)
      self.patterns = rule["patterns"]
      self.properties = rule["properties"]
      self
    end

    # Returns true if any pattern in this rule matches `path`
    def match(path)
      patterns.each do |pattern|
        #guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
        regex = %r(#{pattern})

        if path =~ regex
          return true
        end
      end
      false
    end
  end
end
