--
-- Author: zhongys
-- Date: 2015-01-08 13:30:54
--

ByteStringAnalyze = class("ByteStringAnalyze")

function ByteStringAnalyze:ctor()
	self._buf = nil
	self._pos = 1
end

function ByteStringAnalyze:getLen()
	if self._buf==nil then
		return 0
	end
	return #self._buf
end

function ByteStringAnalyze:getAvailable()
	return #self._buf - self._pos + 1
end

function ByteStringAnalyze:getPos()
	return self._pos
end

function ByteStringAnalyze:setPos(__pos)
	self._pos = __pos
	return self
end

function ByteStringAnalyze:readByte()
	local byteSting = string.sub(self._buf,self._pos,self._pos)
	self._pos = self._pos + 1
	return string.byte(byteSting)
end

function ByteStringAnalyze:readShort()
	local __, __v = string.unpack(self:readBuf(2), self:_getLC("h"))
	return __v
end

function ByteStringAnalyze:readInt()
	local __, __v = string.unpack(self:readBuf(4), self:_getLC("i"))
	return __v
end

function ByteStringAnalyze:readUInt()
	local __, __v = string.unpack(self:readBuf(4), self:_getLC("I"))
	return __v
end

function ByteStringAnalyze:readLong()
	local int1=self:readUInt()
	local int2=self:readUInt()
	return int1*100000000+int2
end

--- Read a byte array as string from current position, then update the position.
function ByteStringAnalyze:readBuf(__len)
	local __ba = string.sub(self._buf,self._pos,self._pos+__len-1)
	self._pos = self._pos + __len
	return __ba
end

function ByteStringAnalyze:writeBuf(__s)
	if self._buf==nil then
		self._buf=__s
	else
		self._buf=self._buf..__s
	end
	
end

function ByteStringAnalyze:_checkAvailable()
	assert(#self._buf >= self._pos, string.format("End of file was encountered. pos: %d, len: %d.", self._pos, #self._buf))
end

function ByteStringAnalyze:_getLC(__fmt)	
	return ">"..__fmt	
end
