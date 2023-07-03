module Turbo
  class PathConfiguration

    attr_accessor :sources, :loader, :delegate, :rules, :settings
    # Multiple sources will be loaded in order
    # Remote sources should be last since they're loaded async
    def initWithSources(sources)
      self.sources = sources
      self.rules = []
      load
      self
    end

    # Returns a merged hash containing all the properties
    # that match this url
    # Note: currently only looks at path, not query, but most likely will
    # add query support in the future, so it's best to always use this over the path variant
    # unless you're sure you'll never need to reference other parts of the URL in the future
    def propertiesForURL(url)
      propertiesForPath(url.path)
    end

    # Returns a merged hash containing all the properties
    # that match this path
    def propertiesForPath(path)
      #source = NSString.stringWithContentsOfURL(url, encoding: NSUTF8StringEncoding, error: nil)
      properties = {}

      rules.each do |rule|
        if rule.match(path)
          properties.merge!(rule.properties)
        end
      end
      properties
    end

    private

    def load
      loader = PathConfigurationLoader.alloc.initWithSources(sources)
      if loader
        loader.load do |config|
          self.send(:update, config)
        end
      end
    end

    def update(config)
      # Update our internal state with the config from the loader
      self.settings = config.settings
      self.rules = config.rules
      delegate.pathConfigurationDidUpdate if delegate
    end
  end
end
