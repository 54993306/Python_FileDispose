kRegionConfig = {};

REGION = 34;

kCityNameConfig = {"南京", "无锡", "徐州", "常州", "苏州", "南通", "连云港", "淮安", "盐城", "扬州", "镇江", "泰州", "宿迁"};
kCityCodeConfig = {3401, 3402, 3403, 3404, 3405, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413};

function kRegionConfig.getCityName(cityCode)
    for k, v in pairs(kCityCodeConfig) do
        if v == cityCode then
            return kCityNameConfig[k];
        end
    end
    return "江苏";
end