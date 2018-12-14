--
-- Author: 汪智
-- Date: 2018年7月30日10:47:46
-- 战绩列表
--

local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")
local PokerUtils = require("package_src.games.pokercommon.commontool.PokerUtils")
local DDZDefine = require("package_src.games.paodekuai.pdk.data.DDZDefine")
local DDZRecord = class("DDZRecord",PokerUIWndBase)
local DDZConst = require("package_src.games.ddz.data.DDZConst")
function DDZRecord:ctor(data)
    self.super.ctor(self,"package_res/games/pokercommon/standings.csb", data)
    -- self:onInit()
    self.matchCount = 0
    self.playerIdList = {}
end

-- 初始化
function DDZRecord:onInit()
    local root = ccui.Helper:seekWidgetByName(self.m_pWidget,"root")
    root:addTouchEventListener(handler(self,self.onClickButton))
    -- 玩家头像集合
    self.panel_heand = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_heand")

    -- 每局分数的滑动容器
    self.scrollView = ccui.Helper:seekWidgetByName(self.m_pWidget,"scrollView")

    -- 总分
    self.panel_bottom = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_bottom")

    self:playerHead()

    self:matchListView()

end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function DDZRecord:getPlayerModel(userID)
    Log.i("--wangzhi--userID--",userID)
    Log.i("--wangzhi--userID--",tolua.type(userID))
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer = nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZDefine.USERID) == tonumber(userID) then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    return dstPlayer
end


-- 头像信息
function DDZRecord:playerHead()
    local matchTotalInfo = DataMgr:getInstance():getMatchTotalRecord()

    local playerHeadImag = {}
    local playerNameList = {}
    local playerSexList = {}
    for k,v in pairs(matchTotalInfo[1].playFenMap) do
        local PlayerModel = self:getPlayerModel(k)
        local userid = PlayerModel:getProp(DDZDefine.USERID)
        local headImg = PlayerModel:getProp(DDZDefine.ICON_ID)
        local playerName = PlayerModel:getProp(DDZDefine.NAME)
        local playerSex = PlayerModel:getProp(DDZDefine.SEX)

        -- playerHeadImag[userid] = headImg
        table.insert(playerHeadImag,userid)
        -- playerNameList[userid] = playerName
        table.insert(playerNameList,playerName)

        table.insert(playerSexList,playerSex)

        table.insert(self.playerIdList,userid)
    end

    local count = 1
    for i,v in pairs(playerHeadImag) do
        Log.i("--wangzhi--playerHeadImag--",i,v)
        local img_head = ccui.Helper:seekWidgetByName(self.panel_heand,"pand_heand_"..count)
        local image_heand = ccui.Helper:seekWidgetByName(img_head,"image_heand")
        local label_name = ccui.Helper:seekWidgetByName(img_head,"label_name")
        local userid = self.playerIdList[count]
        local headImg = userid..".jpg"

        headImg = cc.FileUtils:getInstance():fullPathForFilename(headImg);
        if io.exists(headImg) then
            Log.i("--wangzhi--playerHead--headImg--",headImg)
            image_heand:loadTexture(headImg)
            image_heand:setScale(80 / image_heand:getContentSize().width)
        else
            local sex = playerSexList[i]
            local defMale = "package_res/games/pokercommon/head/defaultHead_male.png"
            local defFemale = "package_res/games/pokercommon/head/defaultHead_female.png"
            local stencil = "package_res/games/pokercommon/head/cicleHead.png"
            local headFile = sex == DDZConst.MALE and defMale or defFemale
            Log.i("head headFile ", headFile)
            image_heand:loadTexture(headFile)
            image_heand:setScale(80 / image_heand:getContentSize().width)
        end

        label_name:setString(PokerUtils:subUtfStrByCn(playerNameList[i], 1, 4, ".."))
        count = count + 1
    end
end

