module Turbolinks
  class VisitableView < UIView
    include WebView
    include Screenshots
    include ScrollView
    include RefreshControl
    include ActivityIndicator
    include Layout

    def initWithFrame(frame)
      puts "VisitableView#initWithFrame"
      super
      initialize
    end

    def initialize
      puts "VisitableView#initialize"
      installHiddenScrollView
      installActivityIndicatorView
    end
  end
end
