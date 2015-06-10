# -*- coding: utf-8 -*-
Nplay::Application.routes.draw do
  get "sessions/callback"

  # match ':controller(/:action(/:id))(.:format)'

  root :to => "tweet#index"
  # get "tweet/input"
  # post "tweet/update"
  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy"
  post "tweet/index"
  get "tweet/index"
  post "tweet/tl_search"
  get "tweet/time_line"
  post "tweet/time_line"

  # tl更新用
  match "tweet/newtweet" => "tweet#newtweet"
  match "tweet/changelist" => "tweet#changelist"
  match "tweet/getlist" => "tweet#getlist"

end