-- 每个人的总分
function DDZRecord:matchTotalScore()
    local matchTotalInfo = DataMgr:getInstance():getMatchTotalRecord()
    -- 每个人的总分
    local label_score_1 = ccui.Helper:seekWidgetByName(self.m_pWidget,"label_score_1")
    local label_score_2 = ccui.Helper:seekWidgetByName(self.m_pWidget,"label_score_2")
    local label_score_3 = ccui.Helper:seekWidgetByName(self.m_pWidget,"label_score_3")
    local totalScore1 = 0
    local totalScore2 = 0
    local totalScore3 = 0

    local winColor = cc.c3b(254, 218, 131)
    local loseColor = cc.c3b(169, 199, 236)
    for i,v in ipairs(matchTotalInfo) do
        local count = 0
        for k,v2 in pairs(v.playFenMap) do
            count = count + 1
            if count == 1 then
                totalScore1 = totalScore1 + v.playFenMap[tostring(self.playerIdList[count])]
                if i == #matchTotalInfo then
                    label_score_1:setString(totalScore1)
                    if totalScore1 > 0 then
                        label_score_1:setColor(winColor)
                    else
                        label_score_1:setColor(loseColor)
                    end
                end
            elseif count == 2 then
                totalScore2 = totalScore2 + v.playFenMap[tostring(self.playerIdList[count])]
                if i == #matchTotalInfo then
                    label_score_2:setString(totalScore2)
                    if totalScore2 > 0 then
                        label_score_2:setColor(winColor)
                    else
                        label_score_2:setColor(loseColor)
                    end
                end
            elseif count == 3 then
                totalScore3 = totalScore3 + v.playFenMap[tostring(self.playerIdList[count])]
                if i == #matchTotalInfo then
                    label_score_3:setString(totalScore3)
                    if totalScore3 > 0 then
                        label_score_3:setColor(winColor)
                    else
                        label_score_3:setColor(loseColor)
                    end
                end
            end

        end
    end
end

