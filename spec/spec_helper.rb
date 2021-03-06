require 'rspec'
require 'rails/all'
require 'sqlite3'
require_relative '../lib/rails-settings/settings.rb'

if RailsSettings::Settings.respond_to? :raise_in_transactional_callbacks=
  RailsSettings::Settings.raise_in_transactional_callbacks = true
end
require_relative '../lib/rails-settings-cached-typed'

module Rails
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
end

def count_queries &block
  count = 0

  counter_f = ->(name, started, finished, unique_id, payload) {
    unless payload[:name].in? %w[ CACHE SCHEMA ]
      count += 1
    end
  }

  ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)

  count
end

# run cache initializers
RailsSettings::Railtie.initializers.each{|initializer| initializer.run }

# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
# ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(version: 1) do
  create_table :settings do |t|
    t.string :var, null: false
    t.text :value
    t.integer :thing_id
    t.string :thing_type, limit: 30
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :users do |t|
    t.string :login
    t.string :password
    t.datetime :created_at
    t.datetime :updated_at
  end
end

RSpec.configure do |config|
  config.before(:all) do
    class Setting < RailsSettings::CachedSettings
    end

    class CustomSetting < RailsSettings::CachedSettings
      table_name = 'custom_settings'
    end

    class User < ActiveRecord::Base
      has_settings gender: :string,
                   level: :integer,
                   locked: :boolean,
                   last_logined_at: :object

      before_setting_save :do_something
      after_setting_save :do_something_else

      def do_something
      end

      def do_something_else
      end
    end

    ActiveRecord::Base.connection.execute('delete from settings')
    Rails.cache.clear
  end

  config.after(:all) do
    Object.send(:remove_const, :Setting)
  end
end
