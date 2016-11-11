# frozen_string_literal: true
Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    resources :widgets, path: 'widget'

    get 'info', to: 'info#info'
    get 'ping', to: 'info#ping'
  end
end
