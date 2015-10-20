# Chat commands engine for Nox Unimod 
--[[			About engine

Version: 2.0 ENG
Author: Herman Tafintsev aka Xandros Darkstorm
E-mail: germanapps@gmail.com
Skype: taf2530

			Reactions
This engine using following reactions:
REACTION LIST                |Will be called when happend this event
--------------------------------------------------------------------------------------------------------
ADVCHAT_DISABLED             |User sent a message, but sv_addchat is set to 0
ADVCHAT_NOCOMMANDS           |User sent a message, but commands base is empty
ADVCHAT_INVALID_ARGS_DATATYPE|onConPrint reaction works incorrectly (this error may occure if Unimod was 
                             |modified or reaction function was called manually).
ADVCHAT_INVALID_COMMAND      |User tried to use unknown command.
ADVCHAT_ONCOMPLETE           |Advchat's work done. This reaction is onConPrint redirection for other needs
                             |(for example, another onConPrint function)
--------------------------------------------------------------------------------------------------------
Do not modify reactions and variables inside this file!!! Override them instead!
]]--

--VARIABLES
sv_advchat = 0;
local ADVCHAT_CMDLIST = {};

--ENGINE REACTIONS (ITS NOT RECOMMENDED TO CHANGE THIS FUNCTIONS - USE OVERRIDE INSTEAD (SEE TOP COMMENT))
ADVCHAT_DISABLED = function()
print('Chat commands engine is disabled.');
end

ADVCHAT_NOCOMMANDS = function()
print('WARNING: No commands found. Chat commands engine will be turned off');
sv_advchat = 0;
end

ADVCHAT_INVALID_ARGS_DATATYPE = function(var, type_s)
	if (var == 1) then
		print('WARNING: Invalid data in "text" argument. Expected "STRING", got '..type_s..'"!');
	else
		print('WARNING: Invalid data in "color" argument. Expected "NUMBER", got '..type_s..'"!');
	end
end

ADVCHAT_INVALID_COMMAND = function(text)
end

--EXTERNAL FUNCTIONS (DO NOT MODIFY THIS SECTION)
--This function will add specified binding
function sv_addchatcmd(command, action)
	if (type(command) ~= "string") or (type(action) ~= "function") then
		return 0;
	end
	ADVCHAT_CMDLIST[command] = action;
	return 1;
end

--Remove chat command specified binding
function sv_removechatcmd(command)
	if (type(command) ~= "string")then
		return 0;
	end
	ADVCHAT_CMDLIST[command]=nil;
	return 1;
end

--This function will remove all bindings
function sv_clearchatcmds()
	ADVCHAT_CMDLIST = {};
	return 1;
end

function sv_advchatinfo()
	local s; 
	if (sv_advchat == 0) then 
		s = 'DISABLED'; 
	else 
		s = 'WORKING'; 
	end
	print('\n##################################\nChat commands engine. Version 2.0 by Tafintsev Herman aka Xandros\nE-mail: germanapps@gmail.com\nSTATUS: '..s..'\nCOMMANDS COUNT: '..ADVCHAT_CMDLEN()..'\n##################################');
	print('');
	print('Open console to see response');
	print('');
end
function sv_advchatversion () return "2.0" end

function ADVCHAT_CMDLEN()
	local c = 0;
	for _ in pairs(ADVCHAT_CMDLIST) do
		c = c + 1;
	end
	return c;
end
onConPrint=function(text,color)

if (type(text) ~= "string") then ADVCHAT_INVALID_ARGS_DATATYPE(1,type(text));ADVCHAT_ONCOMPLETE(text, color); end
if (type(color) ~= "number") then ADVCHAT_INVALID_ARGS_DATATYPE(2,type(color));ADVCHAT_ONCOMPLETE(text, color); end
if (color ~= 15) then ADVCHAT_ONCOMPLETE(text, color); end
if (sv_advchat == 0) then ADVCHAT_DISABLED(); ADVCHAT_ONCOMPLETE(text, color); end
if (ADVCHAT_CMDLEN() == 0) then ADVCHAT_NOCOMMANDS(); ADVCHAT_ONCOMPLETE(text, color); end

local user
for _,plr in pairs(playerList()) do
	if(playerInfo(plr).name == string.sub(text,0, #(playerInfo(plr).name))) then
		user=playerInfo(plr).name;
	end
end

local cmddetected = ""
for cmd in pairs(ADVCHAT_CMDLIST) do
	if(string.sub(text, #user+3, #user+2+#cmd) == cmd) then
		cmddetected = cmd;
		break;
	end
end
if (cmddetected == "") then
	ADVCHAT_INVALID_COMMAND(string.sub(text, #text-1-#user))
	ADVCHAT_ONCOMPLETE(text, color)
else
	local args = string.sub(text, #user+4+#cmddetected);
	ADVCHAT_CMDLIST[cmddetected](user, args);
	ADVCHAT_ONCOMPLETE(text, color);
end
end

sv_addchatcmd('/advchat', sv_advchatinfo);
--ENGINE UNLOAD FUNCTION
function sv_advchatunload()
sv_advchat = nil
sv_addchatcmd = nil
sv_removechatcmd = nil
sv_clearchatcmds = nil
sv_advchatinfo = nil
sv_advchatversion = nil

ADVCHAT_CMDLIST = nil

ADVCHAT_CMDLEN = nil

ADVCHAT_DISABLED = nil
ADVCHAT_NOCOMMANDS = nil
ADVCHAT_INVALID_ARGS_DATATYPE = nil
ADVCHAT_INVALID_COMMAND = nil
ADVCHAT_ONCOMPLETE=nil
onConPrint=nil
sv_advchatunload = nil
print('Chat commands engine for Nox with integrated Lua (version 2.0) has been unloaded successfully');
return 1
end
print('Chat commands engine for Nox with integrated Lua (version 2.0) has been loaded successfully');
