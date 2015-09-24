require_relative 'rails-settings/settings'
require_relative 'rails-settings/cached_settings'
require_relative 'rails-settings/scoped_settings'
require_relative 'rails-settings/extend'

class RailsSettings::Railtie < Rails::Railtie
  initializer 'rails_settings.active_record.initialization' do
    RailsSettings::CachedSettings.after_commit :rewrite_cache, on: %i(create update)
    RailsSettings::CachedSettings.after_commit :expire_cache, on: %i(destroy)
  end

  initializer 'rails-settings-cached-typed.extend_active_record' do
    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Base.send :extend, RailsSettings::Extend
    end
  end
end
