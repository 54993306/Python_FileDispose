--[[----------------------------------------
--作者：尹艳龙
--日期：2017-12-22
--摘要：性能分析模块
]]-------------------------------------------

-- define module
-- local profiler = {}
local socket = require("socket")

local profiler = class("profiler");

function profiler:ctor()
end

-- get the function title
function profiler:_func_title(funcinfo)

    -- check
    assert(funcinfo)

    -- the function name
    local name = funcinfo.name or 'anonymous'

    -- the function line
    local line = funcinfo.linedefined or 0

    -- the function source
    local source = funcinfo.source

    -- make title
    local retStr = string.format("%-20s| %-90s| %4d", name, source, line)
    -- Log.i(retStr)
    return retStr
end

-- get the function report
function profiler:_func_report(funcinfo)

    -- get the function title
    local title = self:_func_title(funcinfo)

    -- get the function report
    self.REPORTS_BY_TITLE = self.REPORTS_BY_TITLE or {}
    self._REPORTS = self._REPORTS or {}
    -- dump(self)
    local report = self.REPORTS_BY_TITLE[title]
    if not report then
        
        -- init report
        report = 
        {
            title       = title
        ,   callcount   = 0
        ,   totaltime   = 0
        }

        -- save it
        self.REPORTS_BY_TITLE[title] = report
        table.insert(self._REPORTS, report)
    end

    -- ok?
    return report
end

-- profiling call
function profiler:_profiling_call(funcinfo)

    -- get the function report
    local report = self:_func_report(funcinfo)
    assert(report)

    -- save the call time
    report.calltime    = socket.gettime()

    -- update the call count
    report.callcount   = report.callcount + 1
end

-- profiling return
function profiler:_profiling_return(funcinfo)

    -- get the stoptime
    local stoptime = socket.gettime()

    -- get the function report
    local report = self:_func_report(funcinfo)

    -- update the total time
    if report.calltime and report.calltime > 0 then
		report.totaltime = report.totaltime + (stoptime - report.calltime)
        report.calltime = 0
	end
end

-- the profiling handler
function profiler:_profiling_handler(hooktype)

    -- the function info
    local funcinfo = debug.getinfo(2, 'nS')

    -- dispatch it
    if hooktype == "call" then
        self:_profiling_call(funcinfo)
    elseif hooktype == "return" then
        self:_profiling_return(funcinfo)
    end
end

-- the tracing handler
function profiler:_tracing_handler(hooktype)

    -- the function info
    local funcinfo = debug.getinfo(2, 'nS')
    if funcinfo.what ~= "Lua" then return end
    -- is call?
    if hooktype == "call" then
        local title = self:_func_title(funcinfo)
        print(title)
    end
end

-- start profiling
function profiler:start(mode)
    Log.i("profiler:start:", mode,socket.gettime())
    -- trace?
    if mode and mode == "trace" then
        debug.sethook(handler(self, self._tracing_handler), 'cr', 0)
    else

        -- save the start time
        self._STARTIME = socket.gettime()

        -- start to hook
        debug.sethook(handler(self, self._profiling_handler), 'cr', 0)
    end
end

-- stop profiling
function profiler:stop(mode)
    Log.i("profiler:stop", mode,socket.gettime())
    -- trace?
    if mode and mode == "trace" then

        -- stop to hook
        debug.sethook()
    else
        if not self._REPORTS or #self._REPORTS == 0 then return end
        -- save the stop time
        self._STOPTIME = socket.gettime()

        -- stop to hook
        debug.sethook()

        -- calculate the total time 
        local totaltime = self._STOPTIME - self._STARTIME

        -- sort reports
        table.sort(self._REPORTS, function(a, b)
            return a.totaltime > b.totaltime
        end)
        Log.i("self._REPORTS", #self._REPORTS)
        -- print head
        local titleHead = "name                | source                                                                                    | line"
        if device.platform == "android" then
            Log.i(string.format("%-8s| %-7s| %-5s| %-20s", "costtime", "percent", "count", titleHead))
        else
            print(string.format("%-8s| %-7s| %-5s| %-20s", "costtime", "percent", "count", titleHead))
        end
        -- show reports
        for _, report in ipairs(self._REPORTS) do
            
            -- calculate percent
            local percent = (report.totaltime / totaltime) * 100
            if percent < 0.01 then
                break
            end

            -- trace
            if device.platform == "android" then
                Log.i(string.format("%3.6f| %6.2f%%| %5d| %-20s", report.totaltime, percent, report.callcount, report.title))
            else
                print(string.format("%3.6f| %6.2f%%| %5d| %-20s", report.totaltime, percent, report.callcount, report.title))
            end
        end

        -- init reports
        self._REPORTS           = {}
        self.REPORTS_BY_TITLE  = {}
   end
end

-- return module
return profiler
