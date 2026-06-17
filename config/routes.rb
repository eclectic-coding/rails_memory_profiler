RailsMemoryProfiler::Engine.routes.draw do
  resources :reports, only: [:index, :show]
  resource  :comparison, only: [:show]
  resource  :store,      only: [:destroy], controller: "store"
end
