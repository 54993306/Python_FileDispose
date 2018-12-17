--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.common.Define"
PlayerHead = class("PlayerHead")
local UmengClickEvent = require("app.common.UmengClickEvent")

local kSiteNames = 
{
    {},
    {"Panel_head_my", "Panel_head_other"},
    {"Panel_head_my", "Panel_head_right", "Panel_head_left"},
    {"Panel_head_my", "Panel_head_right", "Panel_head_other", "Panel_head_left"}
}

local kHeadSrcPoses = 
{
    {

    },
    {
        { left = 590, right = 0, top = 0, bottom = 60},
        { left = 0, right = 590, top = 60, bottom = 0}
    },
    {
        { left = 590, right = 0, top = 0, bottom = 60},
        { left = 0, right = 60, top = 0, bottom = 360},
        { left = 60, right = 0, top = 360, bottom = 0}
    },
    {
        { left = 590, right = 0, top = 0, bottom = 60},
        { left = 0, right = 60, top = 0, bottom = 360},
        { left = 0, right = 590, top = 60, bottom = 0},
        { left = 60, right = 0, top = 360, bottom = 0}
    }
}

local kGamePoses = 
{
    {

    },
    {
        { left = 35, right = 0, top = 0, bottom = 179},
        { left = 0, right = 180, top = 35, bottom = 0}
    },
    {
        { left = 35, right = 0, top = 0, bottom = 179},
        { left = 0, right = 35, top = 0, bottom = 418},
        { left = 35, right = 0, top = 251, bottom = 0}
    },
    {
        { left = 35, right = 0, top = 0, bottom = 179},
        { left = 0, right = 35, top = 0, bottom = 418},
        { left = 0, right = 265, top = 35, bottom = 0},
        { left = 35, right = 0, top = 251, bottom = 0}
    }
}

local player_icon_to_ready = 
{
    {},
    {1,3},
    {1,2,4},
    {1,2,3,4},
}

function PlayerHead:ctor(data)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/playerHead.csb");

    local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.playerCount = sys:getGameStartDatas().playerNum

    local allHeads = kSiteNames[4]
    for i = 1, #allHeads do
        local w = self:getWidget(self.m_pWidget, allHeads[i])
        w:setVisible(false)
    end

    self.m_data = data;
    self.m_headImage = {};
    self.speakPanel = {}; -- 聊天条
    self.fortuneLabels = {}; -- 积分
    self.panel_heads = {};

    self.handlers = {}
    -- 定缺动画
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_dingque_Anim_finsh, 
        handler(self, self.onDingqueAnimEnd)))
    
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_LAPAOZUO_EVENT, 
        handler(self, self.onDidLaPaoZuoEnded)))
end

function PlayerHead:onClose()
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}
    self.m_pWidget:stopAllActions()
end

function PlayerHead:setDelegate(delegate)
    self.m_delegate = delegate;
end

local function createNameTip(name)
    local bg = ccui.Scale9Sprite:create(cc.rect(10, 10, 2, 2), "hall/Common/name_scale_bg.png")
    bg:setContentSize(cc.size(80, 22))

    local nameLabel = ccui.Text:create(name, "hall/font/fangzhengcuyuan.TTF", 18)
    nameLabel:setColor(cc.c3b(0xff, 0xfe, 0xad))
    nameLabel:setPosition(cc.p(40, 11))
    nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    bg:addChild(nameLabel)
    return bg, nameLabel
end

--获取子控件时赋予特殊属性(支持Label,TextField)
function PlayerHead:getWidget(parent, name, ...)
    local widget = nil;
    local args = ...;
    widget = ccui.Helper:seekWidgetByName(parent or self.m_pWidget, name);
	if(widget == nil) then
        return;
    end

    return widget;
end

