module Sufia::Controller
  extend ActiveSupport::Concern

  included do
    # Adds Hydra behaviors into the application controller
    include Hydra::Controller::ControllerBehavior

    before_action :set_locale
  end

  def current_ability
    user_signed_in? ? current_user.ability : super
  end

  # Override Devise method to redirect to dashboard after signing in
  def after_sign_in_path_for(_resource)
    sufia.dashboard_index_path
  end

  # Ensure that the locale choice is persistent across requests
  def default_url_options
    { locale: I18n.locale }
  end

  private

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end
end
