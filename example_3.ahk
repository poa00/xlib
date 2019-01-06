﻿#include xdllcall.ahk

OnScreenChange(cb,
	hwnd := 0,
	x := 0, y := 0, w := '', h := '',
	timeout := -1 ) {
	; Description:
	; 	async wait for screen area to change
	; params:
	;	cb, script callback function which will be called when the screen changes, the wait times out or if an error occurs. The callback is passed one parameter, see xDllCall documentation for more details.
	;	hwnd, handle to the window to consider, omit or pass 0 to consider screen. Can also be an object: {hwnd: hwnd, hrgnClip:hrgnClip, flags:flags}, see GetDCEx documentation for details.
	;	x,y,w,h, dimensions of client area unless DCX_WINDOW flag is set. 
	;	timeout, max time in ms to wait, pass -1 to never stop waiting.
	;
	; return:
	; 	0, the area changed
	;	1, timed out, no change
	;	-1, error 1
	;	-2, error 2
	;	Both errors will occur if the window doesn't exist, but the cause can be something else too.
	
	/*
	* GetDCEx() flags
	#define DCX_WINDOW           0x00000001L
	#define DCX_CACHE            0x00000002L
	#define DCX_NORESETATTRS     0x00000004L
	#define DCX_CLIPCHILDREN     0x00000008L
	#define DCX_CLIPSIBLINGS     0x00000010L
	#define DCX_PARENTCLIP       0x00000020L
	#define DCX_EXCLUDERGN       0x00000040L
	#define DCX_INTERSECTRGN     0x00000080L
	#define DCX_EXCLUDEUPDATE    0x00000100L
	#define DCX_INTERSECTUPDATE  0x00000200L
	#define DCX_LOCKWINDOWUPDATE 0x00000400L
	#define DCX_VALIDATE         0x00200000L
	*/
	static cBitmap, screenWait, memcmp, sleep, getTickCount, gdiLib, pgdiLib
	static sleep_time := 30 ; sleep time in ms between each check.
	local
	global xlib
	if !screenWait 
		init
	
	if isobject( hwnd )
		flags := hwnd.flags, hrgnClip := hwnd.hrgnClip, hwnd := hwnd.hwnd
	else 
		hwnd := hwnd, flags := 0, hrgnClip := 0
	static DCX_WINDOW := 0x00000001
	if w == ''	; if w is omitted w and h defaults to hwnd's dimensions or screen dimensions
		( hwnd )	? (flags & DCX_WINDOW) ? wingetpos(,, w, h, 'ahk_id' hwnd) : wingetclientpos(,, w, h, 'ahk_id' hwnd) ; window or client dimensions depending on wether DCX_WINDOW flag is set or not.
					: (w:=a_screenWidth, h := a_screenHeight)
	static dir := 1 ; set to -1 to search take up side down snapshots.
	; int screenWait( _cBitmap cb, sleep psleep, getTickCount tic, HWND hwnd, pGdiLib gdi, int x, int y, int w, int h, HRGN hrgnClip, DWORD flags, int dir, unsigned int sleep_time, unsigned int timeout){
	xDllCall( cb, screenWait, 'ptr', cBitmap, 'ptr', sleep, 'ptr', getTickCount, 'ptr', hwnd, 'ptr', pgdiLib,
		'int', x, 'int', y, 'int', w, 'int', h,
		'ptr', hrgnClip, 'uint', flags, 'int', dir, 'uint', sleep_time, 'uint', timeout, 'cdecl int')
	
	init() {
		; source available in the repo, see folder: example_3_source. It is compiled with gcc -Ofast
		raw32cBitmap := [1398167381,10284161,2626355200,45092,71535360,2333373323,1267404883,2334886680,1955144827,814436388,1411667081,2300334987,2335188044,1955143755,1888181284,609519880,72387380,941913225,2299293835,2336498804,1955139696,1888177188,611617044,410028888,1009022089,2300342411,2336760948,1149968496,1137127460,12,608487168,10340,608487168,116,611617024,611617600,608471348,675515240,2216985799,0,3338665984,8922244,0,2936995840,608471494,112748,2305163264,3094357060,32,608471398,608471922,3333361456,2231558337,608471533,1904480120,2298478593,2299012220,2298750028,3539936300,2299325571,268404167,64900,607947008,941905151,2231692419,264669632,63108,138644736,337921223,0,270812359,0,136594631,0,2300851337,2366383172,2305041476,4278461508,2202281044,3229948140,941900937,13272079,1149829120,881394724,609550116,149717836,1149878405,2215592996,257,1344554123,539247815,13369376,337935497,136594631,0,69485767,0,2300851337,2333877316,2303992900,2333615172,2301895748,2333090884,2301633604,4278985796,2203591764,3229951212,807683270,608996096,2305389892,1426007052,3968024612,608471812,264275256,881443733,609550116,82608968,69500041,4280560777,2201756756,1547176172,242429988,941900939,4280550537,2202018900,3296789740,156,1566531163,3338667202,3679300,822083584,608487131,3236626480,1153882929,3942658084,7769517,69487753,874794121,4280562825,2202805332,1133054188,608471308,608486968,1284178224,1894331428,2315255807,666668534,0,2360519,4278190080,2203853908,3347645676,4294872297,113663,1153826816,3909103652,4294967126,2425393296,2425393296,2425393296]
		raw64cBitmap := [1447122753,1413567809,1398167381,3370942792,1207959552,2332574091,2039160921,678005540,1154451785,1210868107,1552494987,2336783396,2337022040,1217088536,1368082440,1099646000,1552500792,2336778276,1233856600,1753959484,1888177176,612141360,2626242672,32804,2022393856,1485522960,1082869816,612681536,144,40,407357257,0,2485431433,3338665984,10495108,0,2303197184,2304255044,2144712,255918080,2303247535,1717576796,2653195401,2298478592,9970820,28835840,1711276032,2619638921,1140850688,2937053321,48284101,2314634568,10757252,2227634176,43044,0,612681472,172,0,2955183303,0,3338665984,11805828,0,2215575552,344,1106348360,2303250943,3682945219,14320655,2303197184,1222115289,2303246469,3850637255,1157627904,2370355249,9446548,1153892352,10276,3343384576,2106436,1291845632,1209028493,4282499465,3229960405,264603977,50052,3263776768,1224313160,1747207307,2236141823,2223589568,34852,4119072512,2332033024,1097868356,826665353,3352441280,541074500,1208011776,673471625,610568516,4186523680,1149889841,1149974564,1149860900,2336763940,8397956,3506372608,2337063045,8922268,1886715904,1222216012,1478771851,2236469503,2500805101,4186523844,608471880,1221656416,2303253129,3607052785,1944401988,3918089227,608471880,2429615960,3368321352,1526726656,1096638302,1096630620,3277799774,8658703,0,1173172549,3979469873,258392555,17439,837038405,1722477549,8658703,0,1289390412,1881431177,1224313160,1747207307,445,1288765184,1881431179,1237682505,3910682505,4294967144,8658703,0,4282501425,3280554195,4294878441,2035711,113729,3979411456,4294923497,2425393407]
		cBitmap := xlib.mem.rawput(raw32cBitmap, raw64cBitmap) ; function for retrieving screen pixel data.
		
		raw32screenWait := [1398167381,9235585,258342912,3156511854,2332033024,13116548,258342912,3223622766,2332033024,11281548,258342912,3022292078,2332033024,11543708,258342912,3089407086,1711276032,2345296399,12854420,3029008384,52260,1645176320,608471491,608471364,608472436,608995616,610044192,608487204,40,608487168,44,1812948480,604277185,1076122761,1210348681,1344556169,1411669129,1478771911,0,608446735,608487216,92,609519872,1143541616,1955160100,2499770404,40996,82608896,740574347,2215624837,208,3156524171,251658240,3223633071,4278190080,11019412,1149829120,1150098468,1149849636,2422609956,3492054155,2298478592,2499748868,42020,82608896,405030027,4280550537,10495124,3968008192,611093252,1961723228,2348778872,2334663764,1951933516,956467993,826373377,2332617664,876183860,2201318786,3342401984,747237749,542375716,2198137987,13903036,1962868736,613744539,168,472138795,3559162937,1996488704,114311,199950336,824454281,542375926,2332355715,2301371460,1409229828,2213579040,3296789740,140,1566531163,4294885059,3756785663,4294967224,2431118335,2425393296,2425393296,2425393296]
		raw64screenWait := [1447122753,1413567809,1398167381,3102507336,1207959552,539270283,2332033025,22553732,258342912,941919342,1207959553,2303315849,1846503124,20980884,2336751616,21505164,2303524864,1846503110,19408004,2492137472,86052,1846502912,19932316,258342912,2303248994,1214260300,2686749833,1207959552,807685261,3277983590,615287620,352,1747235979,1275068417,807685257,610044232,1153910840,16420,258342912,3343434092,4727876,2298478592,2305303636,1282155588,1881427081,610044232,2227652728,32804,0,1143541504,3343405092,8922244,0,2492006400,43044,2217283328,36900,612665600,172,2202589183,4727932,12616719,2336489472,20456596,2370306048,1148200044,613723919,320,1106928461,1149884159,258354212,17439,1105824068,2303251711,1222115305,2284096651,1207959552,2071251333,1291814221,1076118667,613190476,128,2336303732,20529408,28851829,3942645760,2149519126,0,2148830017,29393736,2169781057,1277261308,3967154233,2202031103,2759131134,735510337,959194180,3197728710,1,2422605803,1409283633,1284196416,1409239076,1223723328,12108929,1583022080,1547787615,1581342017,3200474945,4294967294,4290305003,3959422975,2425393374,2425393296,2425393296,2425393296]
		screenWait := xlib.mem.rawput(raw32screenWait, raw64screenWait) ; function for waiting for screen change.
		
		sleep :=   xlib.ui.getFnPtrFromLib('Kernel32.dll', 'Sleep')	; to save cpu usage
		getTickCount :=   xlib.ui.getFnPtrFromLib('Kernel32.dll', 'GetTickCount')	; to track timeout
		g := 'gdi32.dll\'
		u := 'User32.dll\'
		gdiLib := xlib.ui.createlib( [	; lib needed to get screen data.
			[u . 'GetDC'                , 'GetDC'				],
			[u . 'GetDCEx'              , 'GetDCEx'             ],
			[g . 'CreateCompatibleDC'   , 'CreateCompatibleDC'  ],
			[g . 'CreateDIBSection'     , 'CreateDIBSection'    ],
			[g . 'SelectObject'         , 'SelectObject'        ],
			[g . 'BitBlt'				, 'BitBlt'			    ],
			[u . 'ReleaseDC'			, 'ReleaseDC'		    ],
			[g . 'DeleteDC'			    , 'DeleteDC'			],
			[g . 'DeleteObject'			, 'DeleteObject'		] ], , 'gdiLib' )
		pgdiLib := gdiLib.Pointer
	}
}

; Example,

msgbox 		'Press F1 to open a gui and wait for any of its pixels to change (no timeout).`n`n`n'
		.	'Press F2 to wait for the upper left corner of the screen to change (timeout 2 seconds).`n`n`n'
		.	'Press ESC to terminate the script.`n`n`n'
		.	'0 means the screen changed, 1 means the wait timed out, negative return means error.'
		


f1::
	cb := (r)=> msgbox( 'ret from gui: ' r[] ) && guifromhwnd(r[ 4 ]).destroy() ; a callback function to show the result and destroy the gui
	; create a simple gui
	gui := guiCreate()
	gui.addbutton 'w200', 'hover mouse here'
	hwnd := gui.hwnd
	gui.show()
	WinGetClientPos ,,w,h, 'ahk_id' hwnd
	sleep 250
	
	onscreenchange cb, hwnd, 0,0,w,h ; async wait for the gui to change one of its pixels, in the client area
return

f2::onscreenchange (r)=>msgbox(r[]), 0, 0, 0, 100, 100, 2000	; screen, upper left area

esc::exitapp






