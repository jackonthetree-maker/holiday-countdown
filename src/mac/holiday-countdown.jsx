// 放假倒數 桌面小月曆（Mac / Übersicht 版）
// 會每天自動到 GitHub 檢查更新。下面「設定」區塊裡的內容，更新時會保留。
import { run } from "uebersicht";

// >>> 設定（可以自己改，自動更新會保留）
const POSITION = "top: 40px; right: 40px;"; // 小工具在桌面上的位置
const SCALE = 1;                             // 大小倍率，例如 0.8、1.2
// <<< 設定

const VERSION = __VERSION__;
const REPO = "https://raw.githubusercontent.com/jackonthetree-maker/holiday-countdown/main";

// ===== 假日資料：行政院人事行政總處 115、116 年辦公日曆表 =====
const HOLIDAYS = [
  ["2026-10-09","國慶日"],["2026-10-10","國慶日"],["2026-10-25","光復節"],["2026-10-26","光復節"],
  ["2026-12-25","行憲紀念日"],["2027-01-01","開國紀念日"],
  ["2027-02-04","春節"],["2027-02-05","春節"],["2027-02-06","春節"],["2027-02-07","春節"],
  ["2027-02-08","春節"],["2027-02-09","春節"],["2027-02-10","春節"],
  ["2027-02-28","和平紀念日"],["2027-03-01","和平紀念日"],
  ["2027-04-04","兒童節、清明節"],["2027-04-05","兒童節、清明節"],["2027-04-06","兒童節、清明節"],
  ["2027-04-30","勞動節"],["2027-05-01","勞動節"],["2027-06-09","端午節"],["2027-09-15","中秋節"],
  ["2027-09-28","教師節"],["2027-10-10","國慶日"],["2027-10-11","國慶日"],["2027-10-25","光復節"],
  ["2027-12-24","行憲紀念日"],["2027-12-25","行憲紀念日"],["2027-12-31","開國紀念日"]
];
const SHORT = { "國慶日":"國慶", "光復節":"光復節", "行憲紀念日":"行憲", "開國紀念日":"元旦", "春節":"春節",
  "和平紀念日":"228", "兒童節、清明節":"清明", "勞動節":"勞動節", "端午節":"端午", "中秋節":"中秋", "教師節":"教師節" };

// ===== 配色（和 Windows 版相同）=====
const THEMES = {
  morning:   { card:"#FFFFFF", ink:"#1E2430", muted:"#8A93A3", acc:"#3D7BD9", tint:"#F2F5FA", num:"#F26A21", badge:"#3D7BD9", cap:"#3D7BD9", hi:"#1E2430" },
  afternoon: { card:"#FFF3E3", ink:"#2A2118", muted:"#977F66", acc:"#C7701F", tint:"#FBE3C4", num:"#F26A21", badge:"#C7701F", cap:"#C7701F", hi:"#2A2118" },
  night:     { card:"#1C2230", ink:"#EEF1F6", muted:"#8B95A8", acc:"#7C8CFF", tint:"#262E40", num:"#FF8A4C", badge:"#7C8CFF", cap:"#7C8CFF", hi:"#EEF1F6" },
  holiday:   { card:"#FFAE1F", ink:"#3A1F00", muted:"#7A4A00", acc:"#FFFFFF", tint:"#FFC352", num:"#FFFFFF", badge:"#FF5A00", cap:"#3A1F00", hi:"#FFFFFF" }
};
const WORK_START = 600, WORK_END = 1140, MORNING = 360, NOON = 780;
const DAY = 86400000, WD = ["日","一","二","三","四","五","六"], WDE = ["SUN","MON","TUE","WED","THU","FRI","SAT"];

