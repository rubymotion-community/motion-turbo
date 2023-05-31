module Turbo
  class VisitableView < UIView
    include WebView
    include Screenshots
    include RefreshControl
    include ActivityIndicator
    include Constraints
    include ScrollView

    def initWithFrame(frame)
      super
      setup
      self
    end

    def setup
      installActivityIndicatorView
    end
  end
end
