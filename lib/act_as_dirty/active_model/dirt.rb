# -*- coding: utf-8 -*-

require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/array/conversions'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/ordered_hash'

module ActAsDirty
  module ActiveModel
    class Dirt
      include Enumerable
          
      attr_reader :messages
    
      def initialize(base)
        @base = base
        @messages = ActiveSupport::OrderedHash.new
      end
      
      # Clear the messages
      def clear
        messages.clear
      end
      
      # Do the dirty messages include a message for the attribute +attribute+?
      def include?(attribute)
        (v = messages[attribute]) && v.any?
      end
      alias :has_key? :include?
      
      # Get messages for +key+
      def get(key)
        messages[key]
      end
      
      # Set messages for +key+ to +value+
      def set(key, value)
        messages[key] = value
      end
    
      # Delete messages for +key+
      def delete(key)
        messages.delete(key)
      end
    
      # When passed a symbol or a name of a method, returns an array of messages
      # for the method.
      #
      #   p.dirt[:name]   # => ["has been updated from Bob to John"]
      #   p.dirt['name']  # => ["has been updated from Bob to John"]
      def [](attribute)
        get(attribute.to_sym) || set(attribute.to_sym, [])
      end
    
      # Iterates through each error key, value pair in the error messages hash.
      # Yields the attribute and the error for that attribute. If the attribute
      # has more than one error message, yields once for each error message.
      #
      #   p.errors.add(:name, "can't be blank")
      #   p.errors.each do |attribute, errors_array|
      #     # Will yield :name and "can't be blank"
      #   end
      #
      #   p.errors.add(:name, "must be specified")
      #   p.errors.each do |attribute, errors_array|
      #     # Will yield :name and "can't be blank"
      #     # then yield :name and "must be specified"
      #   end
      def each
        messages.each_key do |attribute|
          yield attribute
        end
      end
      
      # Returns the number of error messages.
      #
      #   p.dirt.add(:name, "has been updated from Bob to John")
      #   p.dirt.size # => 1
      #   p.dirt.add(:name, "has been updated from Bob to John")
      #   p.dirt.size # => 2
#      def size
#        values.flatten.size
#      end
      
      # Returns all message values
      def values
        messages.values
      end
      
      # Returns all message keys
      def keys
        messages.keys
      end
      
      # Returns an array of dirty messages, with the attribute name included
      #
      #   p.dirt.add(:name, "has been updated from Bob to John")
      #   p.dirt.add(:nickname, "has been updated from Bobby to Johnny")
      #   p.dirt.to_a # => ["Name has been updated from Bob to John", "Nickname has been updated from Bobby to Johnny"]
      def to_a
        full_messages
      end
    
      # Returns the number of dirty messages.
      def count
        to_a.size
      end
    
      # Returns true if no dirty messages are found, false otherwise.
      # If the dirty message is a string it can be empty.
      def empty?
        values.compact.empty?
      end
      alias_method :blank?, :empty?

      # Returns an xml formatted representation of the Dirt hash.
      #
      #   p.dirt.add(:name, "has been updated from Bob to John")
      #   p.dirt.add(:nickname, "has been updated from Bobby to Johnny")
      #   p.dirt.to_xml
      #   # =>
      #   #  <?xml version=\"1.0\" encoding=\"UTF-8\"?>
      #   #  <dirts>
      #   #    <dirt>name has been updated from Bob to John</dirt>
      #   #    <dirt>name has been updated from Bobby to Johnny</dirt>
      #   #  </dirts>
      def to_xml(options={})
        to_a.to_xml options.reverse_merge(:root => "dirts", :skip_types => true)
      end
    
      # Returns an ActiveSupport::OrderedHash that can be used as the JSON representation for this object.
      def as_json(options=nil)
        to_hash
      end

      def to_hash
        messages.dup
      end

      # Adds +message+ to the dirty messages on +attribute+. More than one error can be added to the same
      # +attribute+.
      # If no +message+ is supplied, <tt>:invalid</tt> is assumed.
      #
      # If +message+ is a symbol, it will be translated using the appropriate scope (see +translate_dirt+).
      # If +message+ is a proc, it will be called, allowing for things like <tt>Time.now</tt> to be used within an error.
#      def add(attribute, message = nil, options = {})
#        message = normalize_message(attribute, message, options)
#        self[attribute] << message
#      end

      # Will add a dirty message to each of the attributes in +attributes+ that is empty.
