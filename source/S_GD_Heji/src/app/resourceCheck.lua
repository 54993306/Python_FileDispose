--win32判断一些需要地方组替换的图片资源是否已经替换，win32的时候自检

local ResourceCheck = {}

ResourceCheck.check = function()
    if device.platform ~= "windows" then
        return
    end
    if not cc.FileUtils:getInstance():isFileExist("real_res/1004789.png") then
        local errorMessage = [[
            小伙子，亲友圈分享背景图片
            package_res/config/image/club_bg.png
            忘记放了吧~
            P.S. 中心组不要把这个图片提到库上
        ]]
        -- device.showAlert("ResourceCheck.check", tostring(errorMessage), "OK")
    end
end


return ResourceCheck