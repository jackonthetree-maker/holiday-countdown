# 放假倒數 桌面小月曆（Windows：Rainmeter／Mac：Übersicht）

給辦公室用的 Windows 桌面小工具：倒數下班、倒數放假，依台灣行政院人事行政總處辦公日曆表計算國定假日。上班時間 10:00–19:00。

## 安裝
1. 安裝 [Rainmeter](https://www.rainmeter.net/)。
2. 下載 [`dist/HolidayCountdown.rmskin`](dist/HolidayCountdown.rmskin)，雙擊安裝。
3. 用滑鼠拖到喜歡的位置，滾輪縮放。

裝一次就好：小工具開機時和之後每天會檢查這個儲存庫，有新版會自動下載並重新整理。右鍵選「檢查更新」可以手動檢查。

## Mac 安裝
1. 到 [Übersicht 官網](https://tracesof.net/uebersicht/) 下載安裝 Übersicht 並打開。
2. 下載 [`mac/holiday-countdown.jsx`](mac/holiday-countdown.jsx)。
3. 點選單列的 Übersicht 圖示 →「Open Widgets Folder」，把檔案放進去。
4. 位置和大小在檔案最上面的「設定」區塊修改，自動更新時會保留。

Mac 版每天也會自動檢查這個儲存庫並更新自己；在選單列 Übersicht →「Refresh All Widgets」會立即檢查一次。

## 檔案
- `version.txt`：目前版本號。小工具比對這個數字決定要不要更新。
- `src/`：原始檔（UTF-8，方便編輯）。
  - `Layout.inc`：版面、配色、天氣
  - `HolidayCountdown.lua`：放假邏輯與國定假日資料
  - `HolidayCountdown.ini`、`Updater.lua`：安裝後不會再變的外殼與自動更新
- `skin/`：由 `build.py` 產生的 UTF-16 LE 檔案，小工具從這裡下載。
- `dist/`：Windows 安裝檔。
- `src/mac/holiday-countdown.jsx` → `mac/holiday-countdown.jsx`：Mac（Übersicht）版。假日資料和邏輯要和 Lua 版同步修改。

## 發布更新
1. 修改 `src/` 裡的檔案。
2. 把 `version.txt` 的版本號加 1，**只用整數**（例如 4 → 5）。早期安裝的外殼只認得第一個數字，所以 9 以前都用一位數整數。
3. `python3 build.py`
4. commit 並 push 到 `main`。

注意：`src/HolidayCountdown.ini` 和 `src/Updater.lua` 不會自動更新，改了需要大家重新安裝。
