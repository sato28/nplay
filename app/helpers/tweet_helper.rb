# -*- coding: utf-8 -*-
module TweetHelper

  # tweet内容を受け取って、それをカット→動画検索かける
  def list_update(str)
    movie = ["", "", ""]

    tweet_c = cut_tweet(str)
    p "name=",tweet_c
    if tweet_c.blank? then
      return nil
    else
      movie = Marshal.load(Marshal.dump(get_movie(tweet_c)))
    return movie
    end
  end



  #############################################################
  #############################################################


  #つぶやきにタグが含まれるか判別する関数
  def check_tag(word, t_sel)
    case t_sel
    when " #nowplaying" then   
      if /#(n|N)ow(\s)*(p|P)lay(ing)*/ =~ word then

        return true
      end
    when " #なうぷれ" then
      if /#なうぷれ/ =~ word then
        return true
      end
    else
      if /#(n|N)ow(\s)*(p|P)lay(ing)*/ =~ word then
        
        return true
      end
      if /#なうぷれ/ =~ word then
        return true
      end
    end
    return false

  end


  # #OR検索用関数
  # def check_or(word, s_words) 
  #   size = s_words.size #検索単語の数
  #   j = 0
  #   while j < size 
  #     check = word.include?(s_words[j]) #検索ワードがあるか？
  #     if check == true 
  #       return true
  #     end
  #     j = j+1
  #   end   
  # end


  #OR検索用関数
  def check_or(word, s_words) 
    s_words.each do |s|
      if word.slice(/#{s}/).blank? then
      else
        return true
      end
    end
      return false
  end

  #and検索用関数
  def check_and(word, s_words)
    s_words.each do |s|
      if word.slice(/#{s}/).blank? then
        return false
      else
        word = word.gsub(/#{s}/,"");
      end
    end
    return true
  end

  # #and検索用関数
  # def check_and(word, s_words)
  #   size = s_words.size #iは検索単語の数
  #   j = 0
  #   while j < size 
  #     check = word.include?(s_words[j]) #検索ワードがあるか？
  #     if check != true 
  #       break
  #     end
  #     j = j+1
  #     if size == j #すべての検索ワードとマッチした場合
  #       return true 
  #     end
  #   end
  # end


  #フォロワーもしくは自分のツイートから検索する関数。引数は(検索ワード、 検索範囲、 検索モード、 検索タグ)
  def search_personal(t_sel, s_sel, r_sel, s_word)
      # Twitter.configure do |cnf|
      #   cnf.consumer_key = "pk7CYsiSeTGc1ecFjaYvgw"
      #   cnf.consumer_secret = "I4jxfgka4F1nTdKrUuqtRROxuVGTcsiHtDKFZkUAs"
      #   cnf.oauth_token = "1262850542-sQfxhJPB56mpN2yIbsj7Z16BSawNjHQKZcAXMRw"
      #   cnf.oauth_token_secret = "Ob5eHktcf5fXoPkYeZSTkbjW3a0FhVzGKq6fublGzY4"
      # end

      Twitter.configure do |cnf|
        cnf.consumer_key = "MMpDXk66Gd7PN5s8boCg3w"
        cnf.consumer_secret = "hv9HfRT6G1t1UgWhsOi9uBB0O9mC9SrZSrpVHVWxag"
        cnf.oauth_token = session[:oauth_token]
        cnf.oauth_token_secret =  session[:oauth_token_secret]
      end

      # Twitter.configure do |cnf|
      #   cnf.consumer_key = "MMpDXk66Gd7PN5s8boCg3w"
      #   cnf.consumer_secret = "hv9HfRT6G1t1UgWhsOi9uBB0O9mC9SrZSrpVHVWxag"
      #   cnf.oauth_token = "1394030977-CUZQP639COta1cBplIdyOPTqnuePvmNbwoYQd94"
      #   cnf.oauth_token_secret = "NOjksia2Lc5GfdY0xlkTN4vAn0gdzt4iPjOdlZKoE"
      # end

    #変数  
    tag1 = 0 #使用するタグ
    tag2 = 0 #複数タグの時のみ使用
    tweet = Array.new #検索結果を格納する配列
    tl = Array.new(200) #TLから最新200件を格納する配列

    #最新のTLを200件取得   
    if r_sel == 2
      tl = Twitter.home_timeline({:count =>200})
    else
      tl = Twitter.user_timeline({:count =>200})
    end
    #入力された検索文字列を空白毎に単語で区切る
    s_word = s_word.gsub("　"," ")   
    s_words = s_word.split(nil) #全角の空白を半角の空白に変えてから空白ごとに区切る

    p "s_words=",s_words
    #入力が空白のみの場合、上の処理が行えないので検索ツイートを半角スペースを含むものとする。
    # if s_word == " "
    #   s_words[0] = " "
    # end

    #検索用変数
    size = tl.size
    i = 0
    j = 0
    str = 0 

    #検索部分
    if s_sel == 1 #AND検索
      while i < size
        str = tl[i].full_text #調べるツイートを格納
        tc = check_tag(str, t_sel) #指定したタグがついていればtrue

        if tc == true #指定したタグがついてた場合
      # p "TRUE"
          c = check_and(str, s_words)
          
          if c == true  #つぶやきがマッチした場合
            tweet << tl[i] 
            j = j+1
          end

          if j == 15
            return tweet
          end
        end
        i = i+1 #調べ終わったら次のツイートへ
      end
    elsif s_sel == 2 #OR検索
      while i < size
        str = tl[i].full_text #調べるツイートを格納
        tc = check_tag(str, t_sel) #指定したタグがついていればtrue

        if tc == true #指定したタグがついてた場合
          c = check_or(str, s_words) 

          if c == true  #つぶやきがマッチした場合
            tweet << tl[i] 
            j = j+1
          end

          if j == 15
            return tweet
          end
        end
        i = i+1 #調べ終わったら次のツイートへ
      end
    end

    return tweet #途中で30件に満たなかった場合
  end


  #############################################################
  #############################################################


  def get_movie(s)
    if s.blank? then 
    else 
      url = 'http://gdata.youtube.com/feeds/api/videos?'
      s = s.downcase.gsub(/\s/,"/")
      keywords ="q=" + s
      options = '&orderby=relevance&start-index=1&max-results=20&fomrat=5'

      url2 = URI.encode(url + keywords + options+"&v=2")
      uri = URI(url2)
      p uri
      box = Array.new
      doc = Nokogiri::XML(uri.read, nil, 'utf-8')   # XML解析のおまじない。uri.readでxmlを文書にしてる。
      doc.search('entry').each do |entry|
        box << [entry.search('title').text,entry.xpath('media:group/media:player').first['url']]
      end
      str2=nil
      movie = ["","",""]
      if box.blank? then
        box << ["title","url"]
      end

      if box[0][0].blank? then
        return  nil
      else
        movie[0] =  box[0][0] # 動画タイトル
      end
      str = box[0][1]

      bun = ["", ""] # 曲情報の仮置き場
      i = 0 # ループ脱出用
      # &以降　を削除
      while i == 0 do 
        if /&\S*/ =~ str then
          bun[0] = $`
          bun[1] = $'
          str = bun[0] + bun[1]
        else
          i = 1
        end
      end

      movie[1] = str # 動画URL

      str2 = str.gsub('http://www.youtube.com/watch?v=',"")
      p "str2=" ,str2

    end
      if str.blank? then
        return nil
        else
      movie[2] =  str2 # 動画ID
      end

    return movie

  end #get_movie


  #############################################################
  #############################################################


  def cut_tweet(str)
    @debug_str2 = str

    i = 0 # ループ脱出用
    tou = 0 # Q & A
    nami = 0 # 〜〜
    bou = 0 # -
    sura = 0 # /
    aru = 0 # A

    bun = ["", ""] # 曲情報の仮置き場
    namu = "" # 〜〜
    toe = "" # &
    are = "" # A とか  

    kari = "" # プログラム書き換え時に用いたりする仮置き場

    # program○○　を削除 
    if /\s(P|p)rogram\S+/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end

    # off vocal を削除
    if /(O|o)(F|f)(F|f)\s(V|v)(O|o)(C|c)(A|a)(L|l)/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end
    
    # nowplaying を削除
    while i == 0 do
      if /(n|N)ow(\s)*(p|P)lay(ing)*/ =~ str then 
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1 # i=1(=マッチしない)場合、ループから脱出
      end
    end

    i = 0 # 次のループ用にiをリセットしておく

    # ハッシュタグを削除
    while i == 0 do
      if /#(\S)*/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + "  " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # @ユーザー名　を削除
    while i == 0 do 
      if /\s@\w*/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + "   " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # () （） [] <> 【】 を括弧の中身ごと削除
    while i == 0 do 
      if /\((\w|\s|:|\.|,)*\)|（(\w|\s|:|\.|,)*）|<(\.|\w|\s|:|,)*>|\[(\.|\w|\s|:|,)*\]/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + "  " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # (顔文字)　を削除
    # 弊害が発生しないか心配
    if /\(\S*\)/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + "  " + bun[1]
    end

    # 〜〜　
    if /～(\w|\s)*～/ =~ str then
      namu = $&
      nami = 1
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + "  " + bun[1]
    end

    # A** を削除
    if /\s[A-Z]\*+/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end

    # * " 「 」 ” “ を削除
    while i == 0 do 
      if /\*|\"|"|」|「|”|“|』|『/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # urlを削除
    while i == 0 do 
      if /(\S)*\/+(\S)+\.(\S)*|\.\S+\/+|\S*twitter\S*/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + "  " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # Q & A っていう曲名があったので対応しておく
    if /\s*[A-Z]\s*&\s*[A-Z]\s*/ =~ str then
      toe = $&
      tou = 1
    end

    # edit 英単語　を削除
    if /\s*(E|e)dit\s*–*\s*([A-Za-z]|\s)+/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + " " + bun[1]
    end

    # on albun 英語のアルバム名　を削除
    if /(o|O)(N|n)\salbum\s[A-Za-z]+('|\s|[A-Za-z]|∞|[0-9]|\.|(([A-Za-z]|[0-9])+\-([A-Za-z]|[0-9])+)|(\-([A-Za-z]|[0-9])+))*/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end

    # on album アルバム名 ラジオ名 ft. feet. best album new albumを削除
    # 英語ver
    while i == 0 do 
      if /(((O|o)(N|n)|(B|b)(E|e)(S|s)(T|t)|(N|n)(E|e)(W|w)|[0-9]st)(\s)(\w|\s)*((A|a)lbum|(R|r)adio|RADIO))|((\s(F|f)(T|t)(\.|\s)|(F|f)(E|e)(A|a)(T|t)\.*)\s*[A-Za-z]+('|\s|[A-Za-z]|∞|[0-9]|\.|(([A-Za-z]|[0-9])+\-([A-Za-z]|[0-9])+)|(\-([A-Za-z]|[0-9])+))*)/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # on album アルバム名 ラジオ名 ft. feet. best album new albumを削除
    # 日本語ver
    while i == 0 do
      if /(((O|o)(N|n)|(B|b)(E|e)(S|s)(T|t)|(N|n)(E|e)(W|w))\s*(\w|\s)*(アルバム|ラジオ))|(((F|f)t\.*|(F|f)eat\.*)\s*([一-龠]|[ぁ-ん]|[ァ-ヴ]|ー|・))+/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # サントラ名を消したかった
    # サントラ名のあとに曲名とか書いてあると消される
    if /(THE|the|The)(\s|[A-Za-z]|[0-9])*(SOUND|Sound|sound)\s(TRACK|Track|track)(\s|[A-Za-z]|[0-9])*(\w|\W)*$/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end

    # ラジオ名を消す試み
    if /on(\s|\w|[0-9]\.[0-9])*\s[A-Za-z]*radio/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + " " + bun[1]
    end

    # AM/FM 周波数　を削除
    if /((AM|am|FM|am)\s*[0-9]+\.[0-9]+|[0-9]+\.[0-9]+\s*(AM|am|FM|fm))/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + " " + bun[1]
    end

    # album: 英語のアルバム名 を削除
    if /(A|a)lbum:(\s|[A-Za-z]|・|')*/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + " " + bun[1]
    end

    # 日本語曲情報　- –　日本語曲情報　を抽出
    if /([a-zA-Z]|[0-9]|!|&|\?|☆|@|[一-龠]|[ぁ-ん]|[ァ-ヴ])*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%|∞)*((\s+(\-|−|–))|((\-|−|–)\s+)|(\s+(\-|−|–)\s+))([a-zA-Z]|[0-9]|!|&|\?|☆)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%|∞)*/ =~ str then
      bun[0] = $&
      str = bun[0]
      bou = 1
    end

    # 曲情報　- –　曲情報　を抽出
    if bou == 0 then
      if /(([a-zA-Z]|[0-9]|\s|&|!|\?|☆|,|\.)*([a-zA-Z])+([0-9]|!|%|・|,|\.)*([a-zA-Z])*((\s+(\-|−|–))|((\-|−|–)\s+)|(\s+(\-|−|–)\s+))([a-zA-Z])*([0-9]|ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%)*)|([a-zA-Z]|[0-9])*(ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|[a-zA-Z]|&|!|%)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%)*((\s+(\-|−|–))|((\-|−|–)\s+)|(\s+(\-|−|–)\s+))([a-zA-Z]|\s|&|!|\?|☆|,)*([a-zA-Z]|[0-9])+([a-zA-Z]|\s|&|!|\?|☆|,)*/ =~ str then
        bun[0] = $&
        str = bun[0]
        bou = 1
      end
    end

    # 英語の曲情報 -　英語の曲情報　を抽出
    if bou == 0 then
      if /('|☆|\s|&|[A-Za-z]|[0-9]|\.|\/|(([A-Za-z]|[0-9])+\-([A-Za-z]|[0-9])+))*[A-Za-z]+([0-9]|!|\?|%|・)*([a-zA-Z])*((\s+(\-|−|–))|((\-|−|–)\s+)|(\s+(\-|−|–)\s+))([a-zA-Z]|[0-9]|\s|&|!|\?|☆)*([A-Za-z])+([0-9]+:[0-6][0-9]|[A-Za-z]|[0-9]|\.|!|\?|\s|'|・|&|☆)*/ =~ str then
        bun[0] = $&
        str = bun[0]
        bou = 1
        if /[A-Za-z]+\s\s+([A-Za-z]|[0-9])+(\w|\s)*$/ =~ str then # 英単語 二個以上の空白 英文 文末
          # の場合、　二個以上の空白 英文  を削除
          if /\s\s+([A-Za-z]|[0-9])+(\w|\s)*$/ =~ str then
            bun[0] = $`
            str = bun[0]
          end
        end
      end
    end

    # .○○ を削除
    while i == 0 do 
      if /\s\.(\w)+/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 記号を削除
    while i == 0 do
      if /＼|‘|;|:|\[|\]|\^|\(|\)|\{|\}|\||→|←|↑|↓|♡|♥|\s'|'\s|【|】|\+|\^|<[0-9]*|>[0-9]*|:[A-Z]/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # RT listening to　を削除
    while i == 0 do
      if /^.+\s(R|r)(T|t)(\s|:)|\S*(L|l)isten(ing)*(\s)*to|(P|p)lay(ing)*\s*now|is\s*(P|p)lay(ing)*/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 曲情報と関係なさそうな日本語を削除
    # 曲情報まで消されないか心配
    while i == 0 do
      if /\S*聞く\S*|\S*聴く\S*|\S*聴いて\S*|\S*聞いて\S*|作曲者|アーティスト|曲名|歌手(名)*|再生(中)*|オリジナル\S*(MV|mv)|\S*サウンドトラック(\S|\s)*|\S+神曲\S*|\S*なうぷれ\S*|\S+ってみた\S*|\S*インスト\S*/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 検索したい単語以外でツイートに書かれてそうな英単語を削除
    # 曲情報まで消してしまう恐れあり。消そうか悩む
    while i == 0 do 
      if /(A|a)lbum|(S|s)ong|(A|a)rtist/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 音符を削除
    while i == 0 do
      if /♪|♫|♩|♬/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # コメントを消す努力
    # 2文以上の日本語を消す
    if /\S*([一-龠]|[ぁ-ん]|[ァ-ヴ]|、)+。([一-龠]|[ぁ-ん]|[ァ-ヴ]|、)+。\S*/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end

    # , 、のあとに空白があるとき、, 、を削除
    while i == 0 do 
      if /(,|、)\s/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else 
        i = 1
      end
    end

    i = 0

    # 前置詞が文末だったら前置詞削除
    while i == 0 do 
      if /\s((O|o)(N|n)|(I|i)(N|n)|(T|t)(O|o)|(B|b)(Y|y)|(A|a)(T|t)|(F|f)(O|o)(R|r)|(O|o)(F|f)|(W|w)(I|i)(T|t)(H|h)|(A|a)(B|b)(O|o)(U|u)(T|t))(\s)*$/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 前置詞が文のはじめにあったら削除
    while i == 0 do
      if /^(\s)*((O|o)(N|n)|(I|i)(N|n)|(T|t)(O|o)|(B|b)(Y|y)|(A|a)(T|t)|(F|f)(O|o)(R|r)|(O|o)(F|f)|(W|w)(I|i)(T|t)(H|h)|(A|a)(B|b)(O|o)(U|u)(T|t))\s/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i  = 1
      end
    end

    i = 0

    # 日本語の曲情報/日本語の曲情報
    if bou == 0 then
      if /([a-zA-Z]|[0-9]|!|&|\?|☆)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%|∞)*\s*(\/|／)\s*([a-zA-Z]|[0-9]|!|&|\?|☆)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%|∞)*/ =~ str then
        bun[0] = $&
        str = bun[0]
        sura = 1
      end
    end

    # 英語曲情報/日本語曲情報
    # 日本語曲情報/英語曲情報
    if bou == 0 then
      if sura == 0 then
        if /([a-zA-Z]|\s|&|!|\?|☆|[0-9]|\.)*[a-zA-Z]+([0-9]|[a-zA-Z]|\s|&|!|\?|☆|・|\-|\.)*(\s)*(\/|／)(\s)*([a-zA-Z]|[0-9])*(ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|[a-zA-Z]|&|!|%)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%)*|([a-zA-Z]|[0-9])*(ー|・|!|\?|%|&)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9]|ー|・|[a-zA-Z]|&|!|%)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|[a-zA-Z]|[0-9]|ー|・|&|!|\?|%)*(\s)*(\/|／)\s*([a-zA-Z]|\s|&|!|\?|☆|[0-9]|\.)*[a-zA-Z]+([0-9]|[a-zA-Z]|\s|&|!|\?|☆|\-|・|\.)*/ =~ str then
          bun[0] = $&
          str = bun[0]
          sura = 1
          if /[A-Za-z]+\s\s+([A-Za-z]|[0-9])+(\w|\s)*$/ =~ str then
            if /\s\s+([A-Za-z]|[0-9])+(\w|\s)*$/ =~ str then
              bun[0] = $`
              str = bun[0]
            end
          end
        end
      end
    end

    # 英語の曲情報/英語の曲情報
    if bou == 0 then
      if sura == 0 then
        if /([a-zA-Z]|\s|&|!|\?|☆|[0-9])*[a-zA-Z]+([0-9]|[a-zA-Z]|\s|&|!|\?|☆|・)*\s*(\/|／)+\s*([a-zA-Z]|\s|&|!|\?|☆|[0-9])*[a-zA-Z]+([0-9]|[a-zA-Z]|\s|&|!|\?|☆|・)*/ =~ str then
          bun[0] = $&
          str = bun[0]
          sura = 1
          if /[A-Za-z]+\s\s+([A-Za-z]|[0-9])+(\w|\s)*$/ =~ str then
            if /\s\s+([A-Za-z]|[0-9])+(\w|\s)*$/ =~ str then
              bun[0] = $`
              str = bun[0]
            end
          end
        end
      end
    end

    # from 日本語　を削除
    if /(From|FROM|from)\s*([一-龠]|[ぁ-ん]|[ァ-ヴ])+\S*/ =~ str then
      bun[0] = $`
      bun[1] = $'
      str = bun[0] + bun[1]
    end

    # 日本語　by　日本語　を抽出 
    if /([一-龠]|[ぁ-ん]|[ァ-ヴ]|\s)*(ー|・)*([一-龠]|[ぁ-ん]|[ァ-ヴ])+([0-9])*\s*(B|b)(Y|y)\s*([一-龠]|[ぁ-ん]|[ァ-ヴ])+(ー|・)*([一-龠]|[ぁ-ん]|[ァ-ヴ]|\s)*/ =~ str then
      bun[0] = $&
      str = bun[0]
    end

    # 日本語 by 英語
    # 英語 by 日本語
    if /((([A-Za-z]|[0-9]|・|\-|\s)*([A-Za-z])+[0-9]*\s*(B|b)(Y|y)\s*([一-龠]|[ぁ-ん]|[ァ-ヴ]|ー|・)+)|(([一-龠]|[ぁ-ん]|[ァ-ヴ]|ー|・)+\s*(B|b)(Y|y)\s*([A-Za-z])+([A-Za-z]|[0-9]|・|\-|\s)*))/ =~ str then
      bun[0] = $&
      str = bun[0]
    end

    # 前置詞 by on with from in を消す
    # 曲情報を消してしまうので要注意
    while i == 0 do
      if /\s((B|b)(Y|y)|(O|o)(N|n)|(W|w)(I|i)(T|t)(H|h)|(F|f)(R|r)(O|o)(M|m)|(I|i)(N|n))\s/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 消せなかったワードを無理やり消す
    while i == 0 do 
      if /(Y|y)our\s(H|h)it\s(M|m)usic\s(S|s)tation|(A|a)rmy\s(O|o)f\s(T|t)wo|NE1fm\s102\.5/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # 一文字で意味がありそうなものは消したくないからとっとく
    if tou == 0
      if /(\s(a|[A-Z]|[0-9])(\s|$))/ =~ str then 
        are = $&
        aru = 1
      end
    end

    # この時点までに削除されてなかった記号を削除
    while i == 0
      if /／|\/|\-|–|~|〜|~|\s\w(\s|$)|,,+|、、+|🙌|－|_/ =~ str then  
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    i = 0

    # さっきとっといた文字を加える。この処理をすると文章の順番が変になる
    if aru == 1 then
      str = str + " " + are
    end

    # Q & A を加える
    if tou == 1 then
      if /\s+&\s+/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      end
      str = str + " " + toe
    end

    # 〜〜　を追加
    if nami == 1 then
      str = str + " " + namu
    end

    # .のあとに空白があるとき、.を削除
    while i == 0 do 
      if /\.\s|\.$/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else 
        i = 1
      end
    end

    i = 0

    # 空白が2個以上続いてたら一個にする
    while i == 0 do 
      if /\s\s+/ =~ str then
        bun[0] = $`
        bun[1] = $'
        str = bun[0] + " " + bun[1]
      else
        i = 1
      end
    end

    # 行頭が空白だったら削除
    if /^\s+/ =~ str then
      bun[0] = $'
      str = bun[0]
    end

    # 行末が空白だったら削除
    if /\s+$/ =~ str then
      bun[0] = $`
      str = bun[0]
    end
    if str == "blank" then
      return nil
    end
    @debug_str3 = str
    p str
    return str

  end
end


