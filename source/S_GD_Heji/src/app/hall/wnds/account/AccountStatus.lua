-----------------------------------------------------------
--  @file   AccountComFun.lua
--  @brief  账号系统状态定义文件
--  @author At.Lin
--  @DateTime:2018-07-05 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local AccountStatus = {}

if device.platform == "windows" or device.platform == "mac" then
    AccountStatus.TEST = true
else
    AccountStatus.TEST = false
end

-- 10020 登陆类型
AccountStatus.TouristLogin = 1          -- 游客登陆
AccountStatus.PhoneLogin    = 2         -- 手机登陆
AccountStatus.WechatLogin    = 3        -- 微信登陆
AccountStatus.RegistAccount  = 100      -- 手机号注册

-- 10021 登陆返回状态
AccountStatus.AccountErr = 0            -- 账户或密码错误
AccountStatus.LoginSucceed  = 1         -- 登陆成功
AccountStatus.ServerAnomaly = 2         -- 服务器异常，注册失败
AccountStatus.NeedUpVersion = 4         -- 版本过低需要强制更新
AccountStatus.RegistSucceed = 5         -- 注册成功
AccountStatus.NeedCompelUpdate = 6      -- 版本过低需要下载强更包
AccountStatus.EmptyAccount = 7          -- 空账号
AccountStatus.ProductErr  = 8           -- 产品id配置不一致
AccountStatus.TipsUpdate = 9            -- 提示下载新app
AccountStatus.DataBaseAnomaly = 10      -- 数据库账号异常
AccountStatus.ServerClose = 11          -- 服务器状态为关闭
AccountStatus.RegistDefeat = 12         -- 注册失败
AccountStatus.LoginDefeat = 13          -- 登陆失败
AccountStatus.RepeatRegist = 14         -- 账号已注册过
AccountStatus.VerifyDefeat = 15         -- 验证码失效
AccountStatus.WechatRepeat = 16         -- 微信已注册过请登陆绑定

-- 10028 找回密码状态
AccountStatus.GetPasswordSucceed = 1      -- 找回密码成功
AccountStatus.GetPasswordDefeat = 2       -- 找回密码失败
AccountStatus.GetPasswordVerifyDefeat = 3 -- 验证码失效
AccountStatus.GetPasswordVerifyErr = 4    -- 验证码错误
AccountStatus.GetPasswordAccountErr = 5   -- 账号错误
AccountStatus.GetPasswordUnPhone = 6      -- 该手机未注册
AccountStatus.GetPasswordRepeat  = 7      -- 就密码与新密码

-- 10029 获取短信验证码
AccountStatus.VerifyRegist = 1          -- 注册
AccountStatus.VerifyResetPassword = 2   -- 重置密码
AccountStatus.VerifyResertPhone = 3     -- 重置手机
AccountStatus.VerifyBindWechat = 10     -- 绑定微信

-- 10029 返回
AccountStatus.VerifyBackSucceed = 1     -- 成功
AccountStatus.VerifyBackDefeat = 2      -- 失败
AccountStatus.VerifyWait = 3            -- 获取验证码过于频繁，请稍候再试

-- 10030 短信校验
AccountStatus.CodeVerifySucceed = 1     -- 短信校验成功
AccountStatus.CodeVerifyDefeat = 2      -- 短信校验失败
AccountStatus.CodeVerifyErr = 3         -- 验证码错误
AccountStatus.PhoneRepeat = 4           -- 手机已被注册
AccountStatus.UnHavePhone = 5           -- 该手机未被注册

-- 10030 验证码校验场景
AccountStatus.VerifyCheckRegist = 1         -- 注册
AccountStatus.VerifyCheckResetPassword = 2  -- 重置密码
AccountStatus.VerifyCheckResetPhone = 3     -- 重置手机号
AccountStatus.VerifyCheckBindWechat = 4     -- 微信绑定

-- 10032 绑定微信返回
AccountStatus.WechatBindSucceed = 1         -- 绑定成功
AccountStatus.WechatBindFailed = 2          -- 绑定失败
AccountStatus.WechatBindRepeat = 3          -- 微信已被绑定


-- 51203 修改密码
AccountStatus.ChangeSucceed = 1         -- 修改密码成功
AccountStatus.ChangeDefeat = 2          -- 修改密码失败
AccountStatus.ChangeOldPasswordErr = 3  -- 旧密码错误
AccountStatus.ChangeUnRegist = 4     -- 该手机未注册

-- 51204 绑定手机
AccountStatus.BindSucceed = 1           -- 绑定手机成功
AccountStatus.BindDefeat = 2            -- 绑定手机失败
AccountStatus.BindVerifyDefeat = 3      -- 验证码失效
AccountStatus.BindVerifyErr = 4         -- 验证码错误
AccountStatus.BindPhoneRepeat = 5       -- 该手机号已被使用
AccountStatus.BindPhoneErr = 6          -- 手机号错误

-- 10029 绑定手机任务号
AccountStatus.PhoneTaskID = 10029      -- 绑定手机任务id
AccountStatus.TaskUnDeal = 0           -- 未完成任务 
AccountStatus.TaskFinish = 1           -- 任务完成尚未领取奖励
AccountStatus.TaskGiftGet = 2          -- 任务完成并领取奖励

AccountStatus.HongBao = "hongbao"       --红包界面进来
AccountStatus.HallMain = "hallMain"     --大厅界面进来
AccountStatus.SetPassWord = "passWord"  --设置密码界面进来


return AccountStatus