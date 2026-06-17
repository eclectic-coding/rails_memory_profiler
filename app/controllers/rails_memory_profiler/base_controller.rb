module RailsMemoryProfiler
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session
    layout "rails_memory_profiler/application"
    helper RailsMemoryProfiler::ApplicationHelper

    before_action :check_dashboard_enabled

    private

      def check_dashboard_enabled
        head :forbidden unless RailsMemoryProfiler.config.dashboard_enabled
      end
  end
end
