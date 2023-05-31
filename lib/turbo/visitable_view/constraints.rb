module Turbo
  class VisitableView < UIView
    module Constraints
      def addFillConstraintsForSubview(view)
        NSLayoutConstraint.activateConstraints([
          view.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
          view.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
          view.topAnchor.constraintEqualToAnchor(topAnchor),
          view.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
        ])
      end
    end
  end
end