function PlayerHead:onInit()
    --自己的头像
    local wNames = kSiteNames[self.playerCount]
    for i = 1, #wNames do
        self.panel_heads[i] = self:getWidget(self.m_pWidget, wNames[i])
        self.panel_heads[i]:setVisible(true)
        self:updateHead(self.panel_heads[i], i)
    end
    -- self.panel_heads[1] = self:getWidget(self.m_pWidget, "Panel_head_my")
    -- self:updateHead(self.panel_heads[1], Define.site_self)
    -- --右家的头像
    -- self.panel_heads[2] = self:getWidget(self.m_pWidget,"Panel_head_right")
    -- self:updateHead(self.panel_heads[2], Define.site_right)
    -- --对家的头像
    -- self.panel_heads[3] = self:getWidget(self.m_pWidget,"Panel_head_other")
    -- self:updateHead(self.panel_heads[3], Define.site_other)

    -- --左家的头像
    -- self.panel_heads[4] = self:getWidget(self.m_pWidget,"Panel_head_left")
    -- self:updateHead(self.panel_heads[4], Define.site_left)

    self:initReadySprite()
    -- 更新庄家
    self:updateBan()

    self:updateDingQue()

    if not VideotapeManager.getInstance():isPlayingVideo() then
        self:refreshHeadState()

        --开始检测离线状态
        self.m_pWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() self:refreshHeadState() end))))
    end
end

function PlayerHead:refreshHeadState()
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local players  = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    if playerInfos == nil or playerInfos.pl == nil or players == nil then
        return
    end
    for i,v in pairs(players) do    
        for k, p in pairs(playerInfos.pl) do
            if p.usI == v:getProp(enCreatureEntityProp.USERID) then
                self:showOffline(i, p.st ~= nil and p.st == 1)
                local head = self:getHead(i)
                local image_head_Sprite = self:getWidget(head,"Image_head_Sprite")
                local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(i)
                self:ipXiangTong(player, image_head_Sprite, i)
                break;
            end
        end
    end
end

--定缺结果
function PlayerHead:onDingqueAnimEnd(event)
    Log.i("------onDingqueAnimEnd event", unpack(event._userdata));
    local result, site = unpack(event._userdata);
    self:setDingQueResult(result, site);
end

--定缺结果
function PlayerHead:setDingQueResult(result, site)
    Log.i("------setDingQueResult site", site);
    Log.i("------setDingQueResult result", result);
    local imgDingque = self:getWidget(self.panel_heads[site], "img_dingque")
    if imgDingque then
        if not result or result == 0 then
            imgDingque:setVisible(false);
        elseif result == 1 then
            imgDingque:setVisible(true);
            imgDingque:loadTexture("games/common/mj/games/dq_icon_wan.png");
        elseif result == 2 then
            imgDingque:setVisible(true);
            imgDingque:loadTexture("games/common/mj/games/dq_icon_tiao.png");
        elseif result == 3 then
            imgDingque:setVisible(true);
            imgDingque:loadTexture("games/common/mj/games/dq_icon_tong.png");
        end
    end
end

--[[
    -- @brief 拉跑坐结果
    -- @return void
]] 
function PlayerHead:onDidLaPaoZuoEnded(event)
    local type, num, site = unpack(event._userdata)
    Log.i("==== PlayerHead onDidLaPaoZuoEnded:", unpack(event._userdata))
    self:setLaPaoZuoResualt(type, num, site)
end

if IsPortrait then -- TODO
function PlayerHead:ajustPosition(container)
    local total = #container
    if total == 1 then
        container[1]:setPositionY(0)
    elseif total ==2 then
        container[1]:setPositionY(16)
        container[2]:setPositionY(-16)
    elseif total ==3 then
        container[1]:setPositionY(32)
        container[2]:setPositionY(0)
        container[3]:setPositionY(-32)
    elseif total ==4 then
        container[1]:setPositionY(48)
        container[2]:setPositionY(16)
        container[3]:setPositionY(-16)
        container[4]:setPositionY(-48)
    end

end
end

function PlayerHead:parseLaPaoZuoWidget(parent, wName, tName, num)
    local paoPanel = ccui.Helper:seekWidgetByName(parent, wName)
    paoPanel:setVisible(true)
    local paoText = ccui.Helper:seekWidgetByName(paoPanel, tName)
    paoText:setString("" .. num)
    paoText:setFontSize(16)

    if IsPortrait then -- TODO
        if parent.container == nil then
            parent.container = {}
            parent.container[1]=paoPanel
        else
            local total = #parent.container
            for k,v in pairs(parent.container) do
                if v == paoPanel then
                    return
                end
            end
            parent.container[total+1] = paoPanel
            self:ajustPosition(parent.container)
        end
    end
end

