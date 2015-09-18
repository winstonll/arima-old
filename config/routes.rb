Arima::Application.routes.draw do

  get 'feed' => 'feed#index'
  get 'category' => 'feed#category'
  get 'cat' => 'feed#category_non_feed'
  post 'add_tag' => 'answers#add_tag'
  post 'add_comment' => 'answers#add_comment'

  get 'application' => 'application#long_poll'

  post 'category' => 'feed#category'
  post 'badge' => 'profiles#badge'
  post 'questions/:id' => 'answers#share_image_submit'

  # custom registration route
  devise_for :users, controllers: { registrations: "users/registrations" }
  get 'profile/edit' => 'profiles#edit'
  patch 'profile/:username' => 'profiles#update'
  get 'profile/:username' => 'profiles#show', :as => 'custom_show'

  #resource :profile, only: [:show, :edit, :update]

  get 'search' => "search#index"
  get 'gender' => "answers#gender"

  # constraint allows special characters in the route
  #get "users/:first_name:last_name:id" => "profiles#show", as: :profile_show , constraints: { first_name: /[a-zA-Z1-9\-]+/, last_name: /[a-zA-Z1-9\-]+/ }

  resources :categories, only: [:index, :show] do
    post 'show_recent' => "categories#show_recent"
    post 'show_popular' => "categories#show_popular"
  end

  resources :questions, only: [:show, :new] do
    resources :answers, only: [:new, :create]
  end

  resources :questions do
    member do
      put 'upvote' => "questions#upvote"
      put 'downvote' => "questions#downvote"
      put 'hide_share_modal' => "questions#hide_share_modal"
      put 'show_share_modal' => "questions#show_share_modal"
      get 'report'
    end
  end

  resources :questions, only: [:new, :create] do
    post 'questions/create' => "questions#create", as: :question
  end

  resources :answers, only: [:show] do
    post "share", on: :collection
    get  "thumb" => "answers#show_image"
  end

  #get "reports/:username"            => "reports#index", as: :reports_index
  #get "reports/:username/:answer_id" => "reports#show",  as: :reports_show

  # leaderboard
  get 'leaderboard' => "leaderboards#index"

  # admin lib
  scope :admin, as: :admin do
    get '' => "admins#index"

    scope :model, as: :model do
      get    ':model_name'          => "admins#model_index", as: :index
      get    ':model_name/new'      => "admins#model_new",   as: :new
      get    ':model_name/:id/edit' => "admins#model_edit",  as: :edit
      post   ':model_name'          => "admins#create",      as: :create
      put    ':model_name/:id/edit' => "admins#update",      as: :update
      delete ':model_name/:id'      => "admins#destroy",     as: :destroy
    end

    scope :extension, as: :extension do
      get  ':name' => "admins#extension"
      post ':name' => "admins#extension_post",  as: :post
    end
  end

  # for getting_started page
  get 'getting_started'                             => "getting_started#index",               as: :getting_started
  get 'intro_question/groups/:group_id/answers/new' => "answers#intro_question",              as: :intro_question
  get 'getting_started/country_stats'               => "getting_started#country_stats",       as: :home_country_stats
  get 'getting_started/intro_answer_graphs'         => "getting_started#intro_answer_graphs", as: :intro_answer_graphs
  get 'getting_started/age_stats'                   => "getting_started#age_stats",           as: :age_stats

  # forgot password
  resources :forgot_password

  get 'country'	=> "country#index", as: :country

  # simple/static pages
  get 'terms'   => "home#terms",   as: :terms
  get 'privacy' => "home#privacy", as: :privacy
  get 'credits' => "home#credits", as: :credits
  get 'about'   => "home#about",   as: :about
  get 'faq'     => "home#faq",     as: :faq
  get 'contact' => "home#contact", as: :contact

  # post 'submit_questions/create' => "submit_questions#create", as: :submit_question

  root 'home#index'
end
