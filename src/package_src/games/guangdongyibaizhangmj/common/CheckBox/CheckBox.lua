local CheckBox = class("CheckBox",function()
	local ret = cc.Node:create()
	ret:setContentSize(cc.size(200,60))
	return ret
end)
function  CheckBox:cotr(data,callback)	
	self.m_data = data
	self.m_callback = callback
	self:initUI()
	self:initData()
end
function CheckBox:initData()
	self.m_commonTexture=
	{	
		CheckBoxbg = "package_res/games/guangdongyibaizhangmj/friendRoom/play_select_bg.png",
		CheckBoxSelected = "package_res/games/guangdongyibaizhangmj/friendRoom/play_select.png"
    }
end
function  CheckBox:initUI()
	-- cc.ui.UICheckBoxButton.new({on = self.m_commonTexture.CheckBoxSelected, off= " "})
	local checkbox = cc.CheckBox:create()
	
end
return CheckBox 	