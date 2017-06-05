--###################################
--#									#
--#			UnCode Bot				#
--#									#
--###################################

--env
__debug=true
if __debug then	
  function print(x) weechat.print(debug_buffer,x)end
end

--hook #hook table contain
hook={}
r_name={}
e_name={}
fuc={}
fuc["unknow"]=function(buffer,username)
				weechat.command(buffer,"/msg " .. username .." Command unfound")
			  end
fuc["update"]=function (buffer,username) 
  				os.execute("/home/shared/UnBot/update.sh")
				weechat.command(buffer,"/msg "..username.." updated!")
				weechat.command(buffer,"/lua reload UnBot")
			  end
fuc["ghc"]=function (buffer,username,args)
  				local filename=string.match(args,"(%s+)")
				if not filename then return  end
				os.execute("cd /home/shared/UnBot/haskell/;ghc "..filename.." >> result.out")
				local file=io.open("/home/shared/UnBot/haskell/result.out")
				local str=file:read("*a")
				weechat.command(buffer,"/msg "..username.." "..str)
			  end
				

function checkandrun(data, signal, signal_data)
  nick = weechat.info_get("irc_nick_from_host", signal_data)
  buffer =weechat.info_get("irc_buffer" , signal_data)
  server = string.match(signal,"(.-),")
  channel = string.match(signal_data,"(#[^ ]+)")
  local mynick = weechat.info_get("irc_nick", server)
  if not channel then	return weechat.WEECHAT_RC_OK end
  local ma_nick,command=string.match(signal_data,"[^ ]+ [^ ]+ #[^ ]+ :([%a%d_]+): -@([^ ]+)")
  local _,_,args=string.match(signal_data,"[^ ]+ [^ ]+ #[^ ]+ :([%a%d_]+): -@([^ ]+) ([^ ]+)")
  weechat.print(debug_buffer,signal_data)
  if not ma_nick then return end
  if not command then return end
  if not args then args='' end
  if __debug then	if ma_nick==mynick then	weechat.print(debug_buffer,"nick:".. nick.." command:"..command.." args:"..args) end
  end
  buffer = weechat.info_get("irc_buffer",server..","..channel)
  if ma_nick==mynick then 
	if command  then
	  if fuc[command] then 
	  	fuc[command](buffer,nick,args)
	  else
		fuc["unknow"](buffer,nick,args)
	  end
	end
  end
end

function respond(data,buffer,args)
  lastname=r_name[buffer]
  if not lastname then	weechat.print(buffer,"You got no friend!haha") return weechat.WEECHAT_RC_OK end
  weechat.command(buffer,"/say "..lastname..":"..args)

  return weechat.WEECHAT_RC_OK
end

--debug#for debug
function buffer_input_cb(data,buffer,input_data)
  weechat.print(buffer,input_data)
  local tmp=load(input_data)
  if tmp then	tmp() end
  return weechat.WEECHAT_RC_OK
end
function buffer_close_cb(data,buffer)
  return weechat.WEECHAT_RC_OK
end

--Register
weechat.register("UnBot","acoret@126.com","1.0","GPL","Unbot","","UTF-8")
weechat.hook_signal("*,irc_in2_privmsg", "checkandrun","")
if __debug then
  debug_buffer=weechat.buffer_new("debug_respond", "buffer_input_cb","","buffer_close_cb","")
  weechat.buffer_set(debug_buffer,"title","debug for respond")
  weechat.buffer_set(debug_buffer, "localvar_set_no_log", "1")
end
