-- 放假倒數 桌面小月曆（Rainmeter）
-- 假日資料：行政院人事行政總處 115、116 年辦公日曆表

HOLIDAYS = {
  {"2026-10-09","國慶日"},{"2026-10-10","國慶日"},{"2026-10-25","光復節"},{"2026-10-26","光復節"},
  {"2026-12-25","行憲紀念日"},{"2027-01-01","開國紀念日"},
  {"2027-02-04","春節"},{"2027-02-05","春節"},{"2027-02-06","春節"},{"2027-02-07","春節"},
  {"2027-02-08","春節"},{"2027-02-09","春節"},{"2027-02-10","春節"},
  {"2027-02-28","和平紀念日"},{"2027-03-01","和平紀念日"},
  {"2027-04-04","兒童節、清明節"},{"2027-04-05","兒童節、清明節"},{"2027-04-06","兒童節、清明節"},
  {"2027-04-30","勞動節"},{"2027-05-01","勞動節"},{"2027-06-09","端午節"},{"2027-09-15","中秋節"},
  {"2027-09-28","教師節"},{"2027-10-10","國慶日"},{"2027-10-11","國慶日"},{"2027-10-25","光復節"},
  {"2027-12-24","行憲紀念日"},{"2027-12-25","行憲紀念日"},{"2027-12-31","開國紀念日"}
}
SHORT = { ["國慶日"]="國慶", ["光復節"]="光復節", ["行憲紀念日"]="行憲", ["開國紀念日"]="元旦", ["春節"]="春節",
  ["和平紀念日"]="228", ["兒童節、清明節"]="清明", ["勞動節"]="勞動節", ["端午節"]="端午", ["中秋節"]="中秋", ["教師節"]="教師節" }
WD = {"日","一","二","三","四","五","六"}

-- 配色：三個時段＋放假（現代版）
THEMES = {
  morning   = { Card="FFFFFF", Ink="1E2430", Muted="8A93A3", Acc="3D7BD9", Tint="F2F5FA", NumC="F26A21", Badge="3D7BD9", Dot="3D7BD9", CapC="3D7BD9", TitleHi="1E2430" },
  afternoon = { Card="FFF3E3", Ink="2A2118", Muted="977F66", Acc="C7701F", Tint="FBE3C4", NumC="F26A21", Badge="C7701F", Dot="C7701F", CapC="C7701F", TitleHi="2A2118" },
  night     = { Card="1C2230", Ink="EEF1F6", Muted="8B95A8", Acc="7C8CFF", Tint="262E40", NumC="FF8A4C", Badge="7C8CFF", Dot="7C8CFF", CapC="7C8CFF", TitleHi="EEF1F6" },
  holiday   = { Card="FFAE1F", Ink="3A1F00", Muted="7A4A00", Acc="FFFFFF", Tint="FFC352", NumC="FFFFFF", Badge="FF5A00", Dot="FF5A00", CapC="3A1F00", TitleHi="FFFFFF" }
}
WORK_START, WORK_END, MORNING, NOON = 600, 1140, 360, 780
WDE = {"SUN","MON","TUE","WED","THU","FRI","SAT"}

local function serial(y, m, d) return math.floor(os.time({year=y, month=m, day=d, hour=12}) / 86400) end
local function toTime(s) local t = os.date("*t", s * 86400 + 43200); return t end
local function fromKey(k)
  local y, m, d = k:match("(%d+)-(%d+)-(%d+)")
  return serial(tonumber(y), tonumber(m), tonumber(d))
end
local function dow(s) return toTime(s).wday - 1 end   -- 0 = 星期日
local function md(s) local t = toTime(s); return t.month .. "/" .. t.day end
local function mdw(s) return md(s) .. "（" .. WD[dow(s) + 1] .. "）" end
local function midnight(s) local t = toTime(s); return os.time({year=t.year, month=t.month, day=t.day, hour=0, min=0, sec=0}) end

function Initialize()
  HMAP = {}
  for _, h in ipairs(HOLIDAYS) do HMAP[fromKey(h[1])] = h[2] end
  stateKey = nil
end

local function isOff(s) local w = dow(s); return w == 0 or w == 6 or HMAP[s] ~= nil end

