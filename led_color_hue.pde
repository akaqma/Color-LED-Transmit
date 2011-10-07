/*

Arduino フルカラーLEDの点滅制御ソース
色相を制御し、データを転送することを試みる

参考: 
http://www.geocities.jp/zattouka/GarageHouse/micon/Arduino/RGBLED/RGBLED1.htm

		Auther:Takayuki Akaguma
		Last Update: 2011/10/6
*/

#include <MsTimer2.h>
#include <WString.h>

// 個々のLEDのデータを保持
const int data_size = 8;

typedef struct _LED {
	int 	pin[3];
	int 	data[data_size];
	int 	num;
}LED;

//---------------------------------------
//  設定パラメータ
//---------------------------------------
const int modeHue = 0;	// 色相変化か点滅によるRGB変化か
const int cycle_time = 1000; // 周期時間 [ms]

LED led_1 = { 
	{ 9, 10, 11 },
	{ 0, 1, 0, 1, 0, 1, 0, 1 },
	0
};

LED led_2 = { 
	{ 2, 3, 4 },
	{ 0, 0, 0, 0, 1, 1, 1, 0 },
	0
};

enum _RGB {
	nR,
	nG,
	nB
};

//---------------------------------------
//	初期設定
//---------------------------------------
void setup() {

	Serial.begin(9600);

	if(modeHue) {
		;
	}
	else {
		rgb_setup(led_1.pin);
	}

	MsTimer2::set(cycle_time, led_transmit);
	MsTimer2::start();
}

//---------------------------------------
//	メインループ
//---------------------------------------
void loop()
{
	;
}

//---------------------------------------
//	割り込み処理
//---------------------------------------
void led_transmit() {
	if(modeHue) {
		//hue_loop(led_set1, 40);
		//hue_loop(led_set2, 10);
	}
	else {
		rgb_flash(led_1.pin, led_1.data, &led_1.num);
	}
}

//---------------------------------------
//	色相変化
//---------------------------------------
void hue_loop(const int RGB[], int sleep_time)
{
	int Hue ;
	int R_Color , G_Color , B_Color ;

	/* HSVのH値を0-360で回します */
	for (Hue=0 ; Hue<=360 ; Hue++) {
		/* HSVのH値を各ＬＥＤのアナログ出力値(0-255)に変換する処理 */
		if (Hue <= 120) {
			/* H値(0-120) 赤-黄-緑     */
			R_Color = map(Hue,0,120,255,0) ;     // 赤LED R←→G
			G_Color = map(Hue,0,120,0,255) ;     // 緑LED G←→R
			B_Color = 0 ;
		} else if (Hue <= 240) {
			/* H値(120-240) 緑-水色-青 */
			G_Color = map(Hue,120,240,255,0) ;   // 緑LED G←→B
			B_Color = map(Hue,120,240,0,255) ;   // 青LED B←→G
			R_Color = 0 ;
		} else {
			/* H値(240-360) 青-紫-赤   */
			B_Color = map(Hue,240,360,255,0) ;   // 青LED B←→R
			R_Color = map(Hue,240,360,0,255) ;   // 青LED R←→B
			G_Color= 0 ;
		}
		/* RGBLEDに出力する処理   */
		analogWrite(RGB[nR],R_Color) ;               // 赤LEDの出力
		analogWrite(RGB[nG],G_Color) ;               // 緑LEDの出力
		analogWrite(RGB[nB],B_Color) ;               // 青LEDの出力
		delay(sleep_time) ;
	}
}

//---------------------------------------
//	Hueの値を指定して描画する
//---------------------------------------
void hue_paint(const int RGB[], int Hue)
{
	int R_Color , G_Color , B_Color ;

	/* HSVのH値を各ＬＥＤのアナログ出力値(0-255)に変換する処理 */
	if (Hue <= 120) {
		/* H値(0-120) 赤-黄-緑     */
		R_Color = map(Hue,0,120,255,0) ;     // 赤LED R←→G
		G_Color = map(Hue,0,120,0,255) ;     // 緑LED G←→R
		B_Color = 0 ;
	} else if (Hue <= 240) {
		/* H値(120-240) 緑-水色-青 */
		G_Color = map(Hue,120,240,255,0) ;   // 緑LED G←→B
		B_Color = map(Hue,120,240,0,255) ;   // 青LED B←→G
		R_Color = 0 ;
	} else {
		/* H値(240-360) 青-紫-赤   */
		B_Color = map(Hue,240,360,255,0) ;   // 青LED B←→R
		R_Color = map(Hue,240,360,0,255) ;   // 青LED R←→B
		G_Color= 0 ;
	}
	/* RGBLEDに出力する処理   */
	analogWrite(RGB[nR],R_Color) ;               // 赤LEDの出力
	analogWrite(RGB[nG],G_Color) ;               // 緑LEDの出力
	analogWrite(RGB[nB],B_Color) ;               // 青LEDの出力
}


//---------------------------------------
//	RGBの点滅
//---------------------------------------
void rgb_flash(int rgb[], int data[], int *num)
{
	int count = *num;
	count = count % 3;
	digitalWrite(rgb[count],HIGH) ;
	digitalWrite(rgb[(count==0)?2:(count-1)],LOW) ;
	count++;
	*num = count;
}

//---------------------------------------
//	デジタル出力の場合の初期設定
//---------------------------------------
void rgb_setup(int rgb[])
{
	pinMode(rgb[nR], OUTPUT);
	pinMode(rgb[nG], OUTPUT);
	pinMode(rgb[nB], OUTPUT);
	digitalWrite(rgb[nR], LOW);
	digitalWrite(rgb[nG], LOW);
	digitalWrite(rgb[nB], LOW);
}
