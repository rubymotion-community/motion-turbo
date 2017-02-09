module Turbolinks
  class Visit
    attr_accessor :delegate, :restorationIdentifier
    attr_reader :visitable,
                :action,
                :webView,
                :state,
                :location,
                :hasCachedSnapshot

    def initialize(options)
      @visitable = options[:visitable]
      @location = visitable.visitableURL
      @action = options[:action]
      @webView = options[:webView]
      @state = :initialized
      @navigationCompleted = false
      @hasCachedSnapshot = false
    end

    def start
      puts "Visit#start"
      if state == :initialized
        delegate.visitWillStart(self) if delegate
        @state = :started
        startVisit
      end
    end

    def cancel
      puts "Visit#cancel"
      if state == :started
        @state = :canceled
        cancelVisit
      end
    end

    def complete
      puts "Visit#complete"
      if state == :started
        @state = :completed
        completeVisit
        delegate.visitDidComplete(self) if delegate
        delegate.visitDidFinish(self) if delegate
      end
    end

    def fail(&callback)
      puts "Visit#fail"
      if state == :started
        @state = :failed
        callback.call() if callback
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

    # Navigation

    attr_reader :navigationCompleted, :navigationCallback

    def completeNavigation
      puts "Visit#completeNavigation"
      if state == :started && !navigationCompleted
        @navigationCompleted = true
        navigationCallback.call if navigationCallback
      end
    end

    private

    def afterNavigationCompletion(&callback)
      puts "Visit#afterNavigationCompletion"
      if navigationCompleted
        callback.call
      else
        previousNavigationCallback = navigationCallback
        @navigationCallback = proc do
          previousNavigationCallback.call if previousNavigationCallback
          if state != :canceled
            callback.call
          end
        end
      end
    end

    # Request state

    def requestStarted
      @requestStarted ||= false
    end

    def requestFinished
       @requestFinished ||= false
    end

    def startRequest
      puts "Visit#startRequest"
      unless requestStarted
        @requestStarted = true
        delegate.visitRequestDidStart(self) if delegate
      end
    end

    def finishRequest
      puts "Visit#finishRequest"
      if requestStarted && !requestFinished
        @requestFinished = true
        delegate.visitRequestDidFinish(self) if delegate
      end
    end
  end
end
