module RailsMemoryProfiler
  class StoreController < BaseController
    def destroy
      ReportStore.clear
      redirect_to reports_path
    end
  end
end
