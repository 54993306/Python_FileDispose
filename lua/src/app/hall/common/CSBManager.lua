CSBManager = class("CSBManager");

CSBManager.getInstance = function()
    if not CSBManager.s_instance then
        CSBManager.s_instance = CSBManager.new();
    end

    return CSBManager.s_instance;
end

CSBManager.releaseInstance = function()
    if CSBManager.s_instance then
        CSBManager.s_instance:dtor();
    end
    CSBManager.s_instance = nil;
end

function CSBManager:ctor()
    self.widgetDir = {}
end

function CSBManager:dtor()
	for k,v in pairs(self.widgetDir) do
		v:release()
	end
	self.widgetDir = {}
end

function CSBManager:getCSBFile(filePath)
	if not self.widgetDir[filePath] then
		local widget = ccs.GUIReader:getInstance():widgetFromBinaryFile(filePath)
		self.widgetDir[filePath] = widget
		Log.i("************************************** not exist")
	end
	self.widgetDir[filePath]:retain()
	return self.widgetDir[filePath]:clone()
end