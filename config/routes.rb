RailsMemoryProfiler::Engine.routes.draw do
  resources :reports, only: [:index, :show]
end
