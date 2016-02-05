# Use singleton class Spree::Preferences::Store.instance to access
#
# StoreInstance has a persistence flag that is on by default,
# but we disable database persistence in testing to speed up tests
#

require 'singleton'

module ElanStudioPreferences

  class StoreInstance
    attr_accessor :persistence

    def initialize
      @cache = Hash.new 
      @persistence = false
    end
    
    def set(key, value, type=nil)
      @cache.store(key, value)
      persist(key, value)
    end
    alias_method :[]=, :set

    def exist?(key)
      @cache.has_key?(key) ||
      should_persist? && Spree::Preference.where(:key => key).exists?
    end

    def get(key)
      # return the retrieved value, if it's in the cache
      # use unless nil? incase the value is actually boolean false
      #
      unless (val = @cache[key]).nil?
        return val
      end

 
      if should_persist?
        # If it's not in the cache, maybe it's in the database, but
        # has been cleared from the cache

        # does it exist in the database?
        if preference = Spree::Preference.find_by_key(key)
          # it does exist
          val = preference.value
        else
          # use the fallback value
          val = yield
        end

        # Cache either the value from the db or the fallback value.
        # This avoids hitting the db with subsequent queries.
        @cache.store(key, val)

        return val
      else
        yield
      end    
    end
    alias_method :fetch, :get

    def delete(key)
      @cache.delete(key)
      destroy(key)
    end

    def clear_cache
      @cache.clear
    end

    private

    def persist(cache_key, value)
      return unless should_persist?

      preference = Spree::Preference.where(:key => cache_key).first_or_initialize
      preference.value = value
      preference.save
    end

    def destroy(cache_key)
      return unless should_persist?

      preference = Spree::Preference.find_by_key(cache_key)
      preference.destroy if preference
    end

    def should_persist?
      @persistence and Spree::Preference.table_exists?
    end

  end

  class Store < StoreInstance
    include Singleton
  end

end
