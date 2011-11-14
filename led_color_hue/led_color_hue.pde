/*

Arduino フルカラーLEDの点滅制御ソース
色相を制御し、データを転送することを試みる

参考: 
http://www.geocities.jp/zattouka/GarageHouse/micon/Arduino/RGBLED/RGBLED1.htm

		Auther:Takayuki Akaguma
		Last Update: 2011/10/7
*/

#include <MsTimer2.h>
#include <WString.h>

// 回路の動作確認用
#define DBG_LED 0

// 個々のLEDのデータを保持
const int data_size = 8;

typedef struct _LED {
	int 	pin[3];
	int 	data[data_size];
	int 	count;
	int	hue;
}LED;

//---------------------------------------
//  設定パラメータ
//---------------------------------------
const double frame_rate = 5.0;
const int cycle_time = 1000/frame_rate; 	// 周期時間 [ms]
const int silent_cycle = 2; 	// 消灯時間 [cycle]

LED led_1 = { 
	{ 9, 10, 11 },
	{ 0, 0, 0, 1, 0, 0, 1, 1 },
	0,
	0,
};

LED led_2 = { 
	{ 2, 3, 4 },
	{ 0, 0, 0, 1, 1, 0, 1, 0 },
	0,
	0,
};

enum _RGB {
	nR,
	nG,
	nB
};


//---------------------------------------
//  定数
//---------------------------------------
// 0,1の時に移動する色相差
const int degree_0 = 120;
const int degree_1 = 240;
const int max_degree = 360;

const int LED_ON = 255;
const int LED_OFF = 0;

const int GREEN	= 120;
const int BLUE 	= 240;
const int RED 	= 0;


//---------------------------------------
//	初期設定
//---------------------------------------
void setup() {

	Serial.begin(9600);

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

	led_print(led_1.pin, led_1.data, &led_1.count, &led_1.hue);	
	led_print(led_2.pin, led_2.data, &led_2.count, &led_2.hue);	

}


//---------------------------------------
//	Hueの値を指定して描画する(360°対応)
//---------------------------------------
void led_print(const int rgb[], const int data[], int *count, int *hue)
{
	int t_cnt = *count;
	int t_hue = *hue;
	int max_size = data_size + silent_cycle;	// 消灯時間も含めたデータセット長

	if(t_cnt >= max_size) t_cnt = 0;

	// データ通信中
	if(t_cnt < data_size) {

		t_hue += (data[t_cnt]==1) ? degree_1 : degree_0;
		if(t_hue >= max_degree) {
			t_hue = t_hue - max_degree;
		}
		hue_set(rgb, t_hue, true);
	}
	// 消灯中
	else {
		if(t_cnt == data_size) {
			t_hue = 0;
                }
		hue_set(rgb, NULL, false);
	}
	++t_cnt;
	*count = t_cnt;
	*hue = t_hue;
}


//---------------------------------------
//	Hueの値を指定して描画する
//---------------------------------------
void hue_set(const int RGB[], int Hue, bool illuminate)
{
#if 0
	if(illuminate) {
		hue_paint(RGB, Hue);
	}

#else
	int R_Color = LED_OFF; 
	int G_Color = LED_OFF;
	int B_Color = LED_OFF;

	if(illuminate) {
		if (Hue == GREEN) {
 			G_Color = LED_ON; 
		} 
		else if (Hue == BLUE) {
 			B_Color = LED_ON; 
		} 
		else if (Hue == RED) {
 			R_Color = LED_ON; 
		}
		// エラーのため異なる色を発光
		else {
			R_Color = LED_ON;
			G_Color = LED_ON;
			B_Color = LED_ON;
		}
	}

	analogWrite(RGB[nR],R_Color) ;
	analogWrite(RGB[nG],G_Color) ;
	analogWrite(RGB[nB],B_Color) ;
#endif
}


//---------------------------------------
//	Hueの値を指定して描画する(360°対応)
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


#if DBG_LED
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
#endif
