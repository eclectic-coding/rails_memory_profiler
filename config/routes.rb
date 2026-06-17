RailsMemoryProfiler::Engine.routes.draw do
  resources :reports, only: [:index, :show]
  resource  :comparison, only: [:show]
end
