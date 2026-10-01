; 放假倒數：版面、配色、天氣（現代版，會自動更新，請勿手動修改）

[Variables]
OX=12
OY=8
UI=Microsoft JhengHei UI
NUMFONT=Segoe UI
Card=FFFFFF
Ink=1E2430
Muted=8A93A3
Acc=3D7BD9
Tint=F2F5FA
NumC=F26A21
Badge=3D7BD9
Dot=3D7BD9
CapC=3D7BD9
TitleHi=1E2430
WDay=
DDay=
Title=
NumTxt=
Unit=
NumR=122.5
Head=
HeadY=87.5
CapTxt=
FootL=
Wx=
CD=0
CH=00
CM=00
CS=00
PieA=00
CheckA=00
PieDef=0,0 | LineTo 0,0 | ClosePath 1

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

; ===== 卡片：陰影、底、日期小月曆、圓餅／打勾、倒數區 =====
[MeterCard]
Meter=Shape
Shape=Rectangle ((-4+#OX#)*#S#),((2+#OY#)*#S#),(240*#S#),(253*#S#),(28*#S#) | Fill Color 00000008 | StrokeWidth 0
Shape2=Rectangle ((-2+#OX#)*#S#),((4+#OY#)*#S#),(236*#S#),(249*#S#),(26*#S#) | Fill Color 0000000C | StrokeWidth 0
Shape3=Rectangle ((0+#OX#)*#S#),((6+#OY#)*#S#),(232*#S#),(245*#S#),(24*#S#) | Fill Color 00000012 | StrokeWidth 0
Shape4=Rectangle ((0+#OX#)*#S#),((0+#OY#)*#S#),(232*#S#),(247*#S#),(24*#S#) | Fill Color #Card# | StrokeWidth 0
Shape5=Rectangle ((18+#OX#)*#S#),((16.5+#OY#)*#S#),(24*#S#),(25*#S#),(6*#S#) | Fill Color FFFFFF | StrokeWidth (0.6*#S#) | Stroke Color 0000001A
Shape6=Rectangle ((18+#OX#)*#S#),((26.5+#OY#)*#S#),(24*#S#),(15*#S#),(6*#S#) | Fill Color #Badge# | StrokeWidth 0
Shape7=Rectangle ((18+#OX#)*#S#),((26.5+#OY#)*#S#),(24*#S#),(6*#S#) | Fill Color #Badge# | StrokeWidth 0
Shape8=Ellipse ((201+#OX#)*#S#),((29+#OY#)*#S#),(13*#S#) | Fill Color #Acc##PieA# | StrokeWidth 0
Shape9=Ellipse ((201+#OX#)*#S#),((29+#OY#)*#S#),(8*#S#) | Fill Color FFFFFF4D | StrokeWidth 0
Shape10=Path PieP | Fill Color FFFFFF#PieA# | StrokeWidth 0
PieP=#PieDef#
Shape11=Ellipse ((201+#OX#)*#S#),((29+#OY#)*#S#),(13*#S#) | Fill Color 34C759#CheckA# | StrokeWidth 0
Shape12=Path CheckP | Fill Color 00000000 | StrokeWidth (2.4*#S#) | Stroke Color FFFFFF#CheckA# | StrokeLineJoin Round | StrokeStartCap Round | StrokeEndCap Round
CheckP=((195.5+#OX#)*#S#),((29.5+#OY#)*#S#) | LineTo ((199.1+#OX#)*#S#),((33.1+#OY#)*#S#) | LineTo ((206.5+#OX#)*#S#),((25.5+#OY#)*#S#)
Shape13=Rectangle ((18+#OX#)*#S#),((156+#OY#)*#S#),(196*#S#),(51*#S#),(14*#S#) | Fill Color #Tint# | StrokeWidth 0
DynamicVariables=1
UpdateDivider=1

[StyleText]
FontFace=#UI#
AntiAlias=1
DynamicVariables=1
StringAlign=CenterCenter

; ===== 頂列 =====
[MeterWDay]
Meter=String
MeterStyle=StyleText
Text=#WDay#
X=((30+#OX#)*#S#)
Y=((21.6+#OY#)*#S#)
FontFace=#NUMFONT#
FontSize=(5.25*#S#)
StringStyle=Bold
FontColor=#Badge#

[MeterDDay]
Meter=String
MeterStyle=StyleText
Text=#DDay#
X=((30+#OX#)*#S#)
Y=((34+#OY#)*#S#)
FontFace=#NUMFONT#
FontSize=(8.25*#S#)
StringStyle=Bold
FontColor=FFFFFF

[MeterTitle]
Meter=String
MeterStyle=StyleText
Text=#Title#
X=((115+#OX#)*#S#)
Y=((29+#OY#)*#S#)
W=(140*#S#)
ClipString=1
FontSize=(9.75*#S#)
StringStyle=Bold
FontColor=#Ink#
InlineSetting=Color | #TitleHi#
InlinePattern=(\d+ 天)
InlineSetting2=Weight | 900
InlinePattern2=(\d+ 天)

; ===== 中間：大數字 或 下班囉～／放假囉！ =====
[MeterNum]
Meter=String
MeterStyle=StyleText
Text=#NumTxt#
X=((#NumR#+#OX#)*#S#)
Y=((87.5+#OY#)*#S#)
StringAlign=RightCenter
FontFace=#NUMFONT#
FontSize=(51.75*#S#)
StringStyle=Bold
FontColor=#NumC#

[MeterUnit]
Meter=String
MeterStyle=StyleText
Text=#Unit#
X=(((#NumR#+4)+#OX#)*#S#)
Y=((104+#OY#)*#S#)
StringAlign=LeftCenter
FontSize=(14.6*#S#)
StringStyle=Bold
FontColor=#Muted#

[MeterHead]
Meter=String
MeterStyle=StyleText
Text=#Head#
X=((116+#OX#)*#S#)
Y=((#HeadY#+#OY#)*#S#)
FontSize=(22.5*#S#)
StringStyle=Bold
FontColor=#NumC#

[MeterCap]
Meter=String
MeterStyle=StyleText
Text=#CapTxt#
X=((116+#OX#)*#S#)
Y=((134.5+#OY#)*#S#)
FontSize=(8.25*#S#)
StringStyle=Bold
FontColor=#CapC#

; ===== 倒數 =====
[StyleVal]
FontFace=#NUMFONT#
FontSize=(11.25*#S#)
StringStyle=Bold
FontColor=#Ink#
Y=((176+#OY#)*#S#)

[StyleLab]
FontFace=#NUMFONT#
FontSize=(6.4*#S#)
FontColor=#Muted#
Y=((192+#OY#)*#S#)
InlineSetting=Color | #Dot#
InlinePattern=^(•)

[MeterCD]
Meter=String
MeterStyle=StyleText | StyleVal
Text=#CD#
X=((48.5+#OX#)*#S#)

[MeterCH]
Meter=String
MeterStyle=StyleText | StyleVal
Text=#CH#
X=((93.5+#OX#)*#S#)

[MeterCM]
Meter=String
MeterStyle=StyleText | StyleVal
Text=#CM#
X=((138.5+#OX#)*#S#)

[MeterCS]
Meter=String
MeterStyle=StyleText | StyleVal
Text=#CS#
X=((183.5+#OX#)*#S#)

[MeterCDL]
Meter=String
MeterStyle=StyleText | StyleLab
Text=• Days
X=((48.5+#OX#)*#S#)
InlineSetting2=Color | #Dot#59
InlinePattern2=^(•)

[MeterCHL]
Meter=String
MeterStyle=StyleText | StyleLab
Text=• Hrs
X=((93.5+#OX#)*#S#)
InlineSetting2=Color | #Dot#8C
InlinePattern2=^(•)

[MeterCML]
Meter=String
MeterStyle=StyleText | StyleLab
Text=• Min
X=((138.5+#OX#)*#S#)
InlineSetting2=Color | #Dot#BF
InlinePattern2=^(•)

[MeterCSL]
Meter=String
MeterStyle=StyleText | StyleLab
Text=• Sec
X=((183.5+#OX#)*#S#)

; ===== 底列 =====
[MeterFootL]
Meter=String
MeterStyle=StyleText
Text=#FootL#
X=((18+#OX#)*#S#)
Y=((225.5+#OY#)*#S#)
StringAlign=LeftCenter
W=(150*#S#)
ClipString=1
FontSize=(8.25*#S#)
FontColor=#Ink#
InlineSetting=Color | #Muted#
InlinePattern=^(◷)

[MeterWx]
Meter=String
MeterStyle=StyleText
Text=#Wx#
X=((214+#OX#)*#S#)
Y=((225.5+#OY#)*#S#)
StringAlign=RightCenter
FontSize=(8.25*#S#)
FontColor=#Ink#
InlineSetting=Color | #Muted#
InlinePattern=^(\S+)

; HC-OK
