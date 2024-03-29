//+------------------------------------------------------------------+
//|                                                        reSup.mq5 |
//|                                    Project source code on GitHub |
//|                                  https://github.com/mst219/reSup |
//+------------------------------------------------------------------+
#property copyright "Project source code on GitHub"
#property link      "https://github.com/mst219/reSup"
#property version   "1.00"
#property indicator_chart_window

struct struct_resup{
   datetime time;
   double price;
   char dir;
};
struct_resup resup;

input int resupX=7;// Resistance & Support(Power)

int start=0,periodSec=PeriodSeconds(_Period);
string objBN=MQLInfoString(MQL_PROGRAM_NAME)+"_",srs[];

int OnInit(){
   restart();
   return(INIT_SUCCEEDED);
}
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   if(prev_calculated==0)
		restart();
	
	int count=rates_total-1;
	for(int i=(prev_calculated<resupX?resupX:prev_calculated);i<count;i++){
	   char dir=-1;
		if( close[i]>close[i-1] || ( close[i]==close[i-1] && close[i]>=high[i]-(high[i]-low[i])/2 ) )
			dir=1;
		bool l=true,h=true;
		int x=i-resupX;
		for(int j=i-1;j>=x;j--){
			if(high[i]<high[j])
				h=false;
			if(low[i]>low[j])
				l=false;
		}
		if(dir==1){
			if( l && ( resup.dir!=-1 || low[i]<resup.price ) )
				newReSup(time[i],-1,low[i]);
			if( h && ( resup.dir!=1 || high[i]>resup.price ) )
				newReSup(time[i],1,high[i]);
		}else{// -1
			if( h && ( resup.dir!=1 || high[i]>resup.price ) )
				newReSup(time[i],1,high[i]);
			if( l && ( resup.dir!=-1 || low[i]<resup.price ) )
				newReSup(time[i],-1,low[i]);
		}
	}
	
	int i=rates_total-1;
	if(start<time[i]){
		start=time[i];
		for(i=ArraySize(srs)-1;i>=0;i--)
			ObjectSetInteger(0,srs[i],OBJPROP_TIME,1,TimeCurrent()+periodSec*9);
		ChartRedraw(0);
	}
	
   return(rates_total);
}
void OnTimer(){}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){
   switch(id){
		case CHARTEVENT_OBJECT_CLICK:
			if(StringFind(sparam,objBN+"RESUP")>-1){
				if(findSRS(sparam))
					ObjectSetInteger(0,sparam,OBJPROP_TIME,1,ObjectGetInteger(0,sparam,OBJPROP_TIME,0)+periodSec*3);
				else{
					setSRS(sparam);
					ObjectSetInteger(0,sparam,OBJPROP_TIME,1,TimeCurrent()+periodSec*9);
				}
				ChartRedraw(0);
			}
			return;
	}
}
void OnDeinit(const int reason){restart();}

//
void restart(){
   ObjectsDeleteAll(0,objBN);
   ChartRedraw(0);
}
void newReSup(datetime time,char dir,double price){
	if( resup.dir!=0 && resup.dir!=dir )
		drawReSup("RESUP_"+resup.dir+"_"+(int)resup.time,resup.time,resup.price,resup.time+periodSec*3,resup.price,clrYellow);
	resup.time=time;
	resup.dir=dir;
	resup.price=price;
}
void drawReSup(string name,const datetime t1,const double p1,const datetime t2,const double p2,color clr){
	name=objBN+name;
	if(ObjectCreate(0,name,OBJ_ARROWED_LINE,0,t1,p1,t2,p2)){
		ObjectSetInteger(0,name,OBJPROP_WIDTH,3);
		ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
	}else ObjectSetInteger(0,name,OBJPROP_TIME,0,t2);
}
void setSRS(string name){
	int i=ArraySize(srs);
	ArrayResize(srs,i+1);
	srs[i]=name;
}
bool findSRS(string name){
	for(int i=ArraySize(srs)-1;i>=0;i--)
		if(srs[i]==name){
			ArrayRemove(srs,i,1);
			return true;
		}
	return false;
}