--[[
 -- @brief 设置拉跑坐头像显示的结果
 -- @param type 类型，num 多少底，多少坐，多少拉，多少跑等, site 位置
 -- @return void
]]
function PlayerHead:setLaPaoZuoResualt(type, num, site)
    Log.i("PlayerHead:setLaPaoZuoResult===>>", type, num, site)
    if not type or (not num or num <= 0) then
        return
    end

    if type == enOperate.OPERATE_XIA_PAO then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "pao_panel", "text_pao", num)
    elseif type == enOperate.OPERATE_LAZHUANG then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "la_panel", "text_la", num)
        local zuoIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_la")
        zuoIcon:loadTexture("games/common/game/common/icon_la.png")
    elseif type == enOperate.OPERATE_ZUO then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "la_panel", "text_la", num)
        local zuoIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_la")
        zuoIcon:loadTexture("games/common/game/common/icon_zuo.png")
    elseif type == enOperate.OPERATE_XIADI then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "di_panel", "text_di", num)
    end
end

function PlayerHead:getDingQueResultPosition(site)
    --Log.i("------getDingQueResultPosition site", site);
    local imgDingque = self:getWidget(self.panel_heads[site], "img_dingque")
    local btnPositionX = imgDingque:getPositionX();
    local btnPositionY = imgDingque:getPositionY();
    local wp = self.panel_heads[site]:convertToWorldSpace(cc.p(btnPositionX, btnPositionY));
    return wp;
end

function PlayerHead:updateHead(panel_head, site)
    local image_head_bg = self:getWidget(panel_head,"Image_head_bg")
    -- image_head_bg:setScale(70/ image_head_bg:getContentSize().width)
    image_head_bg:setTag(site);
    image_head_bg:addTouchEventListener(handler(self,self.onClickHead))
    local bgSize = image_head_bg:getContentSize()
    --头像
    local image_head_Sprite = self:getWidget(panel_head,"Image_head_Sprite")
    -- image_head_Sprite:ignoreContentAdaptWithSize(false);
    -- image_head_Sprite:setContentSize(cc.size(bgSize.width - 6, bgSize.height - 6))
    -- image_head_Sprite:setScale(70 / image_head_Sprite:getContentSize().width)
    self:getPlayerHead(image_head_Sprite, site)
    local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
    --名字
    local strNickName = playerObj:getProp(enCreatureEntityProp.NAME)
    local nickName = ToolKit.subUtfStrByCn(strNickName,0,5,"")
    local label_player_name = self:getWidget(panel_head,"Label_player_name")
    -- label_player_name:setString(nickName)
    Util.updateNickName(label_player_name, nickName, 19)

    --积分
    local strMoney = tostring(playerObj:getProp(enCreatureEntityProp.FORTUNE))
    local fortuneLabel = self:getWidget(panel_head, "player_score")
    fortuneLabel:setName("jifenLabel")
    table.insert(self.fortuneLabels, fortuneLabel)
    fortuneLabel:setString(strMoney)
    if IsPortrait then -- TODO
        fortuneLabel:enableOutline(cc.c4b(63,34,4,255), 2)
    end

    --庄
    local image_zhuang = self:getWidget(panel_head,"Image_zhuang")
    image_zhuang:setVisible(false)
    --聊天背景
    local image_cat_bg = self:getWidget(panel_head,"Image_cat_bg")
    image_cat_bg:setVisible(false)

    --离线图片
    local image_substitute = self:getWidget(panel_head,"Image_substitute")
    image_substitute:setVisible(false)

	--听UI背景
    local tinPaiOpImage = self:getWidget(panel_head,"tinPaiOpImage")
    tinPaiOpImage:setVisible(false)
    -- --跑1图片
    -- local image_pao1 = self:getWidget(panel_head,"Image_pao_1")
    -- image_pao1:setVisible(false)
    -- local actType = MjProxy:getInstance():getModeType()
    -- image_pao1:loadTexture(kModePng[actType], ccui.TextureResType.localType)

    -- --跑2图片
    -- local image_pao2 = self:getWidget(panel_head,"Image_pao_2")
    -- image_pao2:setVisible(false)
    -- local actType = MjProxy:getInstance():getModeType()
    -- image_pao2:loadTexture(kModePng[actType], ccui.TextureResType.localType)

    -- 聊天语音条
    self.speakPanel[site] = self:getWidget(panel_head,"Panel_speak")
    self.speakPanel[site]:setVisible(false)
    -- 更新ip相同
    -- self:ipXiangTong(MjProxy:getInstance()._players, image_head_Sprite,site)
    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
    self:ipXiangTong(player, image_head_Sprite, site)

    local offlineImg = self:getWidget(panel_head,"Image_offline")
    if offlineImg == nil then
        local headSize = image_head_Sprite:getContentSize()
        offlineImg = ccui.Layout:create()
        offlineImg:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        offlineImg:setBackGroundColor(cc.c3b(0,0,0))
        offlineImg:setBackGroundColorOpacity(160)
        offlineImg:setColor(cc.c4b(0, 0, 0))
        offlineImg:setContentSize(headSize)
        offlineImg:setName("Image_offline")
        image_head_Sprite:addChild(offlineImg, 100)

        local text = ccui.Text:create();
        text:setFontName("hall/font/fangzhengcuyuan.TTF")
        text:setColor(cc.c3b(255, 62, 57))
        text:setFontSize(22)
        text:setString("已断开")
        text:setPosition(cc.p(headSize.width/2, headSize.height/2))
        offlineImg:addChild(text)

        offlineImg:setVisible(false)
    end
