# -*- coding: utf-8 -*-
class SessionsController < ApplicationController
  def create
    begin
      auth = request.env["omniauth.auth"]
      session[:oauth_token] = auth.credentials.token
      session[:oauth_token_secret] = auth.credentials.secret
      session[:username] = auth.extra.access_token.params[:screen_name]
      Twitter.configure do |cnf|
        cnf.consumer_key = "MMpDXk66Gd7PN5s8boCg3w"
        cnf.consumer_secret = "hv9HfRT6G1t1UgWhsOi9uBB0O9mC9SrZSrpVHVWxag"
        cnf.oauth_token = session[:oauth_token]
        cnf.oauth_token_secret =  session[:oauth_token_secret]
      end
      session[:img] =Twitter.client.user.profile_image_url_https 
      redirect_to root_url, :notice => "Signed in!"
    rescue Timeout::Error, StandardError => e
    end
  end

  def destroy
    session[:oauth_token] = nil
    session[:oauth_token_secret] = nil
    session[:username] = nil
  	session[:img] =nil
    redirect_to root_url, :notice => "Signed out!"
  end
end
