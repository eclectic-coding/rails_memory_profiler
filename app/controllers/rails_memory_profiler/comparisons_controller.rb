module RailsMemoryProfiler
  class ComparisonsController < BaseController
    def show
      ids     = Array(params[:ids]).first(2)
      reports = ids.map { |id| ReportStore.find(id) }.compact

      if reports.size < 2
        redirect_to reports_path
        return
      end

      @left, @right = reports

      respond_to do |format|
        format.html
        format.json { render json: { left: @left, right: @right } }
      end
    end
  end
end
