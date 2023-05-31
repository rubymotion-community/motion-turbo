module Turbo
  class Visit
    attr_accessor :delegate, :restorationIdentifier
    attr_reader :visitable,
                :webView,
                :bridge,
                :options,
                :state,
                :location,
                :hasCachedSnapshot

    def initWithVisitable(visitable, options: options, bridge: bridge)
      raise visitable.visitableURL.inspect if visitable.visitableURL.is_a?(Hash)# TODO
      raise options.inspect unless options.is_a?(VisitOptions)# TODO
      @visitable = visitable
      @location = visitable.visitableURL
      @options = options
      @bridge = bridge
      @webView = @bridge.webView
      @state = :initialized
      @hasCachedSnapshot = false
      self
    end

    def start
      if state == :initialized
        delegate.visitWillStart(self) if delegate
        @state = :started
        startVisit
      end
    end

    def cancel
      if state == :started
        @state = :canceled
        cancelVisit
      end
    end

    def complete
      if state == :started
        @state = :completed
        completeVisit
        delegate.visitDidComplete(self) if delegate
        delegate.visitDidFinish(self) if delegate
      end
    end

    def fail(error)
      if state == :started
        @state = :failed
        delegate.visit(self, requestDidFailWithError: error) if delegate
        failVisit
        delegate.visitDidFail(self) if delegate
        delegate.visitDidFinish(self) if delegate
      end
    end

    # Hooks for subclasses
    def startVisit; end
    def cancelVisit; end
    def completeVisit; end
    def failVisit; end

    private

    # Request state

    def requestStarted
      @requestStarted ||= false
    end

    def requestFinished
       @requestFinished ||= false
    end

    def startRequest
      unless requestStarted
        @requestStarted = true
        delegate.visitRequestDidStart(self) if delegate
      end
    end

    def finishRequest
      if requestStarted && !requestFinished
        @requestFinished = true
        delegate.visitRequestDidFinish(self) if delegate
      end
    end
  end
end
