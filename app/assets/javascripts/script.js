

function changeList(tweet_data){
    var data = {"authenticity_token":$("*[name=authenticity_token]").val(), "tweet_data": tweet_data};

    $.ajax({
	url : "/tweet/changelist",
	type: "POST", 
        data: data,
        cache : false,
	dataType : 'script',
	error: function() {
    	    message(0,"ERROR: 再生リストの読み込みに失敗しました。");
	}
    });
}



function newTweet(tweet,num,data){
    var len = tweet.length;
    var non = len;
    var flag;
    for(i=0;i<len;i++)	if(tweet[i] == null)non--;

    if(non<num)flag = true;
    else flag = false;

    if(flag){ 
	
	$.ajax({
	    url: "/tweet/newtweet", 	// tweetコントローラ内のnewtweetにアクセス。
	    type: "POST", 
	    data: data,
	    dataType : 'script',
	    error: function() {
		message(0,"ERROR: 通信エラーが発生しました。時間をおいてもう一度操作をおこなってください。");
	    },
	    success: function() {
		message(0,"INFO: TIMELINEにツイートが追加されました。");
	    }
	});
    }

}

function tweetDelete(tweet){
    var len = tweet.length; 
    ret = confirm("本当に削除しますか？");
    if (ret == true){
	for(i=0;i<len;i++){
	    str = "#";
	    if(document.chbox.elements[i].checked){
		delete tweet[i];
		str+= document.chbox.elements[i].value;
		$(str).fadeOut();
	    }

	}
    }else{
	alert("キャンセルしました。");
    }
}
function measureTime(time){
    var msecPerMinute = 1000 * 60;
    var msecPerHour = msecPerMinute * 60;
    var msecPerDay = msecPerHour * 24;
    var days = Math.floor(time / msecPerDay );
    time = time - (days * msecPerDay );
    var hours = Math.floor(time / msecPerHour );
    time = time - (hours * msecPerHour );
    var minutes = Math.floor(time / msecPerMinute );
    time = time - (minutes * msecPerMinute );
    var seconds = Math.floor(time / 1000 );
    if(days>0)date = days+"日前";
    else if(hours>0)date = hours+"時間前";
    else if(minutes>0)date = minutes +"分前";
    else date = seconds +"秒前";
    return date
}

function selectTweet(name,num){
    var elem = document.getElementById(name);
    if(document.chbox.elements[num].checked==true){
	elem.className = "tweetBox check";
    }else{
	elem.className = "tweetBox no_check";
    }
}

function timeLine(tweet){
    var time = new Date();
    var str = new String();
    var len = tweet.length;
    // こちらで配列が空かどうかの判定はできない
    for(var i=0;i<len;i++){
	date = measureTime(time - Date.parse(tweet[i][3]));
	str+='<li><div class="tweetBox no_check" id="c'+i+'"><label><input type="checkbox" value="c'+i+'" onclick="selectTweet('+"'c"+i+"'"+','+i+')" /><div class="imageBox">'+tweet[i][0]+'</div><div class="tweet"><div class="username">'+tweet[i][1]+'</div><div class="userid"> '+tweet[i][2]+'</div><div class="tweetTime">'+date+'</div><div class="tweetText">'+tweet[i][4]+'</div><div class="tweetAction"><a href="https://twitter.com/intent/tweet?in_reply_to='+tweet[i][5]+'" target="_blank">Reply</a> <a href="https://twitter.com/intent/retweet?tweet_id='+tweet[i][5]+'">Retweet</a> <a href="https://twitter.com/intent/favorite?tweet_id='+tweet[i][5]+'">Favorite</a></div></div></label></div></li>';
    }
    return str;
}

function timeLine_first(tweet){
    var str = new String();
    var len = tweet.length;
    // こちらで配列が空かどうかの判定はできない
    for(var i=0;i<len;i++){
	str+='<li><div class="tweetBox no_check" id="c'+i+'"><label><input type="checkbox" value="c'+i+'" onclick="selectTweet('+"'c"+i+"'"+','+i+')" /><div class="tweetText">'+tweet[i]+'</div></div></label></div></li>';
    }
    return str;
}

function setTweet(BFbox){
    var bflen = BFbox.length;
	samplenum=3;
    var AFbox = new Array();
	
    for(i=0;i<bflen;i++){
	if(BFbox[i] != null){
	    AFbox.push(BFbox[i]);
	}
    }
    return AFbox;	
}



function message(type,msg){
    var txt = "";
    switch(type){
    case 0:				// エラー
	break;
    case 1:
	txt = "PLAYING: " ; 	// 動画情報
	break;
    case 3:
	break;
    default:
    }
    txt = txt + msg + "\n" + document.result.textarea.value;
    document.result.textarea.value = txt;
}
function setNewMovie(old,new_movie){
	video_list = [old[1],old[2],new_movie];
}

function getMovieId(list){
	return list[1][2];
}
function getMovieName(list){
	return list[1][0];
}
function getMovieUrl(list){
	return list[1][1];
}
function nowMovie(list){
	return list[0];
}

function tweetButton(list){
	var str;
	if(list==null){
		str =  '<a href="https://twitter.com/intent/tweet?button_hashtag=nowplaying&text=" class="twitter-hashtag-button" data-size="large" data-url="" >Tweet #nowplaying</a>';
	}else{
		str =  '<a href="https://twitter.com/intent/tweet?button_hashtag=nowplaying&text='+ list[0] +'" class="twitter-hashtag-button" data-size="large" data-url="'+list[1]+'" >Tweet #nowplaying</a>';
	}
	return str;
}
