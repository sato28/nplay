# -*- coding: utf-8 -*-
class TweetController < ApplicationController

  include TweetHelper


  ##########################################################
  #                      changelist                        #
  ##########################################################

  def changelist
    movie = Array.new
    movie = Marshal.load(Marshal.dump(list_update(params[:tweet_data])))
    if movie.blank? then
      @movie_add = nil
    else 
      @movie_add = Marshal.load(Marshal.dump(movie))
    end
    p "movie_add=" , @movie_add
  end


  ##########################################################
  #                        newtweet                        #
  ##########################################################

  def newtweet
    @tag_v   = params[:tag2]
    @andOr_v = params[:andOr2]
    @word_v  = params[:word2]
    @scope_v = params[:scope2]
    @flag_v  = params[:flag]
    
    if signed_in? && params[:flag]=="start1"

      Twitter.configure do |cnf|
        cnf.consumer_key = "MMpDXk66Gd7PN5s8boCg3w"
        cnf.consumer_secret = "hv9HfRT6G1t1UgWhsOi9uBB0O9mC9SrZSrpVHVWxag"
        cnf.oauth_token = session[:oauth_token]
        cnf.oauth_token_secret =  session[:oauth_token_secret]
      end


      tweet_v = Array.new #=>検索結果を格納する配列
      tweet   = Array.new
      @tweet  = Array.new

      #入力
      t_sel  = @tag_v
      s_sel  = @andOr_v.to_i
      r_sel  = @scope_v.to_i
      s_word = @word_v

      if s_sel == 1 then
        result_word = s_word + t_sel
      elsif s_sel == 2 then
        s_word2 = s_word.gsub(/　/, " ")
        s_word3 = s_word2.gsub(/ /, " OR ") 
        result_word = s_word3 + t_sel
      end
      @ss_word = result_word


      ######################## 全体 #########################
      case r_sel
      when 1 then 
        tweet_v = Twitter.search(result_word, :count => 10, :result_type => "recent").results
      else
        tweet_v = Marshal.load(Marshal.dump(search_personal(t_sel, s_sel, r_sel, s_word)))
      end
      begin

        tweet_v.each do |status|
          text = status['full_text']

          # ハッシュタグのリンク作成
          status.hashtags.each do |hash|
            tag = "#" + hash.text
            # 引数を使って正規表現にするには、#{引数}と書く
            text=text.gsub(/#{tag}/,"<a href='http://twitter.com/search?q=%23"+hash.text+"&src=hash' target='_blank'>"+tag+"</a>")
          end

          name = text.scan(/@.*?\s/)
          name.each do |reply|
            text=text.gsub(/#{reply}/,"<a href='http://twitter.com/"+reply+"' target='_blank'>"+reply+'</a>')
          end
          # タイムラインをhtmlにして配列tweetに代入
          tweet <<  [Rinku.auto_link('<img width=50 alt="Icon" src='+status.user.profile_image_url+' />', :all, 'target="_blank"'),status.user.name,Rinku.auto_link("<a href='http://twitter.com/"+status.user.screen_name+"' target='_blank'>@"+status.user.screen_name+'</a>'),status.created_at,Rinku.auto_link(text, :all, 'target="_blank"'),status.id.to_s,status['full_text']]
          # 一番最後[4]にtweet原文を載せた。
        end

        # 検索ワードで Tweet を取得できなかった場合の例外処理
      rescue Twitter::Error::ClientError
        tweet = nil
      else

        @tweet = Marshal.load(Marshal.dump(tweet))
      end
      #################  signed_in してない時 ##################
    else
      @result = :not_signed_in
    end
  end


  ##########################################################
  #                         index                          #
  ##########################################################

  def index
    @tag_v   = params[:tag]
    @andOr_v = params[:andOr]
    @word_v  = params[:word]
    @scope_v = params[:scope]
    @flag_v  = params[:flag]
    
    if signed_in? && params[:flag]=="start1"

      Twitter.configure do |cnf|
        cnf.consumer_key = "MMpDXk66Gd7PN5s8boCg3w"
        cnf.consumer_secret = "hv9HfRT6G1t1UgWhsOi9uBB0O9mC9SrZSrpVHVWxag"
        cnf.oauth_token = session[:oauth_token]
        cnf.oauth_token_secret =  session[:oauth_token_secret]
      end

      tweet_v = Array.new #=>検索結果を格納する配列
      tweet_rev = Array.new
      tweet   = Array.new
      @tweet  = Array.new

      #入力
      t_sel  = @tag_v
      s_sel  = @andOr_v.to_i
      r_sel  = @scope_v.to_i
      s_word = @word_v

      if s_sel == 1 then
        result_word = s_word + t_sel
      elsif s_sel == 2 then
        s_word2 = s_word.gsub(/　/, " ")
        s_word3 = s_word2.gsub(/ /, " OR ") 
        result_word = s_word3 + t_sel
      end
      @ss_word = result_word


      ######################## 全体 #########################
      case r_sel
      when 1 then 
        tweet_v = Twitter.search(result_word, :count => 15, :result_type => "recent").results
      else
        tweet_v = Marshal.load(Marshal.dump(search_personal(t_sel, s_sel, r_sel, s_word)))
      end
      begin
        i=0
        movie = Array.new
        tNum = 0
        mNum = 0
        tweet_v.each do |status|
          text = status['full_text']
          if mNum<4 then
            movie_save = Marshal.load(Marshal.dump(list_update(text)))
            if movie_save.blank? then
            elsif movie_save[2] == "url" then
            else 
              if mNum<3 then
                movie[mNum] = Marshal.load(Marshal.dump(movie_save))
              end
              status.hashtags.each do |hash|
                tag = "#" + hash.text
                # 引数を使って正規表現にするには、#{引数}と書く
                text=text.gsub(/#{tag}/,"<a href='http://twitter.com/search?q=%23"+hash.text+"&src=hash' target='_blank'>"+tag+"</a>")
              end

              name = text.scan(/@.*?\s/)
              name.each do |reply|
                text=text.gsub(/#{reply}/,"<a href='http://twitter.com/"+reply+"' target='_blank'>"+reply+'</a>')
              end

              # タイムラインをhtmlにして配列tweetに代入
              tweet <<  [Rinku.auto_link('<img width=50 alt="Icon" src='+status.user.profile_image_url+' />', :all, 'target="_blank"'),status.user.name,Rinku.auto_link("<a href='http://twitter.com/"+status.user.screen_name+"' target='_blank'>@"+status.user.screen_name+'</a>'),status.created_at,Rinku.auto_link(text, :all, 'target="_blank"'),status.id.to_s,status['full_text']]
              mNum += 1
            end
          else

            status.hashtags.each do |hash|
              tag = "#" + hash.text
              # 引数を使って正規表現にするには、#{引数}と書く
              text=text.gsub(/#{tag}/,"<a href='http://twitter.com/search?q=%23"+hash.text+"&src=hash' target='_blank'>"+tag+"</a>")
            end

            name = text.scan(/@.*?\s/)
            name.each do |reply|
              text=text.gsub(/#{reply}/,"<a href='http://twitter.com/"+reply+"' target='_blank'>"+reply+'</a>')
            end

            # タイムラインをhtmlにして配列tweetに代入
            tweet <<  [Rinku.auto_link('<img width=50 alt="Icon" src='+status.user.profile_image_url+' />', :all, 'target="_blank"'),status.user.name,Rinku.auto_link("<a href='http://twitter.com/"+status.user.screen_name+"' target='_blank'>@"+status.user.screen_name+'</a>'),status.created_at,Rinku.auto_link(text, :all, 'target="_blank"'),status.id.to_s,status['full_text']]
          end
        end
        # ハッシュタグのリンク作成

        # 検索ワードで Tweet を取得できなかった場合の例外処理
      rescue Twitter::Error::ClientError
        tweet = nil
      end

      if tweet.blank? then
        @tweet = nil
        @movie = nil
      else
        @movie = Marshal.load(Marshal.dump(movie))
        @tweet = Marshal.load(Marshal.dump(tweet))
      end

      #################  signed_in してない時 ##################
    else
      @result = :not_signed_in
    end
  end
end