end

function PlayerHead:onClickHead(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GamePlayerHead)

        Log.i("press head")
        local site = pWidget:getTag();
        Log.i("site........", site);
        local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
        local jindu = playerObj:getProp(enCreatureEntityProp.JING_DU)
        local weidu = playerObj:getProp(enCreatureEntityProp.WEI_DU)
        local ipA   = playerObj:getProp(enCreatureEntityProp.IP)
        local usrID = playerObj:getProp(enCreatureEntityProp.USERID)
        local wType = 2
        local headImage = self.m_headImage[site]
        local name = playerObj:getProp(enCreatureEntityProp.NAME)
        local other = {}
        local player= 0

        local playerInfos = kFriendRoomInfo:getRoomInfo();
        local players = playerInfos.pl
        for k, v in pairs(players) do
            if type(v) == "table" and v.usI then
                Log.i("players ip", i, v.ipA)
                if playerObj:getProp(enCreatureEntityProp.USERID) == v.usI and v.ipA and v.ipA ~= "" then
                    ipA = v.ipA
                    break
                end
            end
        end

        for i=1, self.playerCount - 1 do
            if other[i] == nil then
                other[i] = {}
            end
            if i >= site then
                player = i+1
            else
                player = i
            end

            local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(player)
            other[i].lo     = playerObj:getProp(enCreatureEntityProp.JING_DU)
            other[i].la     = playerObj:getProp(enCreatureEntityProp.WEI_DU)
            other[i].name   = playerObj:getProp(enCreatureEntityProp.NAME)
        end
        local data = {type = wType,playerHeadImage = headImage,playerName = name,playerIP = ipA,playerID = usrID,lo = jindu,la = weidu,site = other}
        self.infoView = UIManager:getInstance():pushWnd(PlayerPosInfoWnd,data);
        self.infoView:setDelegate(self);
    end
end

--庄家
function PlayerHead:updateBan()
    for i = 1, self.playerCount do
        local head = self:getHead(i)
        local image_zhuang = self:getWidget(head, "Image_zhuang")
        local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(i)
        local banSiteFlag = playerObj:getProp(enCreatureEntityProp.BANKER)
        if banSiteFlag then
            image_zhuang:setVisible(true)
        else
            image_zhuang:setVisible(false)
        end
    end
end

--定缺状态
function PlayerHead:updateDingQue()
    for i = 1, self.playerCount do
        local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(i)
        local dingqueVal = playerObj:getProp(enCreatureEntityProp.DINGQUE_VAL)
        self:setDingQueResult(dingqueVal, i);
    end
end

function PlayerHead:getPlayerHead(headSprite,site)
    --头像
    -- local imgURL = MjProxy:getInstance()._players[site]:getIconId() or "";
    local player = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
    local imgURL = player:getProp(enCreatureEntityProp.ICON_ID)
    Log.i("------ PlayerHead imgURL", imgURL);
    if string.len(imgURL) > 3 then
        local imgName = player:getProp(enCreatureEntityProp.USERID).. ".jpg";
        local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        self.m_headImage[site] = headFile;
        if io.exists(headFile) then
            headSprite:loadTexture(headFile);
        else
            self:getNetworkImage(headSprite, imgURL, imgName, site);
        end
    else
        local headFile = "hall/Common/default_head_2.png";
        headFile = cc.FileUtils:getInstance():fullPathForFilename(headFile);
        self.m_headImage[site] = headFile;
        if io.exists(headFile) then
            headSprite:loadTexture(headFile);
        end
    end
