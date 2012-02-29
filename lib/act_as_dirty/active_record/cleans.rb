module ActAsDirty  
  module ActiveRecord    
    module Cleans
      extend ActiveSupport::Concern
      include ActAsDirty::ActiveModel::Cleans
      
      def save(options={})
        perform_cleanings(options)
        super
      end
      
      def clean?(context = nil)
        context ||= (new_record? ? :create : :update)
        output = super(context)
        dirt.empty? && output
      end
      
      def dirty?(context = nil)
        !clean?(context)
      end
      
      protected
      
      def perform_cleanings(options={})
        perform_cleaning = options[:clean] != false
        perform_cleaning ? clean?(options[:context]) : true
      end
      
    end    
  end  
end