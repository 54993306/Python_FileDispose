
function ccs.loadCSB(sCsPath,fCallBack)

    Log.i("ccs.loadCSB:",sCsPath)
    
    if not fCallBack then
        fCallBack=function()end
    end
	local oNode=cc.CSLoader:createNode(sCsPath,fCallBack)
    --如果要自己绑定，就用oNode:loadAction();
    function oNode.loadAnimation(oBindNode)
            local action = cc.CSLoader:createTimeline(sCsPath);
            oBindNode:runAction(action)
            action:gotoFrameAndPause(0)
            oBindNode.actionTimeline=action

            oBindNode.oEndAction=nil
            --每秒多少帧
            local perFrameTime=cc.Director:getInstance():getAnimationInterval()

            function oBindNode:playByName(sAniName,bLoop,fEndCall)
                bLoop=bLoop or false
                action:play(sAniName,bLoop)
                if not bLoop and fEndCall then
                    oBindNode:removeFrameEndCallEx()
                    local nFrame=action:getEndFrame()-action:getStartFrame()
                    local lastTime=nFrame*perFrameTime
                    oBindNode.oEndAction=performWithDelay(oBindNode,fEndCall,lastTime)
                    return oBindNode.oEndAction
                end

            end

            function oBindNode:playByIndexEx(nStartIndex, bLoop,fEndCall)
                action:gotoFrameAndPlay(nStartIndex, bLoop)
                if not bLoop and fEndCall then
                    oBindNode:removeFrameEndCallEx()
                    local nFrame=action:getEndFrame()-action:getStartFrame()
                    local lastTime=nFrame*perFrameTime
                    oBindNode.oEndAction= performWithDelay(oBindNode,fEndCall,lastTime)
                    return oBindNode.oEndAction
                end
            end

            function oBindNode:autoPlayEx(bLoop,fEndCall)
                if not bLoop then
                    bLoop=false
                end
                oBindNode:removeFrameEndCallEx()
                action:gotoFrameAndPlay(0, bLoop)
                if not bLoop  and fEndCall then
                    local nFrame=action:getEndFrame()-action:getStartFrame()
                    local lastTime=nFrame*perFrameTime
                    oBindNode.oEndAction = performWithDelay(oBindNode,fEndCall,lastTime)
                    return oBindNode.oEndAction
                end
            end

            oBindNode:onNodeEvent("exit",function()
                oBindNode:removeFrameEndCallEx()
            end)

            function oBindNode:removeFrameEndCallEx()
                if oBindNode.oEndAction then
                    oBindNode:stopAction(oBindNode.oEndAction)
                    oBindNode.oEndAction=nil
                end
            end
    end
   return oNode
end

--屏幕适配--@@全局函数，比较特殊的
function ccs.LayoutNode(oNode)
    local size = cc.Director:getInstance():getVisibleSize()

    oNode:setContentSize(size)

    ccui.Helper:doLayout(oNode)--执行布局
end

function ccs.CreateAction(oNode,sCsPath)
    local action = cc.CSLoader:createTimeline(sCsPath);
    Log.i("====================",action);
    oNode:runAction(action)
    action:gotoFrameAndPause(0)
    return action
end

function ccs.setTextDefault(oText,str,nMaxWidth)
    oText:setString(str);

	local nWidth = oText:getContentSize().width

    local nTrueWidth = nMaxWidth - 10
    if nWidth > nTrueWidth then
        oText:setScale(nTrueWidth / nWidth)
    end
end

--设置按钮的样式。
function ccs.setBtnDefualt(oBtn,text)
    -- SetBtnLabel(oBtn, cc.c4b(216,194,164,255), 18, cc.c4b(132,90,52,255), 1)
    local oLabel = oBtn:getTitleRenderer();
    ccs.setTextDefault(oLabel,text,oBtn:getContentSize().width);
end

--递归查找ccs控件
function ccs.seekNodeByName(root, sName)
    if not root then
        return
    end 

    if root:getName() == sName then
        return root
    end

    local rootChilds = root:getChildren()

    for k,v in pairs(rootChilds) do
        
        if v then
            local res = ccs.seekNodeByName( v, sName)
            if res then
                return res
            end
        end
    end
end


function ccs.readToNodeList(oNode)
    local tNodeList={};
    local function onLoad(object)
        tNodeList[object:getName()] = object
    end
    local function findChild(oRoot)
        local rootChilds = oRoot:getChildren()
        onLoad(oRoot);
        if #rootChilds > 0 then
            for k,v in ipairs(rootChilds) do
                if v then
                    findChild(v);
                end
            end
        end
    end
    findChild(oNode);
    return tNodeList
end

function ccs.IsFastDoubleClick(oNode)
   --local curTime = os.clock();
   local curTime = g_tHelper.oTimeHelper:getTimeMsec()
   Log.i("IsFastDoubleClick,curTime==",curTime)
    if not oNode.lastClickTime then
        oNode.lastClickTime=curTime;
        return false
    else
        if curTime-oNode.lastClickTime < 0.5 * 1000 then
            return true
        else
            oNode.lastClickTime=curTime;
            return false
        end
    end
end

--避免误操作和快速多次双击的逻辑
function ccs.setBtnInDrag(oBtn,fClickCall)
    local bIsMove=false;
    local function onClick(event)
        if event.name == "began" then
            bIsMove=false;
        elseif event.name =="moved" then
            bIsMove=true;
        elseif event.name == "ended" then
            if not bIsMove then
                if fClickCall then
                    if not ccs.IsFastDoubleClick(oBtn) then
                        fClickCall();
                    end
                end
            end
        end
    end 
    oBtn:onTouch(onClick)
end

