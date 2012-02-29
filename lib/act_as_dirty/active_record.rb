require 'act_as_dirty/active_model'
require 'act_as_dirty/active_record/cleans'

module ActAsDirty  
  module ActiveRecord
    extend ActiveSupport::Autoload    
    autoload :Cleans    
  end
end