#      def add_on_empty(attributes, options = {})
#        [attributes].flatten.each do |attribute|
#          value = @base.send(:read_attribute_for_cleaning, attribute)
#          is_empty = value.respond_to?(:empty?) ? value.empty? : false
#          add(attribute, :empty, options) if value.nil? || is_empty
#        end
#      end
#
#      # Will add a dirty message to each of the attributes in +attributes+ that is blank (using Object#blank?).
#      def add_on_blank(attributes, options = {})
#        [attributes].flatten.each do |attribute|
#          value = @base.send(:read_attribute_for_cleaning, attribute)
#          add(attribute, :blank, options) if value.blank?
#        end
#      end

      # Returns true if a dirty message on the attribute with the given message is present, false otherwise.
      # +message+ is treated the same as for +add+.
      #   p.dirt.add :name, :blank
      #   p.dirt.added? :name, :blank # => true
#      def added?(attribute, message = nil, options = {})
#        message = normalize_message(attribute, message, options)
#        self[attribute].include? message
#      end

      def added?(attribute)
        keys.include? attribute && messages[attribute].present?
      end
      
#      # Returns all the full error messages in an array.
#      #
#      #   class User
#      #     cleans :name, :nickname, :email
#      #   end
#      #
#      #   company = Company.create(:name => "John Doe", :nickname => "Johnny", :email => "john@example.com")
#      #   company.dirt.full_messages # =>
#      #     ["Added John Doe as a name", "Added Johnny as a nickname", "Added john@example.com as an email"]
      def full_messages
#        map { |attribute, message| full_message(attribute, message) }
        values.flatten
      end

#      # Returns a full message for a given attribute.
#      #
#      #   user.dirt.full_message(:name)  # =>
#      #     "Added John Doe as a name"
#      def full_message(attribute, message)
#        return message if attribute == :base
#        attr_name = attribute.to_s.gsub('.', '_').humanize
#        attr_name = @base.class.human_attribute_name(attribute, :default => attr_name)
#        I18n.t(:"errors.format", {
#            :default   => "%{attribute} %{message}",
#            :attribute => attr_name,
#            :message   => message
#          })
#      end

      # Translates a dirty message in its default scope
      # (<tt>activemodel.dirty.messages</tt>).
      #
      # Dirty messages are first looked up in <tt>models.MODEL.attributes.ATTRIBUTE.MESSAGE</tt>,
      # if it's not there, it's looked up in <tt>models.MODEL.MESSAGE</tt> and if that is not
      # there also, it returns the translation of the default message
      # (e.g. <tt>activemodel.errors.messages.MESSAGE</tt>). The translated model name,
      # translated attribute name and the value are available for interpolation.
      #
      # When using inheritance in your models, it will check all the inherited
      # models too, but only if the model itself hasn't been found. Say you have
      # <tt>class Admin < User; end</tt> and you wanted the translation for
      # the <tt>:blank</tt> error message for the <tt>title</tt> attribute,
      # it looks for these translations:
      #
      # * <tt>activemodel.dirty.models.admin.attributes.title.blank</tt>
      # * <tt>activemodel.dirty.models.admin.blank</tt>
      # * <tt>activemodel.dirty.models.user.attributes.title.blank</tt>
      # * <tt>activemodel.dirty.models.user.blank</tt>
      # * any default you provided through the +options+ hash (in the <tt>activemodel.dirty</tt> scope)
      # * <tt>activemodel.dirty.messages.blank</tt>
      # * <tt>dirty.attributes.title.blank</tt>
      # * <tt>dirty.messages.blank</tt>
      #
      def generate_message(attribute, type = :invalid, options = {})
        type = options.delete(:message) if options[:message].is_a?(Symbol)

        if @base.class.respond_to?(:i18n_scope)
          defaults = @base.class.lookup_ancestors.map do |klass|
            [ :"#{@base.class.i18n_scope}.dirty.models.#{klass.model_name.i18n_key}.attributes.#{attribute}.#{type}",
              :"#{@base.class.i18n_scope}.dirty.models.#{klass.model_name.i18n_key}.#{type}" ]
          end
        else
          defaults = []
        end

        defaults << options.delete(:message)
        defaults << :"#{@base.class.i18n_scope}.dirty.messages.#{type}" if @base.class.respond_to?(:i18n_scope)
        defaults << :"dirty.attributes.#{attribute}.#{type}"
        defaults << :"dirty.messages.#{type}"

        defaults.compact!
        defaults.flatten!

        key = defaults.shift
        value = (attribute != :base ? @base.send(:read_attribute_for_cleaning, attribute) : nil)

        options = {
          :default => defaults,
          :model => @base.class.model_name.human,
          :attribute => @base.class.human_attribute_name(attribute),
          :value => value
        }.merge(options)

        I18n.translate(key, options)
      end

      private
      def normalize_message(attribute, message, options)
        message ||= :invalid

        if message.is_a?(Symbol)
          generate_message(attribute, message, options.except(*CALLBACKS_OPTIONS))
        elsif message.is_a?(Proc)
          message.call
        else
          message
        end
      end
        
    end  
  end
end