-- 比赛条目
function DDZRecord:matchListView()
    local matchTotalInfo = DataMgr:getInstance():getMatchTotalRecord()
    local jushuList = {"第1局","第2局","第3局","第4局","第5局","第6局","第7局","第8局","第9局","第10局","第11局","第12局","第13局","第14局","第15局","第16局"}
    -- self.matchCount = self.matchCount + 1
    Log.i("--wangzhi--matchTotalInfo--",matchTotalInfo)
    for i,v in ipairs(matchTotalInfo) do
        local match_item = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/pokercommon/match_item.csb")
        local label_jushu = ccui.Helper:seekWidgetByName(match_item,"label_jushu")
        local label_number_1 = ccui.Helper:seekWidgetByName(match_item,"label_number_1")
        local label_number_2 = ccui.Helper:seekWidgetByName(match_item,"label_number_2")
        local label_number_3 = ccui.Helper:seekWidgetByName(match_item,"label_number_3")

        local label_yupai_1 = ccui.Helper:seekWidgetByName(match_item,"label_yupai_1")
        local label_yupai_2 = ccui.Helper:seekWidgetByName(match_item,"label_yupai_2")
        local label_yupai_3 = ccui.Helper:seekWidgetByName(match_item,"label_yupai_3")

        local label_zhadan1 = ccui.Helper:seekWidgetByName(match_item,"label_zhadan1")
        local label_zhadan2 = ccui.Helper:seekWidgetByName(match_item,"label_zhadan2")
        local label_zhadan3 = ccui.Helper:seekWidgetByName(match_item,"label_zhadan3")

        local image_xiaoguan1 = ccui.Helper:seekWidgetByName(match_item,"image_xiaoguan1")
        local image_xiaoguan2 = ccui.Helper:seekWidgetByName(match_item,"image_xiaoguan2")
        local image_xiaoguan3 = ccui.Helper:seekWidgetByName(match_item,"image_xiaoguan3")

        local image_daguan1 = ccui.Helper:seekWidgetByName(match_item,"image_daguan1")
        local image_daguan2 = ccui.Helper:seekWidgetByName(match_item,"image_daguan2")
        local image_daguan3 = ccui.Helper:seekWidgetByName(match_item,"image_daguan3")

        label_jushu:setString(jushuList[i])

        local winColor = cc.c3b(254, 218, 131)
        local loseColor = cc.c3b(169, 199, 236)
        local tmpColor1
        local tmpColor2
        local tmpColor3

        local count = 1
        for k,v1 in pairs(v.playFenMap) do
            local score = v.playFenMap[tostring(self.playerIdList[count])]
            if count == 1 then
                label_number_1:setString(score)
                if score> 0 then
                    tmpColor1 = winColor
                else
                    tmpColor1 = loseColor
                end
                label_number_1:setColor(tmpColor1)
            elseif count == 2 then
                label_number_2:setString(score)
                if score> 0 then
                    tmpColor2 = winColor
                else
                    tmpColor2 = loseColor
                end
                label_number_2:setColor(tmpColor2)
            elseif count == 3 then
                label_number_3:setString(score)
                if score> 0 then
                    tmpColor3 = winColor
                else
                    tmpColor3 = loseColor
                end
                label_number_3:setColor(tmpColor3)
            end
            count = count + 1
        end

        count = 1
        local yupaiStringStart = "余牌："
        local yupaiStringEnd = "张"
        for k,v2 in pairs(v.playCloseCardMap) do
            local yupaiCount = v.playCloseCardMap[tostring(self.playerIdList[count])]
            local yupai = yupaiStringStart..#yupaiCount..yupaiStringEnd
            if count == 1 then
                label_yupai_1:setString(yupai)
                label_yupai_1:setColor(tmpColor1)
            elseif count == 2 then
                label_yupai_2:setString(yupai)
                label_yupai_2:setColor(tmpColor2)
            elseif count ==3 then
                label_yupai_3:setString(yupai)
                label_yupai_3:setColor(tmpColor3)
            end
            count = count + 1
        end

        count = 1
        local zhadanString = "炸弹："
        for k,v3 in pairs(v.privateZhaDanfenMap) do
            local zhadanCount = v.privateZhaDanfenMap[tostring(self.playerIdList[count])]
            local zhadan = zhadanString..zhadanCount
            if count == 1 then
                label_zhadan1:setString(zhadan)
                label_zhadan1:setColor(tmpColor1)
            elseif count == 2 then
                label_zhadan2:setString(zhadan)
                label_zhadan2:setColor(tmpColor2)
            elseif count ==3 then
                label_zhadan3:setString(zhadan)
                label_zhadan3:setColor(tmpColor3)
            end
            count = count + 1
        end

        count = 1
        local xiaoguanString = "小关"
        local daguanString = "大关"
        for k,v4 in pairs(v.playFanMap) do
            local FanType = v.playFanMap[tostring(self.playerIdList[count])]
            if count == 1 then
                if next(FanType) then
                    if FanType[1].fanName == xiaoguanString then
                        image_xiaoguan1:setVisible(true)
                    elseif FanType[1].fanName == daguanString then
                        image_daguan1:setVisible(true)
                    end
                end
            elseif count == 2 then
                if next(FanType) then
                    if FanType[1].fanName == xiaoguanString then
                        image_xiaoguan2:setVisible(true)
                    elseif FanType[1].fanName == daguanString then
                        image_daguan2:setVisible(true)
                    end
                end
            elseif count ==3 then
                if next(FanType) then
                    if FanType[1].fanName == xiaoguanString then
                        image_xiaoguan3:setVisible(true)
                    elseif FanType[1].fanName == daguanString then
                        image_daguan3:setVisible(true)
                    end
                end
            end
            count = count + 1
        end
        -- 计数+1

        self.scrollView:pushBackCustomItem(match_item)
    end
    self:matchTotalScore()
end

function DDZRecord:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

function DDZRecord:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        self:keyBack();
    end
end

function DDZRecord:onClose()
    Log.i("--wangzhi--DDZRecord:onClose()--")
    self.panel_heand = nil
    self.scrollView = nil
    self.panel_bottom =nil
    self.playerIdList = nil
end

return DDZRecord