// ===== 日期與放假邏輯（台灣時間）=====
const HMAP = {}; HOLIDAYS.forEach(h => { HMAP[h[0]] = h[1]; });
const key = t => new Date(t).toISOString().slice(0, 10);
const parse = k => { const [y, m, d] = k.split("-").map(Number); return Date.UTC(y, m - 1, d); };
const dow = t => new Date(t).getUTCDay();
const isOff = t => { const w = dow(t); return w === 0 || w === 6 || HMAP[key(t)] !== undefined; };
const md = t => { const d = new Date(t); return `${d.getUTCMonth() + 1}/${d.getUTCDate()}`; };
const mdw = t => `${md(t)}（${WD[dow(t)]}）`;
const at = (day, mins) => day + mins * 60000 - 8 * 3600000;
function breakAround(t) {
  let s = t, e = t; const g = [];
  while (isOff(s - DAY)) s -= DAY;
  while (isOff(e + DAY)) e += DAY;
  for (let x = s; x <= e; x += DAY) { const n = HMAP[key(x)]; const sn = n ? (SHORT[n] || n) : null; if (sn && !g.includes(sn)) g.push(sn); }
  return { start: s, end: e, len: Math.round((e - s) / DAY) + 1, name: g.join("、") };
}
const title = b => b.name ? (b.len >= 3 ? b.name + "連假" : b.name) : "週末";
function nextLianjia(from) {
  for (let x = from; x < from + 400 * DAY; x += DAY) {
    if (!isOff(x)) continue;
    const b = breakAround(x);
    if (b.start >= from && b.len >= 3) return b;
    x = b.end;
  }
  return null;
}
function getState(nowMs) {
  const p = {};
  new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Taipei", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", hour12: false })
    .formatToParts(new Date(nowMs)).forEach(x => { p[x.type] = x.value; });
  const today = parse(`${p.year}-${p.month}-${p.day}`), mins = (Number(p.hour) % 24) * 60 + Number(p.minute);
  const st = { today, mins };
  let brk = null;
  if (isOff(today)) brk = breakAround(today);
  else if (mins < WORK_START && isOff(today - DAY)) brk = breakAround(today - DAY);
  else if (mins >= WORK_END && isOff(today + DAY)) brk = breakAround(today + DAY);
  if (brk) {
    st.mode = "holiday"; st.brk = brk; st.back = brk.end + DAY; st.target = at(st.back, WORK_START);
    st.daysLeft = isOff(today) ? Math.round((brk.end - today) / DAY) + 1 : (mins >= WORK_END ? brk.len : 0);
  } else {
    st.mode = (mins >= WORK_END || mins < MORNING) ? "offwork" : "work";
    const first = mins >= WORK_END ? today + DAY : today;
    let L = first; while (!isOff(L + DAY)) L += DAY;
    st.last = L; st.workdays = Math.round((L - first) / DAY) + 1; st.target = at(L, WORK_END);
  }
  st.slot = st.mode === "holiday" ? "holiday" : (mins >= MORNING && mins < NOON) ? "morning" : (mins >= NOON && mins < WORK_END) ? "afternoon" : "night";
  st.lj = nextLianjia(st.mode === "holiday" ? st.back : today);
  return st;
}

