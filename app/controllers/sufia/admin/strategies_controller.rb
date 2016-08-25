module Sufia
  module Admin
    class StrategiesController < Flip::StrategiesController
      before_action do
        authorize! :manage, Feature
      end

      def features_url
        admin_features_path
      end
    end
  end
end
