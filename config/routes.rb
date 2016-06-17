Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    resources :widgets

    get 'info', to: 'widgets#info'
    root        to: 'widgets#docs'
  end
end