// ===== 天氣（Open-Meteo，台北）與自動更新 =====
let weather = "";
function wxIcon(c) {
  if (c <= 1) return "☀"; if (c <= 2) return "⛅"; if (c <= 48) return "☁";
  if (c >= 95) return "⚡"; if (c <= 67 || (c >= 80 && c <= 82)) return "☂"; return "☁";
}
async function loadWeather() {
  try {
    const out = await run(`curl -fsSL --max-time 15 "https://api.open-meteo.com/v1/forecast?latitude=25.04&longitude=121.56&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Asia%2FTaipei&forecast_days=1"`);
    const d = JSON.parse(out).daily;
    weather = `${wxIcon(d.weather_code[0])} ${Math.round(d.temperature_2m_min[0])}–${Math.round(d.temperature_2m_max[0])}°`;
  } catch (e) {}
}
async function checkUpdate() {
  try {
    const remote = parseInt((await run(`curl -fsSL --max-time 15 -H "Cache-Control: no-cache" "${REPO}/version.txt"`)).trim(), 10);
    if (!(remote > VERSION)) return;
    // 下載新版、確認完整後，把「設定」區塊搬過去，再覆蓋自己；Übersicht 偵測到檔案變更會自動重新載入
    await run(`set -e
W="$HOME/Library/Application Support/Übersicht/widgets"
F=$(find "$W" -name "holiday-countdown.jsx" -not -path "*/node_modules/*" | head -n 1)
[ -n "$F" ] || exit 0
T=$(mktemp)
curl -fsSL --max-time 30 "${REPO}/mac/holiday-countdown.jsx" -o "$T"
tail -n 1 "$T" | grep -q "^// HC-OK" || exit 0
awk 'BEGIN{while((getline l < ARGV[2])>0){ if(l ~ /^\\/\\/ >>> 設定/){c=1} if(c){blk=blk l "\\n"} if(l ~ /^\\/\\/ <<< 設定/){c=0} } ARGV[2]=""}
     /^\\/\\/ >>> 設定/{ if(blk!=""){printf "%s", blk; skip=1} } !skip{print} /^\\/\\/ <<< 設定/{skip=0}' "$T" "$F" > "$T.new"
tail -n 1 "$T.new" | grep -q "^// HC-OK" && cat "$T.new" > "$F"
rm -f "$T" "$T.new"`);
  } catch (e) {}
}

let started = false;
function startBackground() {
  if (started) return;
  started = true;
  loadWeather(); checkUpdate();
  setInterval(loadWeather, 30 * 60 * 1000);
  setInterval(checkUpdate, 24 * 60 * 60 * 1000);
}

// ===== 畫面 =====
export const command = "date +%s";
export const refreshFrequency = 1000;
export const className = `
  ${POSITION}
  zoom: ${SCALE};
  font-family: -apple-system, "PingFang TC", "Helvetica Neue", sans-serif;
  -webkit-font-smoothing: antialiased;
`;

function Pie({ st, t }) {
  if (st.mode !== "work") {
    return (
      <svg width="26" height="26" viewBox="0 0 26 26">
        <circle cx="13" cy="13" r="13" fill="#34C759" />
        <path d="M7.5 13.5l3.6 3.6 7.4-7.6" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    );
  }
  const f = st.mins < WORK_START ? 1 : Math.min(1, Math.max(0, (at(st.today, WORK_END) - Date.now()) / (9 * 3600000)));
  const r = 8, a0 = 2 * Math.PI * (1 - f), x = 13 + r * Math.sin(a0), y = 13 - r * Math.cos(a0);
  let wedge = null;
  if (f >= 0.999) wedge = <circle cx="13" cy="13" r={r} fill={t.acc} fillOpacity=".45" />;
  else if (f > 0.001) wedge = <path d={`M13 13L${x.toFixed(2)} ${y.toFixed(2)}A${r} ${r} 0 ${f > 0.5 ? 1 : 0} 1 13 ${13 - r}Z`} fill={t.acc} fillOpacity=".45" />;
  return (
    <svg width="26" height="26" viewBox="0 0 26 26">
      <circle cx="13" cy="13" r="13" fill={t.acc} />
      <circle cx="13" cy="13" r={r} fill="#fff" />
      {wedge}
    </svg>
  );
}

