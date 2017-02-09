module Turbolinks
  class JavaScriptVisit < Visit
    def identifier
      @identifier ||= "(pending)"
    end

    def description
      "<#{dynamicType} #{identifier}: state=#{state} location=#{location}>"
    end

    def startVisit
      puts "JavaScriptVisit#startVisit"
      webView.visitDelegate = self
      webView.visitLocation(location, withAction: action, restorationIdentifier: restorationIdentifier)
    end

    def cancelVisit
      webView.cancelVisitWithIdentifier(identifier)
      finishRequest
    end

    def failVisit
      finishRequest
    end

    # WebViewVisitDelegate

    def webView(webView, didStartVisitWithIdentifier: identifier, hasCachedSnapshot: hasCachedSnapshot)
      puts "JavaScriptVisit#webView:didStartVisitWithIdentifier:hasCachedSnapshot"
      @identifier = identifier
      @hasCachedSnapshot = hasCachedSnapshot

      delegate.visitDidStart(self) if delegate
      webView.issueRequestForVisitWithIdentifier(identifier)

      afterNavigationCompletion do
        webView.changeHistoryForVisitWithIdentifier(identifier)
        webView.loadCachedSnapshotForVisitWithIdentifier(identifier)
      end
    end

    def webView(webView, didStartRequestForVisitWithIdentifier: identifier)
      puts "JavaScriptVisit#webView:didStartRequestForVisitWithIdentifier"
      if identifier == self.identifier
        startRequest
      end
    end

    def webView(webView, didCompleteRequestForVisitWithIdentifier: identifier)
      puts "JavaScriptVisit#webView:didCompleteRequestForVisitWithIdentifier"
      if identifier == self.identifier
        afterNavigationCompletion do
          delegate.visitWillLoadResponse(self) if delegate
          webView.loadResponseForVisitWithIdentifier(identifier)
        end
      end
    end

    def webView(webView, didFailRequestForVisitWithIdentifier: identifier, statusCode: statusCode)
      puts "JavaScriptVisit#webView:didFailRequestForVisitWithIdentifier"
      if identifier == self.identifier
        fail do
          if statusCode == 0
            error = Error.errorWithCode(:network_failure, localizedDescription: "A network error occurred.")
          else
            error = Error.errorWithCode(:http_failure, statusCode: statusCode)
          end
          delegate.visit(self, requestDidFailWithError: error) if delegate
        end
      end
    end

    def webView(webView, didFinishRequestForVisitWithIdentifier: identifier)
      puts "JavaScriptVisit#webView:didFinishRequestForVisitWithIdentifier"
      if identifier == self.identifier
        finishRequest
      end
    end

    def webView(webView, didRenderForVisitWithIdentifier: identifier)
      puts "JavaScriptVisit#webView:didRenderForVisitWithIdentifier"
      if identifier == self.identifier
        delegate.visitDidRender(self) if delegate
      end
    end

    def webView(webView, didCompleteVisitWithIdentifier: identifier, restorationIdentifier: restorationIdentifier)
      puts "JavaScriptVisit#webView:didCompleteVisitWithIdentifier:restorationIdentifier"
      if identifier == self.identifier
        @restorationIdentifier = restorationIdentifier
        complete
      end
    end
  end
end
