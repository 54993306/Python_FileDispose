--主界面
local director = cc.Director:getInstance()
local scheduler = director:getScheduler()

local cScrollView = class("cScrollView")
function cScrollView:ctor(frm, itm, datas, funcRefresh, spaceX, spaceY)
    self.m_speed = 400
    self.m_pFrame = frm
    self.m_type = frm:getDirection()
    local function onNil() end
    self.m_pFrame:addEventListener(onNil)
    self.m_pFrame:removeAllChildren()
    self.m_pInnerContainer = self.m_pFrame:getInnerContainer()
    self.m_pItem = itm
    self.m_pItem:setVisible(false)
    self.m_pDatas = datas
    self.m_funcRefresh = funcRefresh
    self.m_szFrame = self.m_pFrame:getContentSize()
    self.m_szItem = self.m_pItem:getContentSize()
    self.m_spaceX = spaceX
    self.m_spaceY = spaceY
    if spaceX == nil then spaceX = 0 end
    self.m_szItem.width = self.m_szItem.width + spaceX
    if spaceY == nil then spaceY = 0 end
    self.m_szItem.height = self.m_szItem.height + spaceY
    local col = math.floor(self.m_szFrame.width / self.m_szItem.width)
    local row = math.floor(self.m_szFrame.height / self.m_szItem.height)
    if self.m_type == 1 then row = row + 2
    else col = col + 2 end
    self.m_numItemPool = col * row
    self.m_aItemPool = {}
    for i = 1, self.m_numItemPool do
        local w = self.m_pItem:clone()
        w:setTouchEnabled(true)
        w:setVisible(false)
        self.m_pFrame:addChild(w)
        table.insert(self.m_aItemPool, {w, 0})
    end
    self.m_num = table.getn(self.m_pDatas)
    self.m_szCont = cc.size(0, 0)
    if self.m_type == 1 then
        self.m_column = col
        self.m_row = math.ceil(self.m_num / self.m_column)
        self.m_szCont.width = self.m_szFrame.width
        self.m_szCont.height = self.m_szItem.height * self.m_row
        if self.m_szCont.height < self.m_szFrame.height then
            self.m_szCont.height = self.m_szFrame.height
        end
    else
        self.m_row = row
        self.m_column = math.ceil(self.m_num / self.m_row)
        self.m_szCont.width = self.m_szItem.width * self.m_column
        self.m_szCont.height = self.m_szFrame.height
        if self.m_szCont.width < self.m_szFrame.width then
            self.m_szCont.width = self.m_szFrame.width
        end
    end
    self.m_pFrame:setInnerContainerSize(self.m_szCont)
    if self.m_type == 1 then
        self.m_pFrame:jumpToTop()
        self.m_pos = -self.m_pInnerContainer:getPositionY()
    else
        self.m_pFrame:jumpToLeft()
        self.m_pos = -self.m_pInnerContainer:getPositionX()
    end
    self.m_dataItem = {}
    local ptc = self.m_pItem:getAnchorPoint()
    local ptStart = cc.p(0, 0)
    ptStart.x = ptc.x * self.m_szItem.width
    ptStart.y = ( self.m_szCont.height - self.m_szItem.height ) + ( ptc.y * self.m_szItem.height )
    local pt = cc.p(ptStart)
    for i,v in ipairs(self.m_pDatas) do
        local idx = math.mod(i - 1, self.m_numItemPool) + 1
        local w = self.m_aItemPool[idx]
        local itm = {data = v, widget = w, pos = cc.p(pt)}
        table.insert(self.m_dataItem, itm)
        if self.m_type == 1 then
            pt.x = pt.x + self.m_szItem.width
            if math.mod(idx, self.m_column) == 0 then
                pt.x = ptStart.x
                pt.y = pt.y - self.m_szItem.height
            end
        else
            pt.y = pt.y - self.m_szItem.height
            if math.mod(idx, self.m_row) == 0 then
                pt.y = ptStart.y
                pt.x = pt.x + self.m_szItem.width
            end
        end
    end
    local function onSclEvent(obj, event)
        self:scl(self:getPos())
    end
    self.m_pFrame:addEventListener(onSclEvent)
    self:scl(0)
end

function cScrollView:setInnerContainerSize(size)
  self.m_pFrame:setInnerContainerSize(size)
end

--更新数据
function cScrollView:updateSclData(dataIndex,data)
  self.m_pDatas[dataIndex]= data;
  local di = self.m_dataItem[dataIndex]
  di.data = data
  --Log.i("更新数据" ,di);
  --self.m_funcRefresh(di.data, di.widget[1], di.widget[2])
end

