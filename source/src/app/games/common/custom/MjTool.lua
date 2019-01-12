--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local MjTool = {}

function MjTool.strToCharTable(str)
	assert(type(str) == "string")

	local table = {}
	local len = string.len(str)
	for i = 1, len do
		table[#table + 1] = string.byte(str, i)
	end
	return table
end

function MjTool.tableCopy(table)
	assert(type(table) == "table")

	local tab = {}
    for k, v in pairs(table) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = tableCopy(v)
        end
    end
    return tab
end

function MjTool.moneyToStr(str)
	return str
end

function MjTool.getAvatarUrl(userID)
    local vt = 1
    local st = 10202001
    local uid = tonumber(userID)
    local sp = 0
    local gid = 0
    local hid = 0
    local mst = 8
    local phototype = 1
--    local baseUrl = ww.LuaDataBridge:getInstance():getStrValueByKey("res_dl_url")
    local baseUrl = "http://192.168.10.91:8585/gamesrc/getsrc.jsp"
    local url = string.format("%s?vt=%d&st=%d&uid=%d&sp=%d&gid=%d&hid=%d&mst=%d&phototype=%d",baseUrl,vt,st,uid,sp,gid,hid,mst,phototype)


    return url
end

function MjTool.centerCropSprite(sprite, containerSize)
    local dwidth = sprite:getContentSize().width
    local dheight = sprite:getContentSize().height

    local vwidth = containerSize.width
    local vheight = containerSize.height

    local scale = 1.0

    if dwidth * vheight > vwidth * dheight then
        scale = vheight / dheight
    else
        scale = vwidth / dwidth
    end


	sprite:setScale(scale)
end

--[[
    @brief  将一组列表居中对齐排列；
            对象的基类为Node，且尺寸或者类型相同，举个栗子：麻将
    @data   data =         
            {
                ObjList = {Obj1, Obj2, Obj3, ...},  --  对象列表
                MaxCol = 5,                         --  最大列数
                ColGap = 0,                         --  列间距
                RowGap = 0,                         --  行间距
            }
    @return lActualCol      --  实际列数
            lActualRow      --  实际行数
            lComposeSize    --  排版后总体尺寸
--]]
function MjTool:alignCenter(data)
    if #data.ObjList < 1 then
        return
    end
    local lObjList = data.ObjList or {}
    local lMaxCol = data.MaxCol or 5
    local lColGap = data.ColGap or 0
    local lRowGap = data.RowGap or 0

    local col = 0   --  列
    local row = 1   --  行
    local count = #lObjList  --  对象总数
    local lActualCol = count >= lMaxCol and lMaxCol or count    --  实际列数
    local lActualRow = math.ceil(count / lActualCol)    --  实际行数
    local lObjSize = lObjList[1]:getContentSize()  --  取第一个对象尺寸为基准

    for i = 1, count do
        col = col + 1
        local nX = col - ((lActualCol + 1) / 2)
        local offsetX = nX * lColGap
        local posX = lObjSize.width * nX + offsetX

        local nY = -(row - ((lActualRow + 1) / 2))
        local offsetY = -nY * -lRowGap
        local posY = lObjSize.height * nY + offsetY

        lObjList[i]:setPosition(cc.p(posX, posY))

        if col >= lMaxCol then
            col = 0
            row = row + 1
        end
    end

    local lComposeWidth = lActualCol * lObjSize.width + lColGap * (lActualCol - 1)
    local lComposeHeight = lActualRow * lObjSize.height + lRowGap * (lActualRow - 1)
    local lComposeSize = cc.size(lComposeWidth, lComposeHeight) --  排版后总体尺寸

    local lResult = {}
    lResult.ActualCol = lActualCol
    lResult.ActualRow = lActualRow
    lResult.ComposeSize = lComposeSize

    return lResult
end

--[[
    @brief  将一组列表左对齐排列；
            对象的基类为Node，且尺寸或者类型相同，举个栗子：麻将
    @data   data =         
            {
                ObjList = {Obj1, Obj2, Obj3, ...},  --  对象列表
                MaxCol = 5,                         --  最大列数
                ColGap = 0,                         --  列间距
                RowGap = 0,                         --  行间距
            }
    @return lActualCol      --  实际列数
            lActualRow      --  实际行数
            lComposeSize    --  排版后总体尺寸
--]]
function MjTool:alignLeft(data)
    if #data.ObjList < 1 then
        return
    end

    local lObjList = data.ObjList or {}
    local lMaxCol = data.MaxCol or 5
    local lColGap = data.ColGap or 0
    local lRowGap = data.RowGap or 0

    local col = 0   --  列
    local row = 1   --  行
    local count = #lObjList  --  对象总数
    local lActualCol = count >= lMaxCol and lMaxCol or count    --  实际列数
    local lActualRow = math.ceil(count / lActualCol)    --  实际行数
    local lObjSize = lObjList[1]:getContentSize()  --  取第一个对象尺寸为基准

    for i = 1, count do
        local offsetX = col * lColGap
        local posX = lObjSize.width * col + offsetX

        local nY = -(row - ((lActualRow + 1) / 2))
        local offsetY = -nY * -lRowGap
        local posY = lObjSize.height * nY + offsetY

        lObjList[i]:setPosition(cc.p(posX, posY))

        col = col + 1
        if col >= lMaxCol and col ~= count then
            col = 0
            row = row + 1
        end
    end

    local lComposeWidth = lActualCol * lObjSize.width + lColGap * (lActualCol - 1)
    local lComposeHeight = lActualRow * lObjSize.height + lRowGap * (lActualRow - 1)
    local lComposeSize = cc.size(lComposeWidth, lComposeHeight) --  排版后总体尺寸

    local lResult = {}
    lResult.ActualCol = lActualCol
    lResult.ActualRow = lActualRow
    lResult.ComposeSize = lComposeSize

    return lResult
end

return MjTool