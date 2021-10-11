unit Uscore;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, AppEvnts;

type
  TForm2 = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Déclarations privées }
    procedure AfficheText(bmp:tbitmap;x,y:longint;t:string);
  public
    { Déclarations publiques }
    h,m,s:integer;
    fin:integer;
  end;

var
  Form2: TForm2;
  fichierouvert:string;
  score:array[0..19] of string[43];
  fond:tbitmap;

implementation

uses Unom;

{$R *.dfm}

// affiche un text sans fond
procedure TForm2.AfficheText(bmp:tbitmap;x,y:longint;t:string);
var
 texttrans:tbitmap;
begin
 texttrans:=tbitmap.Create;
 texttrans.canvas.Font.Size:=10;
 texttrans.Canvas.Font.Name:='Courier';

 texttrans.Width:=texttrans.Canvas.TextWidth(t);
 texttrans.height:=texttrans.Canvas.Textheight(t);


 texttrans.Transparent:=true;
 texttrans.TransparentColor:=clwhite;
 texttrans.Canvas.Brush.Color:=clwhite;
 texttrans.canvas.Font.color:=clblack;
 texttrans.canvas.TextOut(0,0,t);
 bmp.Canvas.draw(x,y,texttrans);

 texttrans.TransparentColor:=clblack;
 texttrans.Canvas.Brush.Color:=clblack;
 texttrans.canvas.Font.color:=clwhite;
 texttrans.canvas.TextOut(0,0,t);
 bmp.Canvas.draw(x+1,y+1,texttrans);
end;

function Completeg(s:string;c:char;n:integer):string;
begin
 while length(s)<n do s:=c+s;
 result:=s;
end;


function Completed(s:string;c:char;n:integer):string;
begin
 while length(s)<n do s:=s+c;
 result:=s;
end;

function TransRGB(aa,bb,m:longint):longint;
type
 TRGBA=array[0..3] of byte;
var
 res:TRGBA;
 r,v,b,a:longint;
begin
 m:=m and $FF;
 if m=0 then
  begin
   result:=a;
   exit;
  end;
 res[0]:=(TRGBA(aa)[0]*(255-m) + TRGBA(bb)[0]*m) div 255;
 res[1]:=(TRGBA(aa)[1]*(255-m) + TRGBA(bb)[1]*m) div 255;
 res[2]:=(TRGBA(aa)[2]*(255-m) + TRGBA(bb)[2]*m) div 255;
 res[3]:=(TRGBA(aa)[3]*(255-m) + TRGBA(bb)[3]*m) div 255;
 result:=longint(res);
end;

procedure TForm2.FormShow(Sender: TObject);
type
 longintarray=array[0..0] of longint;
 plongintarray=^longintarray;
var
 i,j:integer;
 f:integer;
 n:array[0..50+3*144] of byte;
 temps1,temps2:string;
 sc:array[0..19] of record h,m,s,p:integer;n:string; end;
 dc:hdc;
 c:tcanvas;
 rect:trect;
 parch,trans:tbitmap;
 lf,lp,lt:plongintarray;
begin
 dc:=getdc(0);
 c:=tcanvas.create;
 c.handle:=dc;

 parch:=tbitmap.Create;
 parch.LoadFromFile(extractfilepath(application.ExeName)+'parchemin.bmp');

 trans:=tbitmap.Create;
 trans.LoadFromFile(extractfilepath(application.ExeName)+'parchemin trans.bmp');

 form2.Top:=(screen.Height-parch.Height) div 2;
 form2.Left:=(screen.Width-parch.Width) div 2;
 form2.Width:=parch.Width;
 form2.Height:=parch.Height;

 fond:=tbitmap.Create;
 fond.Width:=parch.Width;
 fond.Height:=parch.Height;

 rect.Top:=(screen.Height-parch.Height) div 2;
 rect.Left:=(screen.Width-parch.Width) div 2;
 rect.Right:=rect.Left+parch.Width;
 rect.Bottom:=rect.Top+parch.Height;

 fond.Canvas.CopyRect(fond.Canvas.ClipRect,c,rect);

 fond.PixelFormat:= pf32bit;
 parch.PixelFormat:= pf32bit;
 trans.PixelFormat:= pf32bit;

 for j:=0 to parch.Height-1 do
  begin
   lf:=fond.ScanLine[j];
   lp:=parch.ScanLine[j];
   lt:=trans.ScanLine[j];
   for i:=0 to parch.Width-1 do
    lf[i]:=TransRGB(lf[i],lp[i],lt[i]);
  end;


 f:=fileopen(fichierouvert,fmOpenread);
 fileread(f,n[0],51+3*144);
 fileread(f,score,sizeof(score));
 fileclose(f);


 if fin=200 then
  begin
   for i:=0 to 19 do AfficheText(fond,80,40+i*16,score[i]);
   exit;
  end;

// '19:                      -- 99:99:99 -- 000'
 for i:=0 to 19 do
  begin
   sc[i].n:=copy(score[i],5,20);
   sc[i].h:=strtoint(copy(score[i],29,2));
   sc[i].m:=strtoint(copy(score[i],32,2));
   sc[i].s:=strtoint(copy(score[i],35,2));
   sc[i].p:=strtoint(copy(score[i],41,3));
  end;


  j:=20;
  for i:=19 downto 0 do
   begin
    if sc[i].p<fin then j:=i else
    if (sc[i].p=fin) and (sc[i].h>h) then j:=i else
    if (sc[i].p=fin) and (sc[i].h=h) and (sc[i].m>m) then j:=i else
    if (sc[i].p=fin) and (sc[i].h=h) and (sc[i].m=m) and (sc[i].s>s) then j:=i;
   end;

  if j<20 then form3.ShowModal;

  if j<20 then for i:=18 downto j do score[i+1]:=score[i];
  score[j]:=Completeg(inttostr(j+1),'0',2)+': '+Completed(form3.Edit1.text,' ',20)+' -- '+
            Completeg(inttostr(h),'0',2)+':'+Completeg(inttostr(m),'0',2)+':'+
            Completeg(inttostr(s),'0',2)+' -- '+Completeg(inttostr(fin),'0',3);

  for i:=0 to 19 do score[i]:=Completeg(inttostr(i+1),'0',2)+copy(score[i],3,43);

  f:=filecreate(fichierouvert);
  filewrite(f,n[0],51+3*144);
  filewrite(f,score,sizeof(score));
  fileclose(f);
  for i:=0 to 19 do AfficheText(fond,80,40+i*16,score[i]);
end;

procedure TForm2.FormHide(Sender: TObject);
begin
fond.Free;
end;

procedure TForm2.FormPaint(Sender: TObject);
begin
canvas.Draw(0,0,fond);
end;

procedure TForm2.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if (x>254) and (y>368) and (x<354) and (y<394) then close;
end;

end.