end

function PlayerHead:getNetworkImage(headSprite, url, fileName, site)
    Log.i("PlayerHead.getNetworkImage", "-------url = " .. url);
    Log.i("PlayerHead.getNetworkImage", "-------fileName = ".. fileName);
    if url == "" then
        return
    end
    local onReponseNetworkImage = function (event)
        if event == nil then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end
        local savePath = CACHEDIR .. fileName;
        request:saveResponseData(savePath);
        self:onResponseNetImg(headSprite,fileName,site);
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

function PlayerHead:onResponseNetImg(headSprite,imgName,site)
    imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    self.m_headImage[site] = imgName;
    if io.exists(imgName) then
        headSprite:loadTexture(imgName);
    end
end

function PlayerHead:showHeadSubstitute(site,visible)
    local head = self:getHead(site)
    local image_substitute = self:getWidget(head,"Image_substitute")
    image_substitute:setVisible(visible)
end

function PlayerHead:showChat(index, site, info)
    local head = self:getHead(site)
    local image_cat_bg = self:getWidget(head,"Image_cat_bg")
   -- image_cat_bg:setVisible(true)
    local playerChat = PlayerChat.new(site, head, index, info, image_cat_bg)
    -- Log.i("------index", index);
    -- Log.i("------site", site);
    -- Log.i("------info", info);
    -- Log.i("------_gameChatTxtCfg", _gameChatTxtCfg);
end

--[[
-- @brief  显示聊天信息
-- @param  void
-- @return void
--]]

function PlayerHead:showChatMessage(chatData)
    local players       = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    Log.i("chatData....", chatData)
    for i,v in pairs(players) do
        if chatData.usI == v:getProp(enCreatureEntityProp.USERID) then
            if chatData.ty == enChatType.DEFAULT then
                local site = i
                local content = chatData.co
                local face = string.sub(content,0,5)
                local duanyu = string.sub(content, 0, 7);
                Log.i("face...", face);
                Log.i("duanyu...", duanyu);
                if face == "face_" then
                    local index = string.sub(content, 6, string.len(content));
                    chatData.ty = 1
                    chatData.emI = index
                    if tonumber(index) > 0 and tonumber(index) <= 24 then
                        self:showChat(2, site, chatData)
                    else
                        self:showChat(1, site, chatData)
                    end
                elseif duanyu == "duanyu_" then
                    local index = string.sub(content, 8, string.len(content));
                    chatData.ty = enChatType.PHRASE;
                    index = tonumber(index);
                    if index > 0 then
                        if _gameChatTxtCfg == nil or #_gameChatTxtCfg <= 0 then
                            MjProxy:getInstance():get_gameChatTxtCfg()
                        end
                        if _gameChatTxtCfg[index] then
                            chatData.emI = index;
                            chatData.co = _gameChatTxtCfg[index];
                            local sex = v:getProp(enCreatureEntityProp.SEX);
                            Log.i("sex...", sex);
                            SoundManager.playEffect(_getGameLiaotianduanyuKey(sex or 2, index));
                            --播放短语声音的时候，暂停背景音乐
                            audio.pauseMusic()
                            self.m_pWidget:performWithDelay(function() audio.resumeMusic() end, 2.0)
                        end

                    end
                    self:showChat(2, site, chatData)
                else
                    self:showChat(1, site, chatData)
                end
                break;
            end
        end
    end
end

--[[
-- @brief  显示默认聊天信息
-- @param  void
-- @return void
--]]

function PlayerHead:showDefaulyChatMessage(chatData)
    local players = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    for i,v in pairs(players) do
        if chatData.usI == v:getProp(enCreatureEntityProp.USERID) then
            if chatData.ty == enChatType.MAGIC then
                -- self._bgLayer:showMoFaBiaoQing(sSeat,chatData,i)
            else
                local site = i
                self:showChat(2, site, chatData)
            end
        end
    end
end
--[[
-- @brief  重设财富值
-- @param  void
-- @return void
--]]
function PlayerHead:refreshFortune(site)
    local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(site)
    local strMoney = playerObj:getProp(enCreatureEntityProp.FORTUNE)
    self.fortuneLabels[site]:setString(tostring(strMoney))
