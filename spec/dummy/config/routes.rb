Rails.application.routes.draw do
  mount RailsMemoryProfiler::Engine => "/rails_memory_profiler"
end
