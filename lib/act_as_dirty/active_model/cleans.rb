module ActAsDirty
  module ActiveModel
    module Cleans
    
      extend ActiveSupport::Concern
      include ActiveSupport::Callbacks
      
      included do
        attr_accessor :cleaning_context
        define_callbacks :clean, :scope => :name
                
        class_attribute :_cleaners
        self._cleaners = Hash.new { |h,k| h[k] = [] }
      end
    
      module ClassMethods
        
        def act_as_dirty
          has_many :dirty_messages, :as => :dirtable, dependent: :destroy
          accepts_nested_attributes_for :dirty_messages, :reject_if => lambda { |a| a[:message].blank? }, :allow_destroy => true
        end
        
        def cleans(*attributes)
          defaults = attributes.extract_options!
          options = defaults.slice!(*_cleaning_default_keys)
          
          raise ArgumentError, 'Specify at least one attribute you would like DirtyMe to handle the message for' if attributes.empty?
          
          attributes = self.attribute_names.map(&:to_sym) if attributes.include? :all
          defaults.merge!(:attributes => attributes)
          
          attributes.each do |attr, options|           
            # Fails when db not up to date with code
            # raise ArgumentError, "The attribute '#{attr}' doesn't correspond to a column in the database" unless self.columns_hash[attr.to_s]            
            cleans_with(ActAsDirty::ActiveModel::Cleaner, defaults)
          end
        end
        
        def cleans_with(*args, &block)
          options = args.extract_options!
          args.each do |klass|
            cleaner = klass.new(options, &block)
            cleaner.setup(self) if cleaner.respond_to?(:setup)

            if cleaner.respond_to?(:attributes) && !cleaner.attributes.empty?
              cleaner.attributes.each do |attribute|
                _cleaners[attribute.to_sym] << cleaner
              end
            else
              _cleaners[nil] << cleaner
            end

            clean(cleaner, options)
          end
        end
        
        def clean(*args, &block)
          options = args.extract_options!
          if options.key?(:on)
            options = options.dup
            options[:if] = Array.wrap(options[:if])
            options[:if].unshift("cleaning_context == :#{options[:on]}")
          end
          args << options
          set_callback(:clean, *args, &block)
        end
        
        # List all trackers that are being used to create the message using
        def cleaners
          _cleaners.values.flatten.uniq
        end
        
        # List all validators that being used to validate a specific attribute.
        def cleaners_on(*attributes)
          attributes.map do |attribute|
            _cleaners[attribute.to_sym]
          end.flatten
        end

        # Copy validators on inheritance.
        def inherited(base)
          dup = _cleaners.dup
          base._cleaners = dup.each { |k, v| dup[k] = v.dup }
          super
        end
      
        protected
        
        def _cleaning_default_keys
          [:create, :update, :delete, :using, :allow_blank, :allow_nil]
        end

      end
      
      def dirt
        @dirt ||= Dirt.new(self)
      end
      
      def clean?(context= nil)
        current_context, self.cleaning_context = cleaning_context, context
        dirt.clear
        run_cleaners!
      ensure
        self.cleaning_context = current_context
      end
      
      def dirty?(context = nil)
        !clean?(context)
      end
      
      def read_changes_for_cleaning(key)
        [self.changes[key][0], self.changes[key][1]]
      end
        
      protected
          
      def run_cleaners!
        run_callbacks :clean
        dirt.empty?
      end
    end
  end
end