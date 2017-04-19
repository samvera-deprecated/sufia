Rails.application.config.after_initialize do
  # If Google Analytics are enabled, pre-load the models which rely on
  # Legato::Model.extended(base) dynamic profile method generation. Non-production
  # environments wouldn't necessarily have this eager loaded by default.
  if Sufia.config.analytics
    require 'legato'
    require 'sufia/pageview'
    require 'sufia/download'
  end
end
