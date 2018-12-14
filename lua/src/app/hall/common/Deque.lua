-------------------------------------------------------------
--  @file   Deque.lua
--  @brief  队列函数
--  @author Zhu Can Qin
--  @DateTime:2016-08-08 20:07:17
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================


--[
-- @class Deque
-- @brief 双端队列，可用于模拟队列和栈
--]
local Deque = class("Deque")

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function Deque:ctor()
    self.elements = {}
end

--[
-- @brief  队首插入元素
-- @param  element
-- @return void
--]
function Deque:pushFront(element)
    table.insert(self.elements, 1, element)
end

--[
-- @brief  队尾插入元素
-- @param  element
-- @return void
--]
function Deque:pushBack(element)
    table.insert(self.elements, element)
end

--[
-- @brief  弹出队首元素
-- @param  void
-- @return void
--]
function Deque:popFront()
    if not self:empty() then
        table.remove(self.elements, 1)
    end
end

--[
-- @brief  弹出队尾元素
-- @param  void
-- @return void
--]
function Deque:popBack()
    if not self:empty() then
        table.remove(self.elements)
    end
end

--[
-- @brief  获取队首元素
-- @param  void
-- @return 队首
--]
function Deque:front()
    if not self:empty() then
        return self.elements[1]
    else
        return nil
    end
end

--[
-- @brief  获取队尾元素
-- @param  void
-- @return 队尾
--]
function Deque:back()
    if not self:empty() then
        return self.elements[#self.elements]
    else
        return nil
    end
end

--[
-- @brief  获取队列大小
-- @param  void
-- @return 队列大小
--]
function Deque:size()
    return #self.elements
end

--[
-- @brief  队列是否为空
-- @param  void
-- @return true/false
--]
function Deque:empty()
    return self:size() == 0
end

--[
-- @brief  清理队列
-- @param  void
-- @return void
--]
function Deque:clear()
    self.elements = {}
end

--[
-- @brief  遍历队列
-- @param  func函数
-- @return void
--]
function Deque:walk(func)
    for k, v in pairs(self.elements) do
        func(v, k)
    end
end

return Deque