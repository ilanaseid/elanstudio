require 'line_preferable'

#puts 'in preferable override decorator'

Spree::Preferences::ScopedStore.class_eval do 

  def store
    TheLinePreferences::Store.instance
  end
end