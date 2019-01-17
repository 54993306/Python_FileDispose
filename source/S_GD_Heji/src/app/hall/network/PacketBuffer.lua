require("app.hall.network.ByteStringAnalyze");
cc.utils1 = require("app.framework.cc.utils.init");
local RC4 = require("app.hall.network.RC4")

PacketBuffer = class("PacketBuffer");

PacketBuffer.ENDIAN = cc.utils1.ByteArrayVarint.ENDIAN_BIG
PacketBuffer.PACKET_MAX_LEN = 655360

PacketBuffer.CONTENT_LEN = 4	-- length of content body
PacketBuffer.CODE_LEN = 4	-- length of message type
PacketBuffer.SUBCODE_LEN = 4	-- length of message code
PacketBuffer.HEAD_LEN = 12  -- length of total head

PacketBuffer.CRYPTO_HEAD_LEN = 4  -- length of crypto head
PacketBuffer.SERCET_KEY = nil
PacketBuffer.DO_CRYPTO = false



function PacketBuffer.getBaseBA()
	return cc.utils1.ByteArray.new(PacketBuffer.ENDIAN)
end


function PacketBuffer.initSerKey()
    PacketBuffer.SERCET_KEY = nil
    local sercodeFile = cc.FileUtils:getInstance():fullPathForFilename("res/games/gamehall/sercode")
    local sercodeData = cc.HelperFunc:getFileData(sercodeFile)

    local buf = cc.utils1.ByteArray.new(PacketBuffer.ENDIAN)
    buf:writeBuf(sercodeData)
    buf:setPos(1)
    local h1 = buf:readUByte()
    local h2 = buf:readUByte()

    local klen
    local clen
    if h1 == 1 then
        klen = buf:readInt()
    else
        klen = buf:readUByte()
    end
    if h2 == 1 then
        clen = buf:readInt()
    else
        clen = buf:readUByte()
    end
    local k = buf:readBuf(klen)
    local c = buf:readBuf(clen)

    PacketBuffer.SERCET_KEY = crypto.decryptXXTEA(c, k)
    --Log.i("PacketBuffer.SERCET_KEY",PacketBuffer.SERCET_KEY)
end

function PacketBuffer.createMessage(code, subcode, dataString)
    local buf = PacketBuffer.getBaseBA();
    local content_len = (dataString == nil) and 0 or string.len(dataString);
    buf:writeInt(code);
    buf:writeInt(subcode);
    buf:writeInt(content_len);

    if dataString then
        buf:writeString(dataString);
    end

    if not PacketBuffer.DO_CRYPTO then
        return buf;
    else
        if PacketBuffer.SERCET_KEY == nil then
            PacketBuffer.initSerKey()
        end
    end

    local cryptoStr = RC4.doRC4(buf:getPack(), PacketBuffer.SERCET_KEY)
    local totalLen = string.len(cryptoStr) + PacketBuffer.CRYPTO_HEAD_LEN

    local cryptoBuf = PacketBuffer.getBaseBA();
    cryptoBuf:writeInt(totalLen)
    cryptoBuf:writeBuf(cryptoStr)

    --[[
    local str = cryptoBuf:getPack()
    local logStr = "[ "
    for i = 1, #str do        
        local c = string.byte(str, i, i)
        logStr = logStr .. tostring(c) ..", "
    end
    Log.i(logStr)
    ]]

    return cryptoBuf;
end

function PacketBuffer:ctor()
	self:init()
end

function PacketBuffer:init()
    self.buf=ByteStringAnalyze.new()
end

