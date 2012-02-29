module ActAsDirty  
  
  module ActiveModel
    
    # == DirtyMe Cleaner
    #
    #
    class Cleaner
      attr_reader :options, :attributes

      # Accepts options that will be made available through the +options+ reader.
      def initialize(options)
        @attributes = Array.wrap(options[:attributes])
        raise ":attributes cannot be blank" if @attributes.empty?
        @options = options.freeze
      end

      # Performs cleaning on the supplied record. By default this will call
      # +clean_each+ to determine cleanliness therefore subclasses should
      # override +clean_each+ with cleaning logic.
      def clean(record)
        return unless record.changed?
        attributes.each do |attribute|
          next unless record.changes[attribute.to_s]
          clean_each(record, attribute)
        end
      end
      
      def clean_each(record, attribute)
        record.dirt.set(attribute, generate_message(record, attribute))
      end
              
      protected
      
      def generate_message record, attribute
        changes = record.read_changes_for_cleaning(attribute)
        if record.new_record?
          if @options[:create]
            message = @options[:create].call(record)
          else
            message = "Added #{record.class.to_s} #{attribute.to_s.humanize} #{changes[1]}"
          end
        elsif @options[:update]
          message = @options[:update].call(record)
        else
          message = "Updated #{record.class.to_s} #{attribute.to_s.humanize} from #{changes[0]} to #{changes[1]}"
        end
        message
      end
      
    end    
  end
  
end