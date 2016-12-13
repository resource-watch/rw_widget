# frozen_string_literal: true
Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    resources :widgets, path: 'widget'

    get    'dataset/:dataset_id/widget',     to: 'widgets#index', constraints: DateableConstraint
    post   'widget/find-by-ids',             to: 'widgets#by_datasets'
    get    'dataset/:dataset_id/widget/:id', to: 'widgets#show'
    post   'dataset/:dataset_id/widget',     to: 'widgets#create'
    put    'dataset/:dataset_id/widget/:id', to: 'widgets#update'
    patch  'dataset/:dataset_id/widget/:id', to: 'widgets#update'
    delete 'dataset/:dataset_id/widget/:id', to: 'widgets#destroy'

    get 'info', to: 'info#info'
    get 'ping', to: 'info#ping'
  end
end
