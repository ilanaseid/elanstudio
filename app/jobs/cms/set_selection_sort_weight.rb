module CMS
  class SetSelectionSortWeight
    include Sidekiq::Worker

    def perform
      begin
        Selection.all.each do |selection|
          # run the callbacks, including set_sort_weight
          selection.save!
        end
      rescue => e
        Airbrake.notify(e) if defined?(Airbrake)
      end
    end

  end
end