export const render = () => {
  startBackground();
  const now = Date.now();
  const st = getState(now), t = THEMES[st.slot];
  const left = Math.max(0, st.target - now);
  const cd = [String(Math.floor(left / DAY)), String(Math.floor(left % DAY / 3600000)).padStart(2, "0"),
              String(Math.floor(left % 3600000 / 60000)).padStart(2, "0"), String(Math.floor(left % 60000 / 1000)).padStart(2, "0")];
  const d = new Date(st.today);

  let titleEl, big, cap = "", footL;
  if (st.mode === "holiday") {
    const nm = title(st.brk);
    titleEl = st.daysLeft > 0
      ? <span>{nm}還有<span style={{ color: t.hi, fontWeight: 900, margin: "0 3px" }}>{st.daysLeft} 天</span>可以玩</span>
      : <span>{nm}快結束了</span>;
    big = <span style={{ fontSize: 30, fontWeight: 900, color: t.num, letterSpacing: ".12em", paddingLeft: ".12em", lineHeight: "69px" }}>放假囉！</span>;
    footL = `${mdw(st.back)}10:00 上班`;
  } else {
    footL = st.lj ? `${title(st.lj)} ${Math.round((st.lj.start - st.today) / DAY)} 天後` : "";
    if (st.mode === "work") {
      titleEl = "距離放假";
      big = <span>
        <span style={{ fontSize: 69, fontWeight: 800, color: t.num, letterSpacing: "-.02em" }}>{st.workdays}</span>
        <span style={{ fontSize: 19.5, fontWeight: 600, color: t.muted, marginLeft: 4 }}>天</span>
      </span>;
      cap = `${mdw(st.last)}19:00 下班放假`;
    } else {
      titleEl = "今天辛苦了";
      big = <span style={{ fontSize: 30, fontWeight: 900, color: t.num, letterSpacing: ".12em", paddingLeft: ".12em", lineHeight: "69px" }}>下班囉～</span>;
      cap = "距離放假還有";
    }
  }

  const labels = ["Days", "Hrs", "Min", "Sec"];
  return (
    <div style={{ width: 232, boxSizing: "border-box", padding: "16px 18px 15px", borderRadius: 24, background: t.card, color: t.ink,
                  boxShadow: "0 10px 30px -12px rgba(0,0,0,.35)" }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ width: 24, borderRadius: 6, overflow: "hidden", boxShadow: "0 0 0 1px rgba(0,0,0,.06)", textAlign: "center", background: "#fff" }}>
          <div style={{ fontSize: 7, fontWeight: 700, color: t.badge, lineHeight: "10px" }}>{WDE[dow(st.today)]}</div>
          <div style={{ background: t.badge, color: "#fff", fontSize: 11, fontWeight: 700, lineHeight: "15px" }}>{d.getUTCDate()}</div>
        </div>
        <div style={{ fontSize: 13, fontWeight: 700 }}>{titleEl}</div>
        <Pie st={st} t={t} />
      </div>
      {cap
        ? <div>
            <div style={{ textAlign: "center", margin: "11px 0 5px", lineHeight: 1 }}>{big}</div>
            <div style={{ textAlign: "center", fontSize: 11, fontWeight: 600, color: t.cap, marginBottom: 14, minHeight: 15 }}>{cap}</div>
          </div>
        : <div style={{ textAlign: "center", margin: "22.5px 0", lineHeight: 1 }}>{big}</div>}
      <div style={{ background: t.tint, borderRadius: 14, padding: "11px 8px 10px", display: "flex" }}>
        {cd.map((v, i) => (
          <div key={i} style={{ flex: 1, textAlign: "center" }}>
            <div style={{ fontSize: 15, fontWeight: 700, color: t.ink, fontVariantNumeric: "tabular-nums", lineHeight: 1.2 }}>{v}</div>
            <div style={{ fontSize: 8.5, color: t.muted, display: "flex", alignItems: "center", justifyContent: "center", gap: 3, marginTop: 2 }}>
              <span style={{ width: 4, height: 4, borderRadius: "50%", background: st.mode === "holiday" ? t.badge : t.acc, opacity: 0.35 + 0.2 * i }} />{labels[i]}
            </div>
          </div>
        ))}
      </div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 11, fontSize: 11, fontWeight: 500 }}>
        <span><span style={{ color: t.muted }}>◷</span> {footL}</span>
        <span>{weather}</span>
      </div>
    </div>
  );
};

// HC-OK
