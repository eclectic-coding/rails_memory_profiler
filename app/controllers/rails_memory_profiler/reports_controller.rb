module RailsMemoryProfiler
  class ReportsController < ActionController::Base
    protect_from_forgery with: :null_session
    layout "rails_memory_profiler/application"
    helper RailsMemoryProfiler::ApplicationHelper

    before_action :check_dashboard_enabled

    SORTABLE_COLUMNS = %w[path controller allocated_objects retained_objects duration_ms recorded_at].freeze

    def index
      reports = ReportStore.all

      respond_to do |format|
        format.json { render json: reports }
        format.html do
          @sort      = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "recorded_at"
          @direction = params[:direction] == "asc" ? "asc" : "desc"
          @reports   = sorted(reports, @sort, @direction)
        end
      end
    end

    def show
      @report = ReportStore.find(params[:id])

      respond_to do |format|
        format.html
        format.json do
          if @report
            render json: @report
          else
            render json: { error: "Report not found" }, status: :not_found
          end
        end
      end
    end

    private

      def sorted(reports, sort, direction)
        sorted = reports.sort_by { |r| r[sort.to_sym] || 0 }
        direction == "asc" ? sorted : sorted.reverse
      end

      def check_dashboard_enabled
        head :forbidden unless RailsMemoryProfiler.config.dashboard_enabled
      end
  end
end
