Rails.application.routes.draw do
  get '/', to: 'basic#default'
  get 'health', to: 'health#check'
  get 'health/detailed', to: 'health#detailed_check'

  # Basic test scenarios
  get 'basic/default', to: 'basic#default'
  get 'basic/fibonacci', to: 'basic#fibonacci'

  # Distributed tracing test scenarios
  get 'distributed/origin', to: 'distributed#origin'
  get 'distributed/intermediate', to: 'distributed#intermediate'
  get 'distributed/destination', to: 'distributed#destination'

  # Job test scenarios
  post 'jobs', to: 'jobs#create'
end
