
IosChargeList = {
	[CONFIG_GAEMID] = { -- CONFIG_GAEMID
		[10102] = 10080, --key == iosProductId, value == serverGoodId
		[20102] = 10081, --key == iosProductId, value == serverGoodId
		[30102] = 10082, --key == iosProductId, value == serverGoodId
	},
	--todo
}

--为了跟旧旧版本逻辑保持一致
--payconfig.lua里面注释掉这个值。交由需要开启支付的地方组的config.lua里面去定义为true
--G_OPEN_CHARGE = true 

--IOS商品提审 不通过服务器 客户端模拟加钻的开关
--仅对服务器没有做支付功能，但是IOS要提审商品的时候用。
--正常情况下必须走服务端的支付，也就是必须为false
G_LOCAL_IOS_CHARGE_FOR_AUDIT = false 
--IOS商品提审 不通过服务器 客户端模拟加钻的数据
--go是卖的数量，pr是赠送的数量, pa0是价格，Id是跟IosChargeList的serverGoodId对应
IosLocalRechargeData = {
    { go = 6, pr = 0, pa0 = 12, Id = 10070},
    { go = 15, pr = 0, pa0 = 30, Id = 10071},
    { go = 50, pr = 0, pa0 = 98, Id = 10072},
}

local ChargeIdTool = {}

function ChargeIdTool.getIosProductId(serverGoodId)
	if serverGoodId ~= nil and IosChargeList[CONFIG_GAEMID] ~= nil then
		for k,v in pairs(IosChargeList[CONFIG_GAEMID]) do
			if v == serverGoodId then
				return k
			end
		end
	end
	return 0
end

function ChargeIdTool.getServerGoodId(iosProductId)
	if iosProductId ~= nil and IosChargeList[CONFIG_GAEMID] ~= nil then
		if IosChargeList[CONFIG_GAEMID][iosProductId] ~= nil then
			return IosChargeList[CONFIG_GAEMID][iosProductId]
		end
	end
	return 0
end

function ChargeIdTool.checkIosLocalConfig()
	if IosChargeList[CONFIG_GAEMID] then
		for k,v in pairs(IosChargeList[CONFIG_GAEMID]) do
			return true
		end
	end
	return false
end

--------------------------------下方加载包体配置-----------------------------------------

local isIOS =false
 --如果是iOS平台
 if device then
    if device.platform == "ios" then
        isIOS = true
    else
        
    end
end


local FileTools = require("app.common.FileTools")
local PayConfig_package_path = "package_src.config.PayConfig_package"
FileTools.reloadFile(PayConfig_package_path,isIOS)

return ChargeIdTool