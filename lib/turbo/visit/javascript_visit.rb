module Turbo
  # A JavaScript managed visit through the Turbo library
  # All visits are JavaScriptVisits except the initial ColdBootVisit
  # or if a reload() is issued
  class JavaScriptVisit < Visit
    attr_writer :identifier, :hasCachedSnapshot
    def identifier
      @identifier ||= "(pending)"
    end

    def initWithVisitable(visitable, options: options, bridge: bridge, restorationIdentifier: restorationIdentifier)
      initWithVisitable(visitable, options: options, bridge: bridge)
      self.restorationIdentifier = restorationIdentifier
      self
    end

    def description
      "<#{dynamicType} #{identifier}: state=#{state} location=#{location}>"
    end

    def startVisit
      log("startVisit")
      bridge.visitDelegate = self
      bridge.visitLocation(location, withOptions: options, restorationIdentifier: restorationIdentifier)
    end

    def cancelVisit
      log("cancelVisit")
      bridge.cancelVisitWithIdentifier(identifier)
      finishRequest
    end

    def failVisit
      log("failVisit")
      finishRequest
    end

    # WebViewVisitDelegate

    def webView(webView, didStartVisitWithIdentifier: identifier, hasCachedSnapshot: hasCachedSnapshot)
      log("didStartVisitWithIdentifier", arguments: { identifier: identifier, hasCachedSnapshot: hasCachedSnapshot })
      self.identifier = identifier
      self.hasCachedSnapshot = hasCachedSnapshot

      delegate.visitDidStart(self) if delegate
    end

    def webView(webView, didStartRequestForVisitWithIdentifier: identifier, date: date)
      log("didStartRequestForVisitWithIdentifier", arguments: { identifier: identifier, date: date })
      if identifier == self.identifier
        startRequest
      end
    end

    def webView(webView, didCompleteRequestForVisitWithIdentifier: identifier)
      log("didCompleteRequestForVisitWithIdentifier", arguments: { identifier: identifier })
      if identifier == self.identifier
        delegate.visitWillLoadResponse(self) if hasCachedSnapshot && delegate
      end
    end

    def webView(webView, didFailRequestForVisitWithIdentifier: identifier, statusCode: statusCode)
      log("didCompleteRequestForVisitWithIdentifier", arguments: { identifier: identifier, statusCode: statusCode })
      if identifier == self.identifier
        # TODO implemented differently
        if statusCode == 0
          error = TurboError.errorWithCode(:network_failure, localizedDescription: "A network error occurred.")
        else
          error = TurboError.errorWithCode(:http_failure, statusCode: statusCode)
        end
        fail(error)
      end
    end

    def webView(webView, didFinishRequestForVisitWithIdentifier: identifier, date: date)
      log("didFinishRequestForVisitWithIdentifier", arguments: { identifier: identifier, date: date })
      if identifier == self.identifier
        finishRequest
      end
    end

    def webView(webView, didRenderForVisitWithIdentifier: identifier)
      log("didRenderForVisitWithIdentifier", arguments: { identifier: identifier })
      if identifier == self.identifier
        delegate.visitDidRender(self) if delegate
      end
    end

    def webView(webView, didCompleteVisitWithIdentifier: identifier, restorationIdentifier: restorationIdentifier)
      log("didCompleteVisitWithIdentifier", arguments: { identifier: identifier, restorationIdentifier: restorationIdentifier })
      if identifier == self.identifier
        @restorationIdentifier = restorationIdentifier
        complete
      end
    end

    private

    def log(name)
      log(name, arguments: nil)
    end

    def log(name, arguments: arguments)
      debugLog("[JavaScriptVisit] #{name} #{location.absoluteString}", arguments: arguments)
    end
  end
end
