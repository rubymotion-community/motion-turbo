module Turbo
  class PathConfigurationLoader
    PathConfigurationLoaderCompletionHandler = Class.new(PathConfigurationDecoder)

    attr_accessor :sources, :completionHandler
    def initWithSources(sources)
      self.sources = sources
      self
    end

    def load(&completionHandler)
      #completionHandler = PathConfigurationLoaderCompletionHandler.new

      sources.each do |source|
        #case source
        #when .data(let data)
          #data = loadData(source)
          data = loadFile(source)
          completionHandler.call(data)

        #when .file(let url):
          #loadFile(source)
        #when .server(let url):
          #download(from: url)
        #end
      end
    end

    private

    def cacheDirectory
      "Turbo"
    end

    def configurationCacheFilename
      "path-configuration.json"
    end

    # MARK: - File

    def loadFile(url)
      #precondition(url.isFileURL, "URL provided for file is not a file url")
      error_ptr = Pointer.new(:object)
      data = NSData.alloc.initWithContentsOfURL(url, options:NSDataReadingUncached, error:error_ptr)
      #begin
        #data = File.read(url) #try Data(contentsOf: url)
        loadData(data)
        #end catch {
        #debugPrint("[path-configuration] *** error loading configuration from file: \(url), error: \(error)")
        #end
      #end
    end

    # MARK: - Data

    def loadData(json) #, cache: cache)
      error_ptr = Pointer.new(:object)
      data = NSJSONSerialization.JSONObjectWithData(json, options: 0, error: error_ptr)
      PathConfigurationDecoder.alloc.initWithJSON(data)
    end
  end
end
