module RailsSettings
  module Extend
    def self.extended(obj)
      obj.instance_exec { define_model_callbacks :setting_save }
    end

    def has_settings(*list_of_settings)
      attrs = list_of_settings.first

      raise ArgumentError.new('Expected a Hash') unless attrs.is_a?(Hash)

      attrs.each do |k, v|
        v_type = v
        if v.is_a? Hash && v.key?(:type)
          v_type = v[:key]
        end
        if !%i(object string integer float boolean).member?(v_type.to_sym)
          raise ArgumentError.new("#{v}: not allowed as a type.")
        end
      end

      define_method :whitelisted_settings do
        @whitelisted_settings ||= attrs.map{|k, v| k.to_sym}
      end

      define_method :rails_settings_mapping do
        @rails_settings_mapping ||= attrs
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
