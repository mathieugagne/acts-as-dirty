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
        changes = format_values(changes, record.class.columns_hash[attribute.to_s].type) if @options[:using]
        if record.new_record?
          if @options[:create]
            message = @options[:create].call(record)
          else
            message = "Added #{record.class.to_s} #{attribute.to_s.humanize} #{changes[1]}"
          end
        elsif @options[:update]
          message = @options[:update].call(record)
        elsif changes[0].nil?
          message = "Updated #{record.class.to_s} #{attribute.to_s.humanize} to #{changes[1]}"
        else
          message = "Updated #{record.class.to_s} #{attribute.to_s.humanize} from #{changes[0]} to #{changes[1]}"
        end
        message
      end
      
      def format_values changes, type
        if @options[:using] and @options[:using].is_a? Array
          if type == :boolean
            changes[0] = changes[0] ? @options[:using][0] : @options[:using][1] if changes[0]
            changes[1] = changes[1] ? @options[:using][0] : @options[:using][1] if changes[1]
          else
            changes[0] = @options[:using][changes[0]] if changes[0]
            changes[1] = @options[:using][changes[1]] if changes[1]
          end      
        end
        changes
      end
      
    end    
  end
  
end