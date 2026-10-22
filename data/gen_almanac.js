// 農民曆資料產生器：npm i lunar-javascript && node gen_almanac.js almanac.json
// 只取「宜」裡的財運／祈福項目（最多 2 項，財運優先）、財神方位、節氣
const {Solar}=require('lunar-javascript');
const fs=require('fs');
const MONEY=['纳财','开市','交易','立券','挂匾'], BLESS=['祈福','求嗣','开光','祭祀'];
const T={'纳财':'納財','开市':'開市','交易':'交易','立券':'立券','挂匾':'掛匾','祈福':'祈福','求嗣':'求嗣','开光':'開光','祭祀':'祭祀'};
const DIR=s=>s.replace(/东/g,'東');
const JQ={'立春':'🌱','雨水':'🌧️','惊蛰':'⚡','春分':'🌸','清明':'🌿','谷雨':'🌾','立夏':'🌞','小满':'🍃','芒种':'🌾','夏至':'☀️','小暑':'🌡️','大暑':'🔥','立秋':'🍁','处暑':'🌤️','白露':'💧','秋分':'🌕','寒露':'🌫️','霜降':'🍂','立冬':'🧣','小雪':'❄️','大雪':'🌨️','冬至':'☃️','小寒':'🧊','大寒':'🥶'};
const KEY={'DONG_ZHI':'冬至','XIAO_HAN':'小寒','DA_HAN':'大寒','LI_CHUN':'立春','YU_SHUI':'雨水','JING_ZHE':'惊蛰'};
const TR={'惊蛰':'驚蟄','谷雨':'穀雨','小满':'小滿','芒种':'芒種','处暑':'處暑'};
let out=[], rows=[], s=Solar.fromYmd(2026,10,1), jqCount=0;
for(let i=0;;i++){const d=s.next(i); if(d.getYear()>2027) break;
  const l=d.getLunar(); const yi=l.getDayYi();
  const pick=[...MONEY.filter(x=>yi.includes(x)), ...yi.filter(x=>BLESS.includes(x))].slice(0,2).map(x=>T[x]);
  let jq=l.getJieQi(); if(KEY[jq]) jq=KEY[jq];
  let jqs=''; if(jq){ if(!JQ[jq]) throw 'jq '+jq; jqs=JQ[jq]+' '+(TR[jq]||jq); jqCount++; }
  const k=d.toYmd().replace(/-/g,'');
  rows.push([k,pick.join(' · '),DIR(l.getDayPositionCaiDesc()),jqs]);
  out.push(`[${k}]={"${pick.join(' · ')}","${DIR(l.getDayPositionCaiDesc())}","${jqs}"}`);
}
fs.writeFileSync(process.argv[2]||'almanac.json', '[\n'+rows.map(r=>JSON.stringify(r)).join(',\n')+'\n]\n');
console.log(out.length,'days',jqCount,'jieqi'); console.log(out.slice(21,23).join('\n')); console.log(out.filter(x=>x.includes('"",')).length,'empty');
