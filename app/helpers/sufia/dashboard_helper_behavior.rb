module Sufia
  module DashboardHelperBehavior
    def render_sent_transfers
      if @outgoing.present?
        render 'sufia/transfers/sent'
      else
        t('sufia.dashboard.no_transfers')
      end
    end

    def render_received_transfers
      if @incoming.present?
        render 'sufia/transfers/received'
      else
        t('sufia.dashboard.no_transfer_requests')
      end
    end

    def render_recent_activity
      if @activity.empty?
        t('sufia.dashboard.no_activity')
      else
        render 'sufia/users/activity_log', events: @activity
      end
    end

    def render_recent_notifications
      if @notifications.empty?
        t('sufia.dashboard.no_notifications')
      else
        render 'sufia/mailbox/notifications', messages: notifications_for_dashboard
      end
    end

    def on_the_dashboard?
      params[:controller].match(%r{^sufia/dashboard|sufia/my})
    end

    def on_my_works?
      params[:controller].match(%r{^sufia/my/works})
    end

    def number_of_works(user = current_user)
      CurationConcerns::WorkRelation.new.where(DepositSearchBuilder.depositor_field => user.user_key).count
    rescue RSolr::Error::ConnectionRefused
      'n/a'
    end

    def number_of_files(user = current_user)
      ::FileSet.where(DepositSearchBuilder.depositor_field => user.user_key).count
    rescue RSolr::Error::ConnectionRefused
      'n/a'
    end

    def number_of_collections(user = current_user)
      ::Collection.where(DepositSearchBuilder.depositor_field => user.user_key).count
    rescue RSolr::Error::ConnectionRefused
      'n/a'
    end

    def notifications_for_dashboard
      @notifications.limit(Sufia.config.max_notifications_for_dashboard)
    end

    def link_to_additional_notifications
      return unless @notifications.count > Sufia.config.max_notifications_for_dashboard
      link_to t('sufia.dashboard.additional_notifications'), sufia.notifications_path
    end
  end
end
