module ActAsDirty
  class Railtie < Rails::Railtie
    initializer 'act_as_dirty' do
      ActiveSupport.on_load :active_record do
        include ActAsDirty::ActiveModel::Cleans
        include ActAsDirty::ActiveRecord::Cleans
      end
    end
  end
end