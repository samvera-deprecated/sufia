module Sufia
  module Admin
    class StrategiesController < Flipflop::StrategiesController
      before_action do
        authorize! :manage, Sufia::Feature
      end

      def features_url
        admin_features_path
      end
    end
  end
end
