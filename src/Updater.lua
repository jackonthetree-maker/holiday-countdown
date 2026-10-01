-- 放假倒數：自動更新
-- 比對 GitHub 上的 version.txt，有新版就下載 Layout.inc 和 HolidayCountdown.lua，檢查完整後替換並重新整理

local MARK_LUA = "-- HC-OK"
local MARK_INC = "; HC-OK"

local function parts(v)
  local t = {}
  for n in tostring(v):gmatch("%d+") do t[#t + 1] = tonumber(n) end
  return t
end
local function newer(a, b)
  local x, y = parts(a), parts(b)
  for i = 1, math.max(#x, #y) do
    local p, q = x[i] or 0, y[i] or 0
    if p ~= q then return p > q end
  end
  return false
end
local function utf16(s)
  return (s:gsub(".", function(c) return c .. "\0" end))
end
local function readAll(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local d = f:read("*a"); f:close(); return d
end
local function writeAll(path, d)
  local f = io.open(path, "wb")
  if not f then return false end
  f:write(d); f:close(); return true
end
local function valid(d, mark)
  return d and #d > 200 and d:sub(1, 2) == "\255\254" and d:find(utf16(mark), 1, true) ~= nil
end

function Initialize()
  target = nil
  got = {}
end

function Check()
  local remote = SKIN:GetMeasure("MeasureUpdVersion"):GetStringValue()
  local localv = SKIN:GetVariable("LocalVersion")
  if remote == nil or remote == "" or not newer(remote, localv) then return end
  target = remote
  got = {}
  for _, m in ipairs({"MeasureDlLua", "MeasureDlLayout"}) do
    SKIN:Bang("!EnableMeasure", m)
    SKIN:Bang("!CommandMeasure", m, "Update")
  end
end

function Got(which)
  if not target then return end
  got[which] = true
  if not (got.lua and got.layout) then return end
  local dir = SKIN:GetVariable("CURRENTPATH") .. "DownloadFile\\"
  local lua = readAll(dir .. "new_HolidayCountdown.lua")
  local inc = readAll(dir .. "new_Layout.inc")
  if not (valid(lua, MARK_LUA) and valid(inc, MARK_INC)) then
    print("放假倒數：下載的更新不完整，這次先不更新")
    target = nil
    return
  end
  if writeAll(dir .. "HolidayCountdown.lua", lua) and writeAll(dir .. "Layout.inc", inc) then
    SKIN:Bang("!WriteKeyValue", "Variables", "LocalVersion", target)
    SKIN:Bang("!Refresh")
  end
end

function Update()
  return 0
end
