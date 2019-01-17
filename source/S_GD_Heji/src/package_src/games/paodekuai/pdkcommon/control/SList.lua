-------------------------------------------------------------------------
-- Desc:   扑克牌框架容器
-- Last: 
-- Author:   diyal.yin
-- Content:  双向队列 实现类
-- 2017-11-04  新建
-------------------------------------------------------------------------
local SList = class("SList")

function SList:ctor()  
    self.first = 1  
    self.last = 0  
    self.list = {}  
    -- self.listManager = {}
end

-- 在队列的前面插入
-- @param _tempObj: 值 （所有类型）
function SList:pushFront(_tempObj)
	local got,index = self:contains(_tempObj)
	if got then
		self:removeAt(index)
	end
	self.first = self.first - 1  
	self.list[self.first] = _tempObj
end

-- 在队列的后面插入
-- @param _tempObj: 值 （所有类型）
function SList:pushBack(_tempObj)
	local got,index = self:contains(_tempObj)
	if got then
		self:removeAt(index)
	end
	self.last = self.last + 1  
	self.list[self.last] = _tempObj
end

-- 包含某元素
-- @param _tempObj: 值 （所有类型）
-- @return got, index  是否包含，索引
function SList:contains(_tempObj)
	local got = false
	local index = 0
	for i,v in pairs(self.list) do
		if v == _tempObj then
			got = true
			index = i
			break
		end
	end
	return got,index
end

-- 删除指定位置元素
-- @param index: 索引
function SList:removeAt(index)
	if index < self.first or index > self.last then
		return
	end
	self.list[index] = nil
	if index < self.last then
		local tempTable = {}
		for tempIndex = index + 1, self.last do
			table.insert(tempTable, tempIndex-1, self.list[tempIndex])
			self.list[tempIndex] = nil
		end
		table.merge(self.list, tempTable)
	end
	self.last = self.last - 1
end

-- 删除指定元素
-- @param _tempObj: 元素
function SList:remove(_tempObj)
	local index = 0
	for i,v in pairs(self.list) do
		if v == _tempObj then
			index = i
			break
		end
	end
	if index > 0 then
		self:removeAt(index)
	end
end

-- 取得队列最前面的元素
-- @return  元素
function SList:getFront()  
	if self:isEmpty() then  
		return nil  
	else  
		local val = self.list[self.first]  
		return val  
	end  
end

-- 取得队列最后面的元素
-- @return  元素
function SList:getBack()  
	if self:isEmpty() then  
		return nil  
	else  
		local val = self.list[self.last]  
		return val  
	end  
end

-- 弹出队列最前面的元素
-- @return  元素
function SList:popFront()  
	local front = self.list[self.first]
	self.list[self.first] = nil  
	self.first = self.first + 1  
	return front
end

-- 弹出队列最后面的元素
-- @return  元素
function SList:popBack()  
	self.list[self.last] = nil  
	self.last = self.last - 1  
end

-- 清空
function SList:clear()  
	while false == self:isEmpty() do  
		self:popFront()  
	end
end

-- 是否为空判断
function SList:isEmpty()  
	if self.first > self.last then  
		self.first = 1  
		self.last = 0  
		return true  
	else  
		return false  
	end  
end

--获取队列元素个数
function SList:getSize()  	
	if self:isEmpty() then  
		return 0  
	else  
		return self.last - self.first + 1  
	end  
end 

return SList