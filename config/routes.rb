RailsMemoryProfiler::Engine.routes.draw do
  resources :reports, only: [:index, :show] do
    collection do
      get :compare
    end
  end
end
