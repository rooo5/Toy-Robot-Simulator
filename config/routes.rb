Rails.application.routes.draw do
  namespace :api do
    post 'robot/orders'
  end
end