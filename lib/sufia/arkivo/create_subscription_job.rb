module Sufia
  module Arkivo
    class SubscriptionError < RuntimeError
    end

    class CreateSubscriptionJob
      attr_reader :user

      def queue_name
        :arkivo_subscription
      end

      def initialize(user_key)
        @user = ::User.find_by_user_key(user_key)
        validate_user!
      end

      def call
        # post json to API
        response = connection.post do |request|
          request.url Sufia::Arkivo.new_subscription_url
          request.headers['Content-Type'] = 'application/json'
          request.body = new_subscription_json
        end
        # parse results
        subscription_path = response.headers['Location']
        # create subscription
        user.arkivo_subscription = subscription_path
        user.save
      end

      private

      def validate_user!
        raise SubscriptionError.new('User not found') if @user.blank?
        raise SubscriptionError.new('User does not have an Arkivo token') if user.arkivo_token.blank?
        raise SubscriptionError.new('User has not yet connected with Zotero') if user.zotero_userid.blank?
        raise SubscriptionError.new('User already has a subscription') if user.arkivo_subscription.present?
      end

      def connection
        Faraday.new(url: Sufia::Arkivo.config[:url])
      end

      def new_subscription_json
        {
          url: Sufia::Zotero.publications_url(@user.zotero_userid),
          plugins: [
            {
              name: "sufia",
              options: { token: @user.arkivo_token }
            }
          ]
        }.to_json
      end
    end
  end
end
