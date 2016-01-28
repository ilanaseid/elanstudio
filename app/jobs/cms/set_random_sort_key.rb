module CMS
  class SetRandomSortKey
    include Sidekiq::Worker

    class All < SetRandomSortKey
      def perform
        ClearCMS::Content.descendants.each do |klass|
          Batch.perform_async(klass.to_s)
        end
      end
    end

    class Batch < SetRandomSortKey
      def perform(klass)
        klass.constantize.where(random_sort_key: nil).all.each do |x|
          x.set_random_sort_key
          x.save
        end
      end
    end
  end
end
