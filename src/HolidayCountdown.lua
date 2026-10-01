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

-- 配色：三個時段＋放假
THEMES = {
  morning   = { Band="2F6E9E", Paper="FFFFFF", Ink="222320", Muted="6A6F67", Line="E1E4DE", Red="CF2219", Under="E9ECEF", Track="F3D9D6", HeadC="CF2219", CDNum="222320", Acc="CF2219" },
  afternoon = { Band="C0621A", Paper="FFFDF6", Ink="222320", Muted="6F6A5E", Line="EDE5D2", Red="CF2219", Under="EDE6D4", Track="F2DDC9", HeadC="CF2219", CDNum="222320", Acc="CF2219" },
  night     = { Band="34426A", Paper="1D2433", Ink="E4E7EE", Muted="98A1B5", Line="2E3850", Red="FF6B5E", Under="161C28", Track="2E3850", HeadC="FF6B5E", CDNum="E4E7EE", Acc="FF6B5E" },
  holiday   = { Band="FF5A00", Paper="FFB627", Ink="3A1F00", Muted="6E4300", Line="FFD77A", Red="E5006E", Under="E89A10", Track="FFD77A", HeadC="FFFFFF", CDNum="FFFFFF", Acc="E5006E" }
}
-- 各狀態的文字位置（卡片座標，倍率 1）
LAYOUT = {
  work    = { CDY=155, CDLY=173, DetY=197, DashY=214, NextY=229 },
  offwork = { CDY=133, CDLY=151, DetY=190, DashY=206, NextY=222.6 },
  holiday = { CDY=152, CDLY=170, DetY=195, DashY=210.5, NextY=226 }
}
WORK_START, WORK_END, MORNING, NOON = 600, 1140, 360, 780

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
  local w
  if code == 0 then w = "晴" elseif code <= 2 then w = "晴時多雲" elseif code == 3 then w = "陰"
  elseif code <= 48 then w = "霧" elseif code >= 95 then w = "雷雨"
  elseif code <= 67 or (code >= 80 and code <= 82) then w = "有雨" else w = "多雲" end
  return w .. " " .. math.floor(lo + 0.5) .. "–" .. math.floor(hi + 0.5) .. "°"
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

local function pieDef(f, S)
  local cx, cy, r = 177 * S, 55.5 * S, 10 * S
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

  if st.key ~= stateKey then
    stateKey = st.key
    for k, v in pairs(THEMES[st.slot]) do set(k, v) end
    for k, v in pairs(LAYOUT[st.mode]) do set(k, tostring(v)) end
    set("Date", st.t.month .. "月" .. st.t.day .. "日 星期" .. WD[st.t.wday])
    local nextFrom = st.today
    if st.mode == "holiday" then
      set("Label", ""); set("Num", ""); set("Unit", "")
      set("Head", "放 假 囉 ！"); set("HeadX", "105.5")
      local chip = title(st.brk) .. "，共 " .. st.brk.len .. " 天，還可以玩"
      set("Chip", chip); set("ChipA", "FF")
      set("Detail", mdw(st.back) .. "10:00 上班")
      nextFrom = st.back
    else
      set("Chip", ""); set("ChipA", "00")
      set("Detail", mdw(st.last) .. "19:00 下班放假")
      if st.mode == "work" then
        set("Head", ""); set("Label", "距離放假還有"); set("Num", tostring(st.workdays)); set("Unit", "天")
        set("NumR", tostring(100 + (string.len(tostring(st.workdays)) * 48 - 23) / 2))
      else
        set("Label", ""); set("Num", ""); set("Unit", "")
        set("Head", "下 班 囉 ～"); set("HeadX", "100")
      end
    end
    local lj = nextLianjia(nextFrom)
    if lj then set("Next", title(lj) .. "還有 " .. (lj.start - st.today) .. " 天") else set("Next", "") end
    if st.mode == "work" then set("PieA", "FF"); set("CheckA", "00") else set("PieA", "00"); set("CheckA", "FF") end
  end

  -- 右上角圓餅：今天上班時間還剩多少
  if st.mode == "work" then
    local f = 1
    if st.mins >= WORK_START then f = math.min(1, math.max(0, (at(st.today, WORK_END) - now) / (9 * 3600))) end
    set("PieDef", pieDef(f, S))
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
