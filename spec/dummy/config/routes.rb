Rails.application.routes.draw do
  mount RailsMemoryProfiler::Engine => "/rails/memory"
end