end

function PlayerHead:setGameLayer()
    --[[
    local poses = kGamePoses[self.playerCount]
    for i = 1, self.playerCount do
        self.panel_heads[i]:getLayoutParameter():setMargin(poses[i])
        if i == self.playerCount then
            self.panel_heads[i]:getParent():requestDoLayout()
        end
    end]]
    -- self.panel_heads[1]:getLayoutParameter():setMargin({ left = 35, right = 0, top = 0, bottom = 179})
    -- self.panel_heads[2]:getLayoutParameter():setMargin({ left = 0, right = 35, top = 0, bottom = 418})
    -- self.panel_heads[3]:getLayoutParameter():setMargin({ left = 0, right = 265, top = 35, bottom = 0})
    -- self.panel_heads[4]:getLayoutParameter():setMargin({ left = 35, right = 0, top = 251, bottom = 0})
    -- self.panel_heads[4]:getParent():requestDoLayout()
end
--[[
-- @brief  头像起始位置
-- @param  void
-- @return void
--]]

function PlayerHead:setHeadSrcPos()
    --[[
    local poses = kHeadSrcPoses[self.playerCount]
    for i = 1, self.playerCount do
        self.panel_heads[i]:getLayoutParameter():setMargin(poses[i])
        if i == self.playerCount then
            self.panel_heads[i]:getParent():requestDoLayout()
        end
    end]]
    -- self.panel_heads[1]:getLayoutParameter():setMargin()
    -- self.panel_heads[2]:getLayoutParameter():setMargin()
    -- self.panel_heads[3]:getLayoutParameter():setMargin()
    -- self.panel_heads[4]:getLayoutParameter():setMargin()
    -- self.panel_heads[4]:getParent():requestDoLayout()

    for i = 1, self.playerCount do
        self:setDingQueResult(0, i);
    end
end

