"""把 src/ 的檔案轉成 Rainmeter 需要的 UTF-16 LE，輸出到 skin/，並打包安裝檔到 dist/。
更新流程：改 src/ → 把 version.txt 的版本號加 1 → python3 build.py → commit + push。"""
import io, os, struct, zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
VERSION = open(os.path.join(ROOT, 'version.txt')).read().strip()

def u16(path):
    t = open(path, encoding='utf8').read().replace('\r\n', '\n').replace('\n', '\r\n')
    return b'\xff\xfe' + t.encode('utf-16-le')

lua = u16(os.path.join(ROOT, 'src/HolidayCountdown.lua'))
inc = u16(os.path.join(ROOT, 'src/Layout.inc'))
os.makedirs(os.path.join(ROOT, 'skin'), exist_ok=True)
open(os.path.join(ROOT, 'skin/HolidayCountdown.lua'), 'wb').write(lua)
open(os.path.join(ROOT, 'skin/Layout.inc'), 'wb').write(inc)

# 安裝檔（外殼＋目前版本的內容）
shell_src = open(os.path.join(ROOT, 'src/HolidayCountdown.ini'), encoding='utf8').read().replace('LocalVersion=VERSION', 'LocalVersion=' + VERSION)
shell = b'\xff\xfe' + shell_src.replace('\r\n', '\n').replace('\n', '\r\n').encode('utf-16-le')
upd = u16(os.path.join(ROOT, 'src/Updater.lua'))
rm = ('[rmskin]\nName=HolidayCountdown\nAuthor=Jack\nVersion=' + VERSION +
      '\nMinimumRainmeter=4.5.0\nMinimumWindows=10.0\nLoadType=Skin\nLoad=HolidayCountdown\\HolidayCountdown.ini\n')
files = {
    'Skins/HolidayCountdown/HolidayCountdown.ini': shell,
    'Skins/HolidayCountdown/Updater.lua': upd,
    'Skins/HolidayCountdown/DownloadFile/HolidayCountdown.lua': lua,
    'Skins/HolidayCountdown/DownloadFile/Layout.inc': inc,
}
buf = io.BytesIO()
with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as z:
    z.writestr('RMSKIN.ini', b'\xff\xfe' + rm.replace('\n', '\r\n').encode('utf-16-le'))
    for k, v in files.items():
        z.writestr(k, v)
data = buf.getvalue()
os.makedirs(os.path.join(ROOT, 'dist'), exist_ok=True)
open(os.path.join(ROOT, 'dist/HolidayCountdown.rmskin'), 'wb').write(data + struct.pack('<qB', len(data), 0) + b'RMSKIN\x00')
with zipfile.ZipFile(os.path.join(ROOT, 'dist/HolidayCountdown-manual.zip'), 'w', zipfile.ZIP_DEFLATED) as z:
    for k, v in files.items():
        z.writestr(k.replace('Skins/', ''), v)
# Mac（Übersicht）版
mac = open(os.path.join(ROOT, 'src/mac/holiday-countdown.jsx'), encoding='utf8').read().replace('__VERSION__', str(int(float(VERSION))))
os.makedirs(os.path.join(ROOT, 'mac'), exist_ok=True)
open(os.path.join(ROOT, 'mac/holiday-countdown.jsx'), 'w', encoding='utf8').write(mac)
print('built version', VERSION)