function PacketBuffer:parseMessage(__byteString)
    local msgs = {}
    self.buf:writeBuf(__byteString);

    if PacketBuffer.DO_CRYPTO then
        local __preLen = PacketBuffer.CRYPTO_HEAD_LEN
        --printf("DO_CRYPTO parseMessage getAvailable %u", self.buf:getAvailable())
        while self.buf:getAvailable() >= __preLen do
            local cryptoBodyLen = self.buf:readInt() - PacketBuffer.CRYPTO_HEAD_LEN;
            --printf("parseMessage cryptoBodyLen %u", cryptoBodyLen)
            -- buffer is not enougth, waiting...
            if self.buf:getAvailable() < cryptoBodyLen then 
                printf("received data is not enough, waiting... need %u, get %u", cryptoBodyLen, self.buf:getAvailable())
                self.buf:setPos(self.buf:getPos() - PacketBuffer.CRYPTO_HEAD_LEN);
                break
            end
            
            if cryptoBodyLen <= PacketBuffer.PACKET_MAX_LEN then
                local cryptoByteStr = self.buf:readBuf(cryptoBodyLen)
                local encryptoBuf = PacketBuffer.getBaseBA();
                encryptoBuf:writeBuf( RC4.doRC4(cryptoByteStr, PacketBuffer.SERCET_KEY) ) 
                encryptoBuf:setPos(1)
                local code = encryptoBuf:readInt();
                local subcode = encryptoBuf:readInt();
                local bodyLen = encryptoBuf:readInt();
                if bodyLen > 0 then
                    content = encryptoBuf:readBuf(bodyLen);
                    if code > 0 then
                        Log.i("------parseMessage subcode", subcode);
                        Log.i("------parseMessage content", content);
                        Log.s("------parseMessage subcode", subcode)
                        Log.s("------parseMessage content", content)
                    end 
                end

                local msg = {}
                msg.code = code;
                msg.subcode = subcode;
                msg.content = content;
                msgs[#msgs + 1] = msg;
                --printf("after get body position:%u available size :%u", self.buf:getPos(), self.buf:getAvailable());
            end
        end
    else
        --printf("parseMessage getAvailable %u", self.buf:getAvailable())
        local __preLen = PacketBuffer.HEAD_LEN
        --printf("analyzing... buffer len: %u, Pos:%u, available: %u", self.buf:getLen(),self.buf:getPos(), self.buf:getAvailable());
        while self.buf:getAvailable() >= __preLen do
            local code = self.buf:readInt();
            local subcode = self.buf:readInt();
            local bodyLen = self.buf:readInt();
            -- Log.d("PacketBuffer __byteString len", string.len(__byteString))
            -- Log.d("PacketBuffer code", code)
            -- Log.d("PacketBuffer subcode", subcode)
            -- Log.d("PacketBuffer bodyLen", bodyLen)
            -- Log.d("self.buf:getAvailable()", self.buf:getAvailable())
            --print(" The bodyLen is ", bodyLen);

            -- 当出现丢包/粘包/乱序时, 这几个数值可能出错, 此时直接通知socket网络出错
            if (code < 0 or code > 99) or (subcode < 0 or subcode > 99999) or bodyLen < 0 then
                Log.e("PacketBuffer code error", code)
                Log.s("self.buf", self.buf:readBuf(self.buf:getAvailable()))
                self:init()
                return nil
            end

            -- buffer is not enougth, waiting...
            if self.buf:getAvailable() < bodyLen then 
                printf("received data is not enough, waiting... need %u, get %u", bodyLen, self.buf:getAvailable())
                self.buf:setPos(self.buf:getPos() - PacketBuffer.HEAD_LEN);
                break
            end
            
            if bodyLen <= PacketBuffer.PACKET_MAX_LEN then
                local content = nil
                if bodyLen > 0 then
                    content = self.buf:readBuf(bodyLen);
                    -- Log.s(ToolKit.getHexStrFromStr(content))
                    if code > 0 then
                        Log.i("------parseMessage subcode", subcode);
                        Log.i("------parseMessage content", content);
                        Log.s("------parseMessage subcode", subcode)
                        Log.s("------parseMessage content", content)
                    end 
                end

                local msg = {}
                msg.code = code;
                msg.subcode = subcode;
                msg.content = content;
                msgs[#msgs + 1] = msg;
                --printf("after get body position:%u available size :%u", self.buf:getPos(), self.buf:getAvailable());
            end
        end
    end
    -- clear buffer on exhausted
    if self.buf:getAvailable() <= 0 then
        self:init();
    end
    return msgs
end
