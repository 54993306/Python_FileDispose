--大厅-HallAPI
local HallAPI = class("HallAPI")

package.loaded["app.hall.data.DataAPI"] = nil;
package.loaded["app.hall.data.ViewAPI"] = nil;
package.loaded["app.hall.data.SoundAPI"] = nil;
package.loaded["app.hall.data.EventAPI"] = nil;

local DataAPI = require("app.hall.data.DataAPI")
local ViewAPI = require("app.hall.data.ViewAPI")
local SoundAPI = require("app.hall.data.SoundAPI")
local EventAPI = require("app.hall.data.EventAPI")

HallAPI.DataAPI = DataAPI.new()

HallAPI.ViewAPI = ViewAPI.new()

HallAPI.SoundAPI = SoundAPI.new()

HallAPI.EventAPI = EventAPI.new()

return HallAPI
