class TurboLog
  def self.debugLoggingEnabled
    true # TODO NSBundle.mainBundle.objectForInfoDictionaryKey('DEBUG')
  end
end

def debugLog(message)
  debugLog(message, arguments: {})
end

def debugLog(message, arguments: arguments)
  timestamp = NSDate.new

  log2("#{timestamp} #{message} #{arguments}")
end

def debugPrint(message)
  log2(message)
end

def log2(message)
  if TurboLog.debugLoggingEnabled
    NSLog(message)
  end
end
