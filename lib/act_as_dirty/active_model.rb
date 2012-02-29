require 'act_as_dirty/active_model/cleaner'
require 'act_as_dirty/active_model/cleans'
require 'act_as_dirty/active_model/dirt'

module ActAsDirty  
  module ActiveModel
    extend ActiveSupport::Autoload
    
    autoload :Cleans
    autoload :Cleaner
    autoload :Dirt
  end
end