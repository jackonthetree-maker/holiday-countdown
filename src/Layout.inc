; 放假倒數：版面、配色、天氣（會自動更新，請勿手動修改）

[Variables]
UI=Microsoft JhengHei UI
Band=2F6E9E
Paper=FFFFFF
Ink=222320
Muted=6A6F67
Line=E1E4DE
Red=CF2219
Under=E9ECEF
Track=F3D9D6
HeadC=CF2219
CDNum=222320
Acc=CF2219
Date=
Wx=
Label=
Num=
Unit=
NumR=112.5
Head=
HeadX=100
Chip=
ChipA=00
Detail=
Next=
CD=0
CH=00
CM=00
CS=00
CDY=155
CDLY=173
DetY=197
DashY=214
NextY=229
PieA=00
CheckA=00
PieDef=177,55.5 | LineTo 177,55.5 | ClosePath 1

; ===== 天氣（Open-Meteo，台北，每 30 分鐘更新）=====
[MeasureWx]
Measure=WebParser
URL=https://api.open-meteo.com/v1/forecast?latitude=25.04&longitude=121.56&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=Asia%2FTaipei&forecast_days=1
RegExp=(?siU)"daily":\{.*"weather_code":\[(\d+)\].*"temperature_2m_max":\[([-\d.]+)\].*"temperature_2m_min":\[([-\d.]+)\]
UpdateRate=1800

[MeasureWxCode]
Measure=WebParser
URL=[MeasureWx]
StringIndex=1

[MeasureWxMax]
Measure=WebParser
URL=[MeasureWx]
StringIndex=2

[MeasureWxMin]
Measure=WebParser
URL=[MeasureWx]
StringIndex=3

[MeasureScript]
Measure=Script
ScriptFile=#CURRENTPATH#DownloadFile\HolidayCountdown.lua

; ===== 底圖：下層紙、紙張、日期色帶、虛線、圓餅／打勾 =====
[MeterBG]
Meter=Shape
Shape=Rectangle (3*#S#),(34*#S#),(194*#S#),(211*#S#),(4*#S#) | Fill Color #Under# | StrokeWidth 0
Shape2=Rectangle 0,(26*#S#),(200*#S#),(215*#S#),(4*#S#) | Fill Color #Paper# | StrokeWidth 0
Shape3=Rectangle 0,0,(200*#S#),(29*#S#),(6*#S#) | Fill Color #Band# | StrokeWidth 0
Shape4=Rectangle 0,(18*#S#),(200*#S#),(11*#S#) | Fill Color #Band# | StrokeWidth 0
Shape5=Line (13*#S#),(#DashY#*#S#),(187*#S#),(#DashY#*#S#) | StrokeWidth (1*#S#) | Stroke Color #Line# | StrokeDashes 3,3
Shape6=Ellipse (177*#S#),(55.5*#S#),(10*#S#) | Fill Color #Track##PieA# | StrokeWidth 0
Shape7=Path PieP | Fill Color #Red##PieA# | StrokeWidth 0
PieP=#PieDef#
Shape8=Ellipse (177*#S#),(55.5*#S#),(10*#S#) | Fill Color 34C759#CheckA# | StrokeWidth 0
Shape9=Path CheckP | Fill Color 00000000 | StrokeWidth (2.2*#S#) | Stroke Color FFFFFF#CheckA# | StrokeLineJoin Round | StrokeStartCap Round | StrokeEndCap Round
CheckP=(172.42*#S#),(55.92*#S#) | LineTo (175.42*#S#),(58.92*#S#) | LineTo (181.58*#S#),(52.58*#S#)
DynamicVariables=1

[StyleText]
FontFace=#UI#
AntiAlias=1
DynamicVariables=1

; ===== 日期色帶 =====
[MeterDate]
Meter=String
MeterStyle=StyleText
Text=#Date#
X=(12*#S#)
Y=(14.5*#S#)
StringAlign=LeftCenter
FontSize=(8.6*#S#)
StringStyle=Bold
FontColor=FFFFFF

[MeterWx]
Meter=String
MeterStyle=StyleText
Text=#Wx#
X=(188*#S#)
Y=(14.5*#S#)
StringAlign=RightCenter
FontSize=(8.4*#S#)
FontColor=FFFFFF

; ===== 上班中：標題＋大數字 =====
[MeterLabel]
Meter=String
MeterStyle=StyleText
Text=#Label#
X=(13*#S#)
Y=(52.5*#S#)
StringAlign=LeftCenter
FontSize=(9.4*#S#)
StringStyle=Bold
FontColor=#Ink#

[MeterNum]
Meter=String
MeterStyle=StyleText
Text=#Num#
X=(#NumR#*#S#)
Y=(103*#S#)
StringAlign=RightCenter
FontFace=Georgia
FontSize=(58.5*#S#)
StringStyle=Bold
FontColor=#Red#

[MeterUnit]
Meter=String
MeterStyle=StyleText
Text=#Unit#
X=((#NumR#+5)*#S#)
Y=(120*#S#)
StringAlign=LeftCenter
FontSize=(13.5*#S#)
StringStyle=Bold
FontColor=#Red#

; ===== 下班囉～ ／ 放假囉！ =====
[MeterHead]
Meter=String
MeterStyle=StyleText
Text=#Head#
X=(#HeadX#*#S#)
Y=(86.6*#S#)
StringAlign=CenterCenter
FontSize=(25.5*#S#)
StringStyle=Bold
FontColor=#HeadC#

[MeterChipBG]
Meter=Shape
Shape=Rectangle ([MeterChip:X]-(11*#S#)),([MeterChip:Y]-(3*#S#)),([MeterChip:W]+(22*#S#)),([MeterChip:H]+(6*#S#)),(([MeterChip:H]+(6*#S#))/2) | Fill Color FFE08A#ChipA# | StrokeWidth 0
DynamicVariables=1

[MeterChip]
Meter=String
MeterStyle=StyleText
Text=#Chip#
X=(100*#S#)
Y=(126*#S#)
StringAlign=CenterCenter
FontSize=(8.25*#S#)
StringStyle=Bold
FontColor=E5006E

; ===== 倒數 =====
[StyleCD]
StringAlign=CenterCenter
FontSize=(12*#S#)
StringStyle=Bold
FontColor=#CDNum#
Y=(#CDY#*#S#)

[StyleCDLabel]
StringAlign=CenterCenter
FontSize=(7.1*#S#)
FontColor=#Muted#
Y=(#CDLY#*#S#)

[MeterCD]
Meter=String
MeterStyle=StyleText | StyleCD
Text=#CD#
X=(42.5*#S#)

[MeterCH]
Meter=String
MeterStyle=StyleText | StyleCD
Text=#CH#
X=(80.5*#S#)

[MeterCM]
Meter=String
MeterStyle=StyleText | StyleCD
Text=#CM#
X=(118.5*#S#)

[MeterCS]
Meter=String
MeterStyle=StyleText | StyleCD
Text=#CS#
X=(156.5*#S#)

[MeterCDL]
Meter=String
MeterStyle=StyleText | StyleCDLabel
Text=天
X=(42.5*#S#)

[MeterCHL]
Meter=String
MeterStyle=StyleText | StyleCDLabel
Text=時
X=(80.5*#S#)

[MeterCML]
Meter=String
MeterStyle=StyleText | StyleCDLabel
Text=分
X=(118.5*#S#)

[MeterCSL]
Meter=String
MeterStyle=StyleText | StyleCDLabel
Text=秒
X=(156.5*#S#)

; ===== 底部兩行 =====
[MeterDetail]
Meter=String
MeterStyle=StyleText
Text=#Detail#
X=(100*#S#)
Y=(#DetY#*#S#)
W=(176*#S#)
ClipString=1
StringAlign=CenterCenter
FontSize=(8.25*#S#)
FontColor=#Ink#

[MeterNext]
Meter=String
MeterStyle=StyleText
Text=#Next#
X=(100*#S#)
Y=(#NextY#*#S#)
W=(176*#S#)
ClipString=1
StringAlign=CenterCenter
FontSize=(7.9*#S#)
FontColor=#Ink#
InlineSetting=Color | #Acc#
InlinePattern=(\d+)(?= 天)
InlineSetting2=Size | (10*#S#)
InlinePattern2=(\d+)(?= 天)
InlineSetting3=Weight | 700
InlinePattern3=(\d+)(?= 天)

; HC-OK
