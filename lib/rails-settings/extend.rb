module RailsSettings
  module Extend
    def self.extended(obj)
      obj.instance_exec { define_model_callbacks :setting_save }
    end

    def has_settings(*list_of_settings)
      attrs = list_of_settings.first

      raise ArgumentError.new('Expected a Hash') unless attrs.is_a?(Hash)

      defaults = {}

      # attrs is a hash containing what was passed in, which could be either
      # {setting_field_name => setting_field_type} or
      # {setting_field_name => {default: setting_default_value, type: setting_field_type} }
      # whereas filteredAttrs is only
      # {setting_field_name => setting_field_type}
      filteredAttrs = {}
      attrs.each do |k, v|
        type = nil

        if v.is_a?(Hash)
          filteredAttrs[k] = v[:type]
          defaults[k.to_sym] = v[:default]
          type = v[:type]
        else
          type = v
          filteredAttrs[k] = v
        end

        if !%i(object string integer float boolean).member?(type.to_sym)
          raise ArgumentError.new("#{v}: not allowed as a type.")
        end
      end

      define_method :whitelisted_settings do
        @whitelisted_settings ||= filteredAttrs.map{|k, v| k.to_sym}
      end

      define_method :rails_settings_mapping do
        @rails_settings_mapping ||= filteredAttrs
      end

      define_method :default_settings do
        @default_settings ||= defaults
      end

      include InstanceMethods

      scope :with_settings, lambda {
                            joins("JOIN settings ON (settings.thing_id = #{table_name}.#{primary_key} AND
                               settings.thing_type = '#{base_class.name}')")
                                .select("DISTINCT #{table_name}.*")
                          }

      scope :with_settings_for, lambda  { |var|
                                joins("JOIN settings ON (settings.thing_id = #{table_name}.#{primary_key} AND
                               settings.thing_type = '#{base_class.name}') AND settings.var = '#{var}'")
                              }

      scope :without_settings, lambda {
                               joins("LEFT JOIN settings ON (settings.thing_id = #{table_name}.#{primary_key} AND
                                    settings.thing_type = '#{base_class.name}')")
                                   .where('settings.id IS NULL')
                             }

      scope :without_settings_for, lambda  { |var|
                                   where('settings.id IS NULL')
                                       .joins("LEFT JOIN settings ON (settings.thing_id = #{table_name}.#{primary_key} AND
                                     settings.thing_type = '#{base_class.name}') AND settings.var = '#{var}'")
                                 }
    end

    private

    module InstanceMethods
      def settings
        ScopedSettings.for_thing(self)
      end

      def settings=(attr)
        return if attr.nil?
        raise ArgumentError.new('Expected a Hash') unless attr.is_a?(Hash)
        #todo: Settings class not always defined..
        Settings.all.where(thing_type: self.class.to_s, thing_id: self.id).destroy_all
        update_settings(attr)
      end

      def update_settings(given_settings)
        if given_settings.is_a?(Hash)
          given_settings = given_settings.symbolize_keys
          given_settings.slice!(*whitelisted_settings)
          given_settings.each do |k, v|
            type = rails_settings_mapping[k]

            self.settings[k] = case type
                                 when :float
                                   ActiveRecord::Type::Float.new.type_cast_from_user(v)
                                 when :integer
                                   ActiveRecord::Type::Integer.new.type_cast_from_user(v)
                                 when :string
                                   ActiveRecord::Type::String.new.type_cast_from_user(v)
                                 when :boolean
                                   ActiveRecord::Type::Boolean.new.type_cast_from_user(v)
                                 when :object
                                   v
                               end
          end
        end
      end
    end
  end
end
