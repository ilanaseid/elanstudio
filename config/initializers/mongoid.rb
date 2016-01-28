Mongoid.logger = Rails.logger
Moped.logger = Rails.logger

module Mongoid
  module Scopable
    module ClassMethods
      def check_scope_name(name)
      end
    end
  end
end
