ToolKit = {};

ToolKit.formatMoney = function(curMoney)
    local moneyStr = nil;
    local curMoneyTmp = tonumber(curMoney);
    if not curMoneyTmp then
        return curMoney;
    end

    local money = curMoneyTmp .. "";
    local length = #money;
    if length <= 6 then
        return money;
    elseif length <= 8 then
        local startStr = string.sub(money, 1, length - 4);
        local endStr1 = string.sub(money, length - 3, length - 3);
        -- local endStr2 = string.sub(money, length - 2, length - 2);
        -- if endStr2 ~= "0" then
        --     moneyStr = startStr .. "." .. endStr1 .. endStr2 .. "万";
        -- else
            if endStr1 ~= "0" then
                moneyStr = startStr .. "." .. endStr1 .. "万";
            else
                moneyStr = startStr .. "万";
            end
        --end
    elseif length >= 9 then
        local startStr = string.sub(money, 1, length - 8);
        local endStr1 = string.sub(money, length - 7, length - 7);
        -- local endStr2 = string.sub(money, length - 6, length - 6);
        -- if endStr2 ~= "0" then
        --     moneyStr = startStr .. "." .. endStr1 .. endStr2 .. "亿";
        -- else
            if endStr1 ~= "0" then
                moneyStr = startStr .. "." .. endStr1 .. "亿";
            else
                moneyStr = startStr .. "亿";
            end
        --end
    end

    return moneyStr;
end

ToolKit.formatMoney1 = function(curMoney)
    local moneyStr = nil;
    local curMoneyTmp = tonumber(curMoney);
    if not curMoneyTmp then
        return curMoney;
    end

    local money = curMoneyTmp .. "";
    local length = #money;
    if length <= 6 then
        return money;
    elseif length <= 8 then
        local startStr = string.sub(money, 1, length - 4);
        local endStr1 = string.sub(money, length - 3, length - 3);
        -- local endStr2 = string.sub(money, length - 2, length - 2);
        -- if endStr2 ~= "0" then
        --     moneyStr = startStr .. "." .. endStr1 .. endStr2 .. "万";
        -- else
            if endStr1 ~= "0" then
                moneyStr = startStr .. "." .. endStr1 .. "w";
            else
                moneyStr = startStr .. "w";
            end
        --end
    elseif length >= 9 then
        local startStr = string.sub(money, 1, length - 8);
        local endStr1 = string.sub(money, length - 7, length - 7);
        -- local endStr2 = string.sub(money, length - 6, length - 6);
        -- if endStr2 ~= "0" then
        --     moneyStr = startStr .. "." .. endStr1 .. endStr2 .. "亿";
        -- else
            if endStr1 ~= "0" then
                moneyStr = startStr .. "." .. endStr1 .. "y";
            else
                moneyStr = startStr .. "y";
            end
        --end
    end

    return moneyStr;
end
function ToolKit.formatDistance(data)
    local distanceStr = nil;
    local curDistanceTmp = tonumber(data);
    if not curDistanceTmp then
        return ""
    end
    local distanceCeil = math.ceil(curDistanceTmp)
    local distance = distanceCeil .. "";
    local length = #distance;
    if length < 4 then
        return distanceCeil.."m"
    else
        local startStr = string.sub(distance, 1, length - 3);
        local endStr1 = string.sub(distance, length - 2, length - 2)
            if endStr1 ~= "0" and endStr1 ~= "" then
                distanceStr = startStr .. "." .. endStr1 .. "km";
            else
                distanceStr = startStr .. "km";
            end
    end
    return distanceStr
end

--[[
    截断字符串，会按照utf8截断，size对应，
    一个中文一个size，
    一个大写英文一个size，
    两个小写英文一个size
]]
function ToolKit.subUtfStrByCn(str, index, size, endStr)
    if not str then
        return "";
    end
    if not index then
        return str;
    end
    if index > string.len(str) then
        return "";
    end
    local i = 1;
    local j = 1;

    local z = 1;

    local si = 1;
    local ei = 1;
    while true do
        j = i;
        local a = string.byte(string.sub(str, i) or "");
        local k = 1;
        if a then
            if a >= 252 then -- 六个字节编码
                k = 6;
            elseif a >= 248 then -- 五个字节编码
                k = 5;
            elseif a >= 240 then -- 四个字节编码
                k = 4;
            elseif a >= 224 then -- 三个字节编码
                k = 3;
            elseif a >= 192 then -- 两个字节编码
                k = 2;
            elseif a >= 64 and a <= 90 then --一个字节编码
                k = 1;
            else
                k = 1;
                local b = string.byte(string.sub(str,i+1) or "");
                if b then
                    if b < 64 or (b > 90 and b < 192) then
                        k = 2;
                    end
                else
                    k = 2;
                end
            end
        end

        if z == index then
            si = j;
        end
        i = i + k;

        if z >= (index + size) then
            ei = i - k - 1;
            break;
        end

        if i > string.len(str) then
            ei = string.len(str);
            break;
        end
        z = z + 1;
    end
    local tmp = string.sub(str, si, ei);
    if tmp and string.len(tmp) < string.len(str) then
        tmp = tmp .. endStr;
    end
    return tmp;
end


--函数功能：获取距离函数
--返回值：距离
function ToolKit.getDistance(LonA, LatA, LonB, LatB)
    -- 东西经，南北纬处理，只在国内可以不处理(假设都是北半球，南半球只有澳洲具有应用意义)
    local EARTH_RADIUS = 6378137;--赤道半径(单位m)
    local radLat1 = math.angle2radian(LonA);
    local radLat2 = math.angle2radian(LonB);
    local a = radLat1 - radLat2;
    local b = math.angle2radian(LatA) - math.angle2radian(LatB);

    local s = 2*math.asin(math.sqrt(math.pow(math.sin(a*0.5),2)+math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b*0.5),2)))
    s = s * EARTH_RADIUS;
    s = math.round(s * 10000) / 10000;
    return s;
end



function ToolKit.widthSingle(inputstr)
    -- 计算字符串宽度
    -- 可以计算出字符宽度，用于显示使用
   local lenInByte = #inputstr
   local width = 0
   local i = 1
    while (i<=lenInByte)
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                               --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                               --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
        elseif curByte >= 248 and curByte <=251 then
            byteCount = 5
        elseif curByte >= 252 then
            byteCount = 6
        end

        local char = string.sub(inputstr, i, i+byteCount-1)                                                 --看看这个字是什么
        i = i + byteCount                                               -- 重置下一字节的索引
        width = width + 1                                               -- 字符的个数（长度）
    end
    return i,width
end

--本地时间格式
function ToolKit.getLocalTimeStr()
    local data = os.date("*t", os.time());
    local hour = data.hour .. "";
    local min = data.min .. "";
    if data.hour < 10 then
        hour = "0" .. hour;
    end
    if data.min < 10 then
        min = "0" .. min;
    end
    return hour .. ":" .. min;
end
