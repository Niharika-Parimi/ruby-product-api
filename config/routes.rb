Rails.application.routes.draw do
  
  get '/products/search/:query', to: 'products#search'
  put '/products/:id', to: 'products#update'
  delete '/products/:id', to: 'products#destroy'
  get '/products/approval-queue', to: 'products#approval_queue'
  put '/products/approval-queue/:id/approve', to: 'products#approve'
  put '/products/approval-queue/:id/reject', to: 'products#reject'
  
 
  resources :products
  resources :approvals
end