local function breakAround(s)
  local a, b = s, s
  while isOff(a - 1) do a = a - 1 end
  while isOff(b + 1) do b = b + 1 end
  local names, seen = {}, {}
  for x = a, b do
    local n = HMAP[x]
    if n then local sn = SHORT[n] or n; if not seen[sn] then seen[sn] = true; names[#names + 1] = sn end end
  end
  return { start = a, stop = b, len = b - a + 1, name = table.concat(names, "、") }
end
local function title(b)
  if b.name == "" then return "週末" end
  if b.len >= 3 then return b.name .. "連假" end
  return b.name
end
local function nextLianjia(from)
  local x = from
  while x < from + 400 do
    if isOff(x) then
      local b = breakAround(x)
      if b.start >= from and b.len >= 3 then return b end
      x = b.stop
    end
    x = x + 1
  end
  return nil
end
local function at(s, mins)
  local t = toTime(s)
  return os.time({year=t.year, month=t.month, day=t.day, hour=math.floor(mins/60), min=mins%60, sec=0})
end
local function set(k, v) SKIN:Bang("!SetVariable", k, v) end

local function weatherText()
  local m = SKIN:GetMeasure("MeasureWxCode")
  if not m then return "" end
  local code = tonumber(m:GetStringValue())
  local hi = tonumber(SKIN:GetMeasure("MeasureWxMax"):GetStringValue())
  local lo = tonumber(SKIN:GetMeasure("MeasureWxMin"):GetStringValue())
  if not code or not hi or not lo then return "" end
  local icon
  if code <= 1 then icon = "☀" elseif code <= 2 then icon = "⛅" elseif code <= 48 then icon = "☁"
  elseif code >= 95 then icon = "⚡" elseif code <= 67 or (code >= 80 and code <= 82) then icon = "☂" else icon = "☁" end
  return icon .. " " .. math.floor(lo + 0.5) .. "–" .. math.floor(hi + 0.5) .. "°"
end

local function getState(now)
  local t = os.date("*t", now)
  local today = serial(t.year, t.month, t.day)
  local mins = t.hour * 60 + t.min
  local st = { today = today, mins = mins, t = t }
  local brk
  if isOff(today) then brk = breakAround(today)
  elseif mins < WORK_START and isOff(today - 1) then brk = breakAround(today - 1)
  elseif mins >= WORK_END and isOff(today + 1) then brk = breakAround(today + 1) end
  if brk then
    st.mode = "holiday"; st.brk = brk; st.back = brk.stop + 1
    st.target = at(st.back, WORK_START)
    if isOff(today) then st.daysLeft = brk.stop - today + 1
    elseif mins >= WORK_END then st.daysLeft = brk.len
    else st.daysLeft = 0 end
  else
    if mins >= WORK_END or mins < MORNING then st.mode = "offwork" else st.mode = "work" end
    local first = today
    if mins >= WORK_END then first = today + 1 end
    local L = first
    while not isOff(L + 1) do L = L + 1 end
    st.last = L; st.workdays = L - first + 1
    st.target = at(L, WORK_END)
  end
  if st.mode == "holiday" then st.slot = "holiday"
  elseif mins >= MORNING and mins < NOON then st.slot = "morning"
  elseif mins >= NOON and mins < WORK_END then st.slot = "afternoon"
  else st.slot = "night" end
  st.key = today .. st.mode .. st.slot
  return st
end

-- 圓餅（以卡片座標計算，再加上外框位移與縮放）
local function pieDef(f, S, ox, oy)
  local cx, cy, r = (201 + ox) * S, (29 + oy) * S, 8 * S
  if f <= 0.001 then return string.format("%.2f,%.2f | LineTo %.2f,%.2f | ClosePath 1", cx, cy, cx, cy) end
  local parts = { string.format("%.2f,%.2f", cx, cy) }
  local n = math.max(2, math.ceil(72 * f))
  for i = 0, n do
    local a = 2 * math.pi * f * i / n
    parts[#parts + 1] = string.format("LineTo %.2f,%.2f", cx + r * math.sin(a), cy - r * math.cos(a))
  end
  parts[#parts + 1] = "ClosePath 1"
  return table.concat(parts, " | ")
end

function Update()
  local now = os.time()
  local st = getState(now)
  local S = tonumber(SKIN:GetVariable("S")) or 1
  local ox = tonumber(SKIN:GetVariable("OX")) or 12
  local oy = tonumber(SKIN:GetVariable("OY")) or 8

  if st.key ~= stateKey then
    stateKey = st.key
    for k, v in pairs(THEMES[st.slot]) do set(k, v) end
    set("WDay", WDE[st.t.wday]); set("DDay", tostring(st.t.day))
    local nextFrom = st.today
    if st.mode == "holiday" then
      local nm = title(st.brk)
      if st.daysLeft > 0 then set("Title", nm .. "還有 " .. st.daysLeft .. " 天可以玩")
      else set("Title", nm .. "快結束了") end
      set("NumTxt", ""); set("Unit", ""); set("CapTxt", "")
      set("Head", "放 假 囉 ！"); set("HeadY", "99")
      set("FootL", "◷  " .. mdw(st.back) .. "10:00 上班")
      nextFrom = st.back
    else
      local lj = nextLianjia(nextFrom)
      if lj then set("FootL", "◷  " .. title(lj) .. " " .. (lj.start - st.today) .. " 天後") else set("FootL", "") end
      if st.mode == "work" then
        set("Title", "距離放假"); set("Head", "")
        set("NumTxt", tostring(st.workdays)); set("Unit", "天")
        local n = string.len(tostring(st.workdays))
        set("NumR", tostring(116 + (37 * n - 24) / 2))
        set("CapTxt", mdw(st.last) .. "19:00 下班放假")
      else
        set("Title", "今天辛苦了"); set("NumTxt", ""); set("Unit", "")
        set("Head", "下 班 囉 ～"); set("HeadY", "87.5")
        set("CapTxt", "距離放假還有")
      end
    end
    if st.mode == "work" then set("PieA", "FF"); set("CheckA", "00") else set("PieA", "00"); set("CheckA", "FF") end
  end

  if st.mode == "work" then
    local f = 1
    if st.mins >= WORK_START then f = math.min(1, math.max(0, (at(st.today, WORK_END) - now) / (9 * 3600))) end
    set("PieDef", pieDef(f, S, ox, oy))
  end

  local left = math.max(0, st.target - now)
  set("CD", tostring(math.floor(left / 86400)))
  set("CH", string.format("%02d", math.floor(left % 86400 / 3600)))
  set("CM", string.format("%02d", math.floor(left % 3600 / 60)))
  set("CS", string.format("%02d", left % 60))
  set("Wx", weatherText())
  return left
end

-- HC-OK
