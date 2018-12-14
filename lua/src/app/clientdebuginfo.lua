--使用方法：在socketManager.lua的第272行（SocketManager:onReceivePacket里面）添加：
--require("app.clientdebuginfo");
--clientdebug(msg);
Log.i("clientdebuginfo....enabled")

function clientdebug(msg)
    content = json.decode(msg.content);
    
    if msg.subcode == 58888 then
        local tmpData={}
        tmpData.ty = 0
        tmpData.lo = ""
        if content.ty == -1 then
            for i=messagesCurrentIndex-1,messagesStartIndex,-1 do
                index = string.find(messages[i], ')', 10)
                code = string.sub(messages[i], 10, index - 1)
                tmpData.lo = tmpData.lo .. i .. ' ' .. code .. "\n\n"
            end
        else
            if content.ty == -2 then
                target = messagesCurrentIndex - 2
                for i=messagesCurrentIndex-1,target,-1 do
                        tmpData.lo = tmpData.lo .. messages[i] .. "'\n\n"
                end
            else
               tmpData.lo = tmpData.lo .. messages[content.ty] .. "'\n\n"
            end
        end
        -- tmpData.lo = tempmessage
        -- tmpData.lo = tmpData.lo .. "clienttttttttttttt" .. os.time()
        SocketManager.getInstance():send(CODE_TYPE_USER, 58888, tmpData);
    else
        if msg.subcode ~= CODE_HEARTBEAT then
            local rrr = {};
            rrr.code = msg.subcode;
            rrr.content = content;
            rrrstr = json.encode(rrr);
            insertMessage("RECIEVED(" .. rrr.code .. "):(" .. os.date("%c", os.time()) .. ")\n" .. rrrstr)
        end
    end
end

messages = {}
messagesStartIndex = 0
messagesCurrentIndex = 0
tempmessage = "";

function insertMessage(str)
    tempmessage = str;
    Log.i("insertMessage", messagesStartIndex, messagesCurrentIndex)
    if messagesCurrentIndex - messagesStartIndex > 20 then
        index = messagesStartIndex
        messages[messagesStartIndex] = nil
        -- table.remove(SocketManager.messages, SocketManager.messagesStartIndex)
        messagesStartIndex = messagesStartIndex + 1
    end
    table.insert(messages, messagesCurrentIndex, str)
    -- Log.i("------SocketManager:insertMessage", SocketManager.messagesCurrentIndex, SocketManager.messages)
    messagesCurrentIndex = messagesCurrentIndex + 1
end