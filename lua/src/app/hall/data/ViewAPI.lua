--ViewAPI
local ViewAPI = class("ViewAPI")

function ViewAPI:ctor()
end

--切换横屏
function ViewAPI:changeToLandscape()
    UIManager.getInstance():changeToLandscape()
end

--切换竖屏
function ViewAPI:changeToPortrait( )
    UIManager.getInstance():changeToPortrait()
end

--desc显示救济金界面
--param fCallback{Function} 救济框点击确定后回调函数
--param ...{table} 不定参数，自由发挥
--东升 你们那边加下
function ViewAPI:showSubsidy(fCallback, ...)
	--todo
    local DoleInfo = UIManager:getInstance():pushWnd(DoleInfoDialog, ...)
    DoleInfo:setsurecallback(fCallback)
end

--打开解散窗口
--data 数据
--zorder 显示层级
--delegate 代理 目前麻将里面可以为nil
function ViewAPI:showDismissView(data, zorder, delegate)
    local dismissDeskView = UIManager.getInstance():getWnd(DismissDeskView);
    if dismissDeskView == nil then
        dismissDeskView = UIManager:getInstance():pushWnd(DismissDeskView, nil, zorder or 100, delegate)
	end
    dismissDeskView:updateUI(data)
end

--打开通用弹出窗口
--param data:
-- local data = {}
-- data.type = 1                              --对话框类型：1,一个"确定"按钮  2，一个“取消”按钮和一个“确定”按钮 3. 只有内容
-- data.contentType = COMNONDIALOG_TYPE_NETWORK;  --对话框提示内容类型
-- data.content = "提示内容"                  --对话框提示内容
-- data.yesCallback                           --确定按钮回调
-- data.cancalCallback                        --取消按钮回调
-- data.closeCallback                         --关闭按钮回调
-- data.switchBtn                             --互换按钮位置
-- data.yesStr                                --确定按钮文本
-- data.cancalStr                             --取消按钮文本
-- data.closeStr                              --关闭按钮文本
-- data.canKeyBack                            --能按物理返回键关闭
function ViewAPI:showCommonDialog(data)
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

--返回登陆界面
function ViewAPI:showLoginView()
    if UIManager.getInstance():getWnd(HallLogin) then
        --在登录界面
        return;
    end

    if UIManager.getInstance():getWnd(HallMain) then
        -- 在大厅
        local info = {};
        info.isExit = true;
        UIManager.getInstance():replaceWnd(HallLogin, info);
    end
end

--打开设定窗口
function ViewAPI:showSettingView(...)
	UIManager:getInstance():pushWnd(HallSetDialog, ...)
end

--打开支付窗口
function ViewAPI:showPayView()
	UIManager.getInstance():pushWnd(quickpayment)
end


function ViewAPI:hideCommonDialog(pwidget)

end

--飘字
function ViewAPI:showToast(sText)
    Toast.getInstance():show(sText)
end

--分享截屏
function ViewAPI:shareScreen()
    TouchCaptureView.getInstance():showWithTime()
    kGameManager:shareScreen()
end

--返回键的接口
function ViewAPI:regBackKeyView(oView,func)

end

--删除返回键的接口
function ViewAPI:removeBackKeyView(oView)

end

--正在加载的接口
--text：文本描述
--time：持续时间
--touchable：是否触摸关闭加载界面
--key：加载类型
function ViewAPI:showLoadingView(text, time, touchable, key )
    LoadingView.getInstance():show(text, time, touchable, key)
end

--隐藏加载的接口
function ViewAPI:hideLoadingView(key)
    if IsPortrait then -- TODO
        if key then
            LoadingView.getInstance():hide(key)
        else
            LoadingView.getInstance():hide()
        end
    else
        LoadingView.getInstance():hide(key)
    end
end

--删除加载的接口
function ViewAPI:releaseLoadingView()
    LoadingView.releaseInstance()
end

return ViewAPI