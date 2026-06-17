RailsMemoryProfiler::Engine.routes.draw do
  resources :reports, only: [:index, :show] do
    collection do
      delete :clear
    end
  end
  resource :comparison, only: [:show]
end