--[[
-- @brief  头像打牌位置
-- @param  void
-- @return void
--]]
function PlayerHead:initReadySprite()
    self:setHeadSrcPos()
    -- 准备
	self.m_continueReadySprites = {}
    local gap = 20 -- 字与头像的间隙
    local players = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    
    local ready_icon_pos = player_icon_to_ready[#players]
    for i=1, #players do
        local head = self:getHead(i)
        local set_pos = ready_icon_pos[i]
        self.m_continueReadySprites[i] = display.newSprite("games/common/mj/common/text_ready.png")
        self.m_continueReadySprites[i]:setAnchorPoint(cc.p(0.5,0.5))
        local position = cc.p(0,0)
        if set_pos == 1 then
            position = cc.p( gap + head:getContentSize().width + self.m_continueReadySprites[i]:getContentSize().width / 2 ,
                head:getContentSize().height / 2)
        elseif set_pos == 2 then
            position = cc.p( 0 - self.m_continueReadySprites[i]:getContentSize().width / 2 - gap,
                head:getContentSize().height / 2)
        elseif set_pos == 3 then
            position = cc.p( 0 - self.m_continueReadySprites[i]:getContentSize().width / 2 - gap,
                head:getContentSize().height / 2)
            --[[position = cc.p( head:getContentSize().width / 2 ,
                - self.m_continueReadySprites[i]:getContentSize().height / 2 - gap - 20)--]]
        elseif set_pos == 4 then
            position = cc.p( gap + head:getContentSize().width + self.m_continueReadySprites[i]:getContentSize().width / 2 ,
                head:getContentSize().height / 2)
        end
		self.m_continueReadySprites[i]:setPosition(position)
        head:addChild(self.m_continueReadySprites[i], -1)
		self.m_continueReadySprites[i]:setVisible(false)
	end
end


--[[
-- @brief  初始化说话版块
-- @param  void
-- @return void
--]]
function PlayerHead:initSpeakPanel()

end

--[[
-- @brief  显示精灵图片函数
-- @param  void
-- @return void
--]]

function PlayerHead:showReadySpr(site)
    if nil == self.m_continueReadySprites then
        printError("PlayerHead:showReadySpr 无效的准备图片")
        return
    end
    if nil == self.m_continueReadySprites[site] then
        printError("PlayerHead:showReadySpr 无效的准备对象 site ========== %d", site)
        return
    end
    self.m_continueReadySprites[site]:setVisible(true)
end

--[[
-- @brief  隐藏精灵图片函数
-- @param  void
-- @return void
--]]

function PlayerHead:hideReadySpr(site)
    self.m_continueReadySprites[site]:setVisible(false)
end

function PlayerHead:getHead(site)
    local head = self.panel_heads[site]
    return head
end
--[[
-- @brief  更新下跑或者拉庄个数函数
-- @param  void
-- @return void
--]]
function PlayerHead:upDateXiaOrLaNum(site, num)
    -- local panel_head = self:getHead(site)
    -- --跑1图片
    -- if num == 0
    --     or num > maxNum then
    --     print("PlayerHead:upDateXiaOrLaNum 输入的数量是0或者过大"..num)
    --     return
    -- end

    -- for i=1, maxNum do
    --     local str = string.format("Image_pao_%d", i)
    --     local image_pao = self:getWidget(panel_head, str)
    --     if i <= num then
    --         image_pao:setVisible(true)
    --     else
    --         image_pao:setVisible(false)
    --     end
    -- end
end

--[[
-- @brief  显示语音条
-- @param  site 座位
-- @return void
--]]
function PlayerHead:showSpeakPanel(site)
    self.speakPanel[site]:setVisible(true)
end

--[[
-- @brief  隐藏语音条
-- @param  site 座位
-- @return void
--]]
function PlayerHead:hideSpeakPanel(site)
    self.speakPanel[site]:setVisible(false)
end


--ip相同
function PlayerHead:ipXiangTong(playerObj, head, site)
    local playerInfos = kFriendRoomInfo:getRoomInfo();
    local players = playerInfos.pl
    if players == nil then
        return
    end
    self:drawIpXiangTong(head, false)
    local myIp = playerObj:getProp(enCreatureEntityProp.IP)
    local myId = playerObj:getProp(enCreatureEntityProp.USERID)
    -- Log.i("myIp....", myIp, site)
    -- Log.i("myId....", myId)
    local playersRoomInfoIP = {}
    for k, v in pairs(players) do
        if type(v) == "table" and v.usI then
            -- Log.i("players ip", i, v.ipA)
            local uid = v.usI
            playersRoomInfoIP[uid] = v.ipA
            if myId == uid and v.ipA and v.ipA ~= "" then
                myIp = v.ipA
            end
        end
    end

    -- Log.i("myIp1111111.....",myIp)
    if myIp == nil or myIp == "" then return end

    for k, v in pairs(playersRoomInfoIP) do
        if k ~= myId and v == myIp then
            self:drawIpXiangTong(head, true)
            return
        end
    end
    -- 为避免断线重连后获取不到玩家IP, 在这里判断续局信息中是否有IP
    local gamePlayers = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    for k, v in pairs(gamePlayers) do
        if myId ~= v:getProp(enCreatureEntityProp.USERID) then
            -- Log.i("v:getProp(enCreatureEntityProp.IP)", v:getProp(enCreatureEntityProp.IP))
            if myIp == v:getProp(enCreatureEntityProp.IP) then
                self:drawIpXiangTong(head, true)
                return
            end
        end
    end
end

function PlayerHead:drawIpXiangTong(head, isShow)
    -- local head = self:getHead(site)
    if isShow == nil then isShow = true end
    local headOneIp = head:getChildByName("ipxiangtong")
    if headOneIp == nil then
        local ip = display.newSprite("games/common/mj/common/ipxiangtong.png")
        ip:setScale(0.85)
        ip:setName("ipxiangtong")
        ip:addTo(head)
        local headSize = head:getContentSize()
        ip:setPosition(cc.p(headSize.width/2,headSize.height/2))
        headOneIp = ip
    end
    headOneIp:setVisible(isShow)
end


function PlayerHead:showOffline(site, visible)
    local head = self:getHead(site)
    local offlineImg = self:getWidget(head,"Image_offline")
    offlineImg:setVisible(visible)    
end

--玩家听牌ui
function PlayerHead:showTinPaiOp(site,visible)
    local head = self:getHead(site)
    local tinPaiOpImage = self:getWidget(head,"tinPaiOpImage")
    tinPaiOpImage:setVisible(visible)
end

--玩家庄牌ui
function PlayerHead:showZhuangOp(site,visible)
    local head = self:getHead(site)
    local zhuangImage = self:getWidget(head,"Image_zhuang")
    zhuangImage:setVisible(visible)
end



return PlayerHead
--endregion
