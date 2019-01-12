


local CacheCollect = class("CacheCollect")

function CacheCollect:ctor()
    Log.i("CacheCollect begin")
    local files = io.open("out.txt" , "w+")
    local memory = io.open("memory.txt" , "w+")
    if not files then return end
    local sharedTextureCache = cc.Director:getInstance():getTextureCache()
    FrameProcesser = scheduler.scheduleUpdateGlobal(function()
        -- Log.i(cc.Director:getInstance():getFrameRate())
        if cc.Director:getInstance():getFrameRate() < 30 then
            local outstr = ""
            outstr = string.format("Frame rate = %.1f \n %s \n %s \n %s \n============================= %s ============================= \n",
                tostring(cc.Director:getInstance():getFrameRate()),
                string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")),
                debug.traceback(),
                sharedTextureCache:getCachedTextureInfo(),
                os.date()
                )
            files:write(outstr)
        end
    end);

    MemoryProcesser = scheduler.scheduleGlobal(function()
        memory:write(
            string.format("%.1f|%.3f|%.3f" ,
                cc.Director:getInstance():getFrameRate() ,
                cc.Director:getInstance():getSecondsPerFrame() ,
                collectgarbage("count")),
            "\n")
    end, 0.5)
    -- files:close()
end

return CacheCollect