function cScrollView:scl(pos, force)
    if pos < 0 then pos = 0 end
    if pos > self:getLen() then pos = self:getLen() end
    local from = 0
    local to = 0
    local count = 0
    if self.m_type == 1 then
        from = math.floor( pos / self.m_szItem.height )
        to = math.floor( ( pos + self.m_szFrame.height ) / self.m_szItem.height)
        count = self.m_column
        if from < 0 then from = 0 end
        if from >= self.m_row then from = self.m_row - 1 end
        if to < 0 then to = 0 end
        if to >= self.m_row then to = self.m_row - 1 end
    else
        from = math.floor( pos / self.m_szItem.width )
        to = math.floor( ( pos + self.m_szFrame.width ) / self.m_szItem.width)
        count = self.m_row
        if from < 0 then from = 0 end
        if from >= self.m_column then from = self.m_column - 1 end
        if to < 0 then to = 0 end
        if to >= self.m_column then to = self.m_column - 1 end
    end
    if force then
        for i,v in ipairs(self.m_aItemPool) do
            v[2] = -1
        end
    end
    for i = from, to do
        for j = 1, count do
            local idx = i * count + j
            local di = self.m_dataItem[idx]
            if di ~= nil then
                di.widget[1]:setPosition(di.pos.x+(self.m_spaceX/2),di.pos.y)
                if di.widget[2] ~= idx then
                    di.widget[1]:setVisible(true)
                    di.widget[2] = idx
                    self.m_funcRefresh(di.data, di.widget[1], idx)
                end
            end
        end
    end
end

function cScrollView:sclPercent(percent, time)
    local len = self:getLen()
    if len <= 0 then return end
    if percent < 0 then percent = 0 end
    if percent > 100 then percent = 100 end
    if self.m_type == 1 then
        if time <= 0 then
            self.m_pFrame:jumpToPercentVertical(percent)
            self:refresh()
        else
            self.m_pFrame:scrollToPercentVertical(percent, time, false)
            self.m_pFrame:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function() self:refresh() end)))
        end
    else
        if time <= 0 then
            self.m_pFrame:jumpToPercentHorizontal(percent)
            self:refresh()
        else
            self.m_pFrame:scrollToPercentHorizontal(percent, time, false)
            self.m_pFrame:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function() self:refresh() end)))
        end
    end
end

function cScrollView:getSegmentCount()
    if self.m_type == 1 then return self.m_row
    else return self.m_column end
end
function cScrollView:sclSegment(segment, time)
    local len = self:getLen()
    if len <= 0 then return end
    if segment < 0 then segment = 0 end
    local percent = 0
    if self.m_type == 1 then
        if segment >= self.m_row then segment = self.m_row - 1 end
        percent = ( ( segment * self.m_szItem.height ) / len ) * 100
    else
        if segment >= self.m_column then segment = self.m_column - 1 end
        percent = ( ( segment * self.m_szItem.width ) / len ) * 100
    end
    self:sclPercent(percent, time)
end

--定位
function cScrollView:sclItem(item_idx, time)
    local len = self:getLen()
    if len <= 0 then return end
    local segment = 0
    if self.m_type == 1 then segment = math.ceil(item_idx / self.m_column) - 1
    else segment = math.ceil(item_idx / self.m_row) - 1 end
    self:sclSegment(segment, time)
end

function cScrollView:setSclSpeed(speed)
    self.m_speed = speed
end
function cScrollView:sclBeginAdd()
    local len = self:getLen()
    if len <= 0 then return end
    local pos = self:getPos()
    local tm = (len - pos) / self.m_speed
    if tm <= 0 then tm = 0.1 end
    self:sclPercent(100, tm)
end
function cScrollView:sclBeginSub()
    local len = self:getLen()
    if len <= 0 then return end
    local pos = self:getPos()
    local tm = pos / self.m_speed
    if tm <= 0 then tm = 0.1 end
    self:sclPercent(0, tm)
end
function cScrollView:sclStop()
    local len = self:getLen()
    if len <= 0 then return end
    local pos = self:getPos()
    local pc = ( pos / len ) * 100
    self:sclPercent(pc, 0.1)
end

function cScrollView:getLen()
    if self.m_type == 1 then return self.m_szCont.height - self.m_szFrame.height
    else return self.m_szCont.width - self.m_szFrame.width end
end

function cScrollView:getPos()
    if self.m_type == 1 then return self.m_pos + self.m_pInnerContainer:getPositionY()
    else return self.m_pos - self.m_pInnerContainer:getPositionX() end
end
function cScrollView:refresh()
    self:scl(self:getPos(), true)
end

function new_cScrollView(...)
    return cScrollView.new(...)
end