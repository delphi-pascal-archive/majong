unit UMaj;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ImgList, Spin, Buttons, AppEvnts, Jpeg;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Quitter1: TMenuItem;
    Ouvrirunplateau1: TMenuItem;
    NouveauJeu1: TMenuItem;
    Chargerdenouvellespices1: TMenuItem;
    N1: TMenuItem;
    Oprtion1: TMenuItem;
    Annuler1: TMenuItem;
    Montrerunmouvementpossible1: TMenuItem;
    Pause1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Suividelasouris1: TMenuItem;
    jouerfinish: TMenuItem;
    Affichage1: TMenuItem;
    Modecourant1: TMenuItem;
    voirlesscores1: TMenuItem;
    voirtouteslespices1: TMenuItem;
    Piecestransparentes1: TMenuItem;
    procedure quitter1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure NouveauJeu1Click(Sender: TObject);
    procedure Pause1Click(Sender: TObject);
    procedure Annuler1Click(Sender: TObject);
    procedure Ouvrirunplateau1Click(Sender: TObject);
    procedure Montrerunmouvementpossible1Click(Sender: TObject);
    procedure Chargerdenouvellespices1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure jouerfinishClick(Sender: TObject);
    procedure voirlesscores1Click(Sender: TObject);
    procedure Modecourant1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure voirtouteslespices1Click(Sender: TObject);
    procedure Piecestransparentes1Click(Sender: TObject);
  private
    { D.clarations priv.es }
  public
    { D.clarations publiques }     
     procedure dessinfond;
     procedure dessinzone(n:integer);
     procedure ouvreplateau(Name:string);
     procedure AfficheAnimgagne;
     procedure AfficheAnimperdu;
     procedure AfficheText(bmp:byte;x,y:longint;t:string);
     procedure AffichePieceSelect(p,n:integer);

  end;


const
 MaxEtoile=2000;
 MaxEtoilealafois=1000;

type
 Tetoile=record x,y,vx,vy,vie:integer;end;
 tposPiece=record x,y,z:byte; end;
 TEtat=(Rien,selectpiece,selectpaire,ShowMove,scoreperdu,scoregagne,pause,showpiece);
 Tjeu=array[1..144]of byte;
 Tplateau=array[1..145] of tposPiece;


var
  modecourant           :TDevMode;
  Etoile                :array[0..MaxEtoile] of Tetoile;
  animVX,animVY,animI   :integer;
  animX,animY           :integer;
  anim                  :integer=0;
  Etat                  :Tetat=selectpiece;
  pieces                :array[0..83] of tbitmap;
  Form1                 : TForm1;
  autofinish            :boolean=true;
  piece                 :tbitmap;
  xp,yp                 :integer;
  xx,yy                 :integer;
  xd,yd                 :integer;
  xm,ym                 :integer;
  h,m,s                 :integer;
  dx,dy                 :integer;
  fond                  :tbitmap;
  texttrans             :tbitmap;
  dessindefond          :tbitmap;
  dessinpieceselect     :tbitmap;
  ModifRes              :boolean=false;
  posPiece,plateau      :tplateau;
  retour                :array[1..73] of record p:tplateau;j:tjeu; end;
  posretour             :integer=1;
  jeu                   :tjeu;
  nmove                 :integer;
  bloccourant           :integer;
  blocselect            :integer=0;
  efface                :boolean=false;
  Piecestrans           :boolean=true;
  margex,margey         :integer;
 


implementation

uses Uscore, Ures;

{$R *.dfm}

function moyenneRGB(a,b:longint):longint;
type
 TRGBA=array[0..3] of byte;
var
 res:TRGBA;
begin
 res[0]:=(TRGBA(a)[0]+TRGBA(b)[0]) div 2;
 res[1]:=(TRGBA(a)[1]+TRGBA(b)[1]) div 2;
 res[2]:=(TRGBA(a)[2]+TRGBA(b)[2]) div 2;
 res[3]:=(TRGBA(a)[3]+TRGBA(b)[3]) div 2;
 result:=longint(res);
end;


function maxbloc:integer;
var
 i:integer;
begin
 i:=145;
 while (i>0) and (pospiece[i].x=255) do dec(i);
 result:=i;
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


procedure AfficheScore;
begin
 form2.h:=h;
 form2.m:=m;
 form2.s:=s;
 form2.Caption:='jeu : '+form1.Caption;
 form2.fin:=144-maxbloc;
 form2.ShowModal;
end;

procedure melangejeu;
var
 i:integer;
 j,k,t:integer;
begin
 for i:=1 to 137 do jeu[i]:=(i-1) div 4;
 for i:=137 to 144 do jeu[i]:=(i-137)+34;
 for i:=0 to random(500)+1000 do
  begin
   j:=random(144)+1;
   k:=random(144)+1;
   t:=jeu[j];
   jeu[j]:=jeu[k];
   jeu[k]:=t;
  end;
end;


function estmemepiece(i,j:integer):boolean;
begin
result:=((jeu[i]=jeu[j])
     or ((jeu[i] in [38,39,40,41]) and (jeu[j] in [38,39,40,41]))
     or ((jeu[i] in [34,35,36,37]) and (jeu[j] in [34,35,36,37])))
end;


procedure Delbloc(n:integer);
var
 i:integer;
begin
 for i:=n to maxbloc do
  begin
   jeu[i]:=jeu[i+1];
   pospiece[i].x:=pospiece[i+1].x;
   pospiece[i].y:=pospiece[i+1].y;
   pospiece[i].z:=pospiece[i+1].z;
  end;
 pospiece[i-1].x:=255;
 pospiece[i-1].y:=0;
 pospiece[i-1].z:=0;
end;

procedure swappiece(i,j:integer);
var
 xt,yt,zt:integer;
begin
 xt:=pospiece[i].x;
 yt:=pospiece[i].y;
 zt:=pospiece[i].z;
 pospiece[i].x:=pospiece[j].x;
 pospiece[i].y:=pospiece[j].y;
 pospiece[i].z:=pospiece[j].z;
 pospiece[j].x:=xt;
 pospiece[j].y:=yt;
 pospiece[j].z:=zt;

 if i=bloccourant then bloccourant:=j
 else
 if j=bloccourant then bloccourant:=i;

 if i=blocselect then blocselect:=j
 else
 if j=blocselect then blocselect:=i;
end;

procedure loadbloc(n:string);
var
 tmp:tbitmap;
 s:Tstrings;
 t:string;
 err:integer;
 i:integer;
 minx,maxx,miny,maxy:integer;
begin
 s:=TStringList.Create;
 s.LoadFromFile(n);
 t:=s[0];
 s[0]:=copy(t,pos('=',t)+1,length(t));
 t:=s[1];
 s[1]:=copy(t,pos('=',t)+1,length(t));
 t:=s[2];
 s[2]:=copy(t,pos('=',t)+1,length(t));
 t:=s[3];
 s[3]:=copy(t,pos('=',t)+1,length(t));
 dx:=0;
 dy:=0;
 val(s[2],dx,err);
 val(s[3],dy,err);
 n:=s[1];
 tmp:=tbitmap.Create;
 tmp.LoadFromFile(n);
 xp:=tmp.Width div 84;
 yp:=tmp.Height;
 for i:=0 to 83 do
  begin
   pieces[i].Width:=xp;
   pieces[i].Height:=yp;
   pieces[i].Canvas.Draw(-i*xp,0,tmp);
   pieces[i].Transparent:=true;
   pieces[i].Transparentcolor:=clpurple;
   pieces[i].PixelFormat:=pf32bit;
  end;
 tmp.free;

 xd:=xp-abs(dx);
 yd:=yp-abs(dy);
 xx:=xd div 2;
 yy:=yd div 2;
 piece.Width:=xp;
 piece.Height:=yp;
 s.free;

 minx:=0;
 miny:=0;
 maxx:=0;
 maxy:=0;
 for i:=1 to maxbloc do
  begin
   if minx>integer(pospiece[i].x)*xx+integer(pospiece[i].z)*dx then  minx:=integer(pospiece[i].x)*xx+integer(pospiece[i].z)*dx;
   if miny>integer(pospiece[i].y)*yy+integer(pospiece[i].z)*dy then  miny:=integer(pospiece[i].y)*yy+integer(pospiece[i].z)*dy;
   if maxx<integer(pospiece[i].x)*xx+integer(pospiece[i].z)*dx then  maxx:=integer(pospiece[i].x)*xx+integer(pospiece[i].z)*dx;
   if maxy<integer(pospiece[i].y)*yy+integer(pospiece[i].z)*dy then  maxy:=integer(pospiece[i].y)*yy+integer(pospiece[i].z)*dy;
  end;
 margex:=(fond.Width-(maxx-minx)-xp) div 2;
 margey:=(fond.Height-(maxy-miny)-yp) div 2;
end;

function nonbloque(n:integer):boolean;
var
 i:integer;
 ag,ad,ah:boolean;
begin
 ag:=false;
 ad:=false;
 ah:=false;
 for i:=1 to maxbloc do
  begin
    if (pospiece[n].z=pospiece[i].z) then
     begin
      if (pospiece[n].x-pospiece[i].x=-2) and (abs(pospiece[n].y-pospiece[i].y)<=1) then ad:=true
      else
      if (pospiece[n].x-pospiece[i].x=2) and (abs(pospiece[n].y-pospiece[i].y)<=1) then ag:=true
     end
    else
     if (pospiece[n].z+1=pospiece[i].z) and (abs(pospiece[n].x-pospiece[i].x)<=1)
                                        and (abs(pospiece[n].y-pospiece[i].y)<=1) then ah:=true;
  end;
 result:=not ah and not (ad and ag);
end;

function cherchebloc(x,y:integer):integer;
var
 i:integer;
begin
 result:=0;
 for i:=1 to maxbloc do
  if (pospiece[i].x*xx+dx*posPiece[i].z<=x) and (pospiece[i].x*xx+dx*posPiece[i].z+xp>=x) and
     (pospiece[i].y*yy+dy*posPiece[i].z<=y) and (pospiece[i].y*yy+dy*posPiece[i].z+yp>=y) then result:=i;
end;

procedure reorganisepiece;
var
 i,j:integer;
 c:integer;
 position:integer;
begin
 c:=2;                              // x y
 if (dx< 0) and (dy< 0) then c:=1;  // N N
 if (dx>=0) and (dy< 0) then c:=2;  // P N
 if (dx< 0) and (dy>=0) then c:=3;  // N P
 if (dx>=0) and (dy>=0) then c:=4;  // P P
 for i:=1 to maxbloc-1 do
  for j:=i+1 to maxbloc do
   begin
    position:=0;
    if (pospiece[i].z>pospiece[j].z) then position:=202;
    if (pospiece[i].z<pospiece[j].z) then position:=201;

    if (position=0) and (pospiece[i].x>=pospiece[j].x+3) and (pospiece[i].y>=pospiece[j].y+3) then position:=010;
    if (position=0) and (pospiece[i].x<=pospiece[j].x-3) and (pospiece[i].y>=pospiece[j].y+3) then position:=030;
    if (position=0) and (pospiece[i].x>=pospiece[j].x+3) and (pospiece[i].y<=pospiece[j].y-3) then position:=060;
    if (position=0) and (pospiece[i].x<=pospiece[j].x-3) and (pospiece[i].y<=pospiece[j].y-3) then position:=080;

    if (position=0) and (pospiece[i].y>=pospiece[j].y+3) then position:=020+(pospiece[j].x-pospiece[i].x+2);
    if (position=0) and (pospiece[i].x>=pospiece[j].x+3) then position:=040+(pospiece[j].y-pospiece[i].y+2);
    if (position=0) and (pospiece[i].x<=pospiece[j].x-3) then position:=050+(pospiece[j].y-pospiece[i].y+2);
    if (position=0) and (pospiece[i].y<=pospiece[j].y-3) then position:=070+(pospiece[j].x-pospiece[i].x+2);

    if (position=0) and (pospiece[i].x=pospiece[j].x+2) and (pospiece[i].y=pospiece[j].y+2) then position:=110;
    if (position=0) and (pospiece[i].x=pospiece[j].x+1) and (pospiece[i].y=pospiece[j].y+2) then position:=111;
    if (position=0) and (pospiece[i].x=pospiece[j].x+0) and (pospiece[i].y=pospiece[j].y+2) then position:=112;
    if (position=0) and (pospiece[i].x=pospiece[j].x-1) and (pospiece[i].y=pospiece[j].y+2) then position:=113;
    if (position=0) and (pospiece[i].x=pospiece[j].x-2) and (pospiece[i].y=pospiece[j].y+2) then position:=114;

    if (position=0) and (pospiece[i].x=pospiece[j].x+2) and (pospiece[i].y=pospiece[j].y+1) then position:=115;
    if (position=0) and (pospiece[i].x=pospiece[j].x-2) and (pospiece[i].y=pospiece[j].y+1) then position:=116;

    if (position=0) and (pospiece[i].x=pospiece[j].x+2) and (pospiece[i].y=pospiece[j].y+0) then position:=117;
    if (position=0) and (pospiece[i].x=pospiece[j].x-2) and (pospiece[i].y=pospiece[j].y+0) then position:=118;

    if (position=0) and (pospiece[i].x=pospiece[j].x+2) and (pospiece[i].y=pospiece[j].y-1) then position:=119;
    if (position=0) and (pospiece[i].x=pospiece[j].x-2) and (pospiece[i].y=pospiece[j].y-1) then position:=120;

    if (position=0) and (pospiece[i].x=pospiece[j].x+2) and (pospiece[i].y=pospiece[j].y-2) then position:=121;
    if (position=0) and (pospiece[i].x=pospiece[j].x+1) and (pospiece[i].y=pospiece[j].y-2) then position:=122;
    if (position=0) and (pospiece[i].x=pospiece[j].x+0) and (pospiece[i].y=pospiece[j].y-2) then position:=123;
    if (position=0) and (pospiece[i].x=pospiece[j].x-1) and (pospiece[i].y=pospiece[j].y-2) then position:=124;
    if (position=0) and (pospiece[i].x=pospiece[j].x-2) and (pospiece[i].y=pospiece[j].y-2) then position:=125;

    //c=1 haut gauche
    //c=2 haut droite
    //c=3 bas gauche
    //c=4 bas droite
    case c of
     1: if (position in [202,010,020,021,022,023,024,030,040,041,042,043,044,050,110,111,112,113,114,115,117,119,121]) then swappiece(i,j);
     2: if (position in [202,010,020,021,022,023,024,030,040,050,051,052,053,110,111,112,113,114,116,118,120]) then swappiece(i,j);
     3: if (position in [202,041,042,043,044,054,060,070,071,072,073,074,115,117,119,121,122,123,124,125]) then swappiece(i,j);
     4: if (position in [202,051,052,053,054,060,070,071,072,073,074,080,116,118,120,122,123,124,125]) then swappiece(i,j);
    end;
  end;
end;


procedure TForm1.dessinzone(n:integer);
type
 longintArray=array[0..0] of longint;
 plongintArray=^longintArray;
var
 i,j,k:integer;
 minx,maxx,miny,maxy:integer;
 l1,l2:PlongintArray;
 x1,x2,y1,y2,w,h:integer;
begin
 // si n=0, rien à faire
 if n=0 then exit;

 // zone à redessiner
 minx:=pospiece[n].x*xx+pospiece[n].z*dx;
 miny:=pospiece[n].y*yy+pospiece[n].z*dy;
 maxx:=minx+xp;
 maxy:=miny+yp;
 // on récup le background
 piece.canvas.Draw(-minx-margex,-miny-margey,dessindefond);
 piece.PixelFormat:=pf32bit;
 // on parcour tous les blocs
 for i:=1 to maxbloc do
  // si on efface, il ne faut pas dessiner bloccourant et blocselect
  if (not efface) or ((i<>bloccourant) and (i<>blocselect)) then
  // si la piece i n'est pas dans la zone, on continue sans rien faire
  if (pospiece[i].x*xx+pospiece[i].z*dx+xp>=minx) and
     (pospiece[i].x*xx+pospiece[i].z*dx<=maxx) and
     (pospiece[i].y*yy+pospiece[i].z*dy+yp>=miny) and
     (pospiece[i].y*yy+pospiece[i].z*dy<=maxy) then
  begin
   // si c'est un bloc quelconque, on l'affiche en opaque
   if (i<>bloccourant) and (i<>blocselect) then
   piece.Canvas.Draw(pospiece[i].x*xx+pospiece[i].z*dx-minx,
                     pospiece[i].y*yy+pospiece[i].z*dy-miny,
                     pieces[jeu[i]])
   else
   // il faut l'afficher en transparence
    if not Piecestrans then  piece.Canvas.Draw(pospiece[i].x*xx+pospiece[i].z*dx-minx,
                             pospiece[i].y*yy+pospiece[i].z*dy-miny, pieces[jeu[i]+42])
    else
    begin

     x1:=pospiece[i].x*xx+pospiece[i].z*dx-minx;
     y1:=pospiece[i].y*yy+pospiece[i].z*dy-miny;
     x2:=0;
     y2:=0;
     w:=xp;
     h:=yp;
     if x1>0 then begin w:=w-x1; x2:=x1; x1:=0; end;
     if y1>0 then begin h:=h-y1; y2:=y1; y1:=0; end;
     if x1<0 then begin w:=w+x1; x2:=0; x1:=-x1; end;
     if y1<0 then begin h:=h+y1; y2:=0; y1:=-y1; end;
     for k:=y2 to y2+h-1 do
     begin
      l1:=piece.ScanLine[k];
      l2:=pieces[jeu[i]+42].ScanLine[y1+k-y2];
      for j:=x2 to x2+w-1 do if l2[x1+j-x2]<>clpurple then l1[j]:=moyenneRGB(l1[j],l2[x1+j-x2]);
     end;
    end; // end else
  end;

 fond.Canvas.Draw(minx+margex,miny+margey,piece);
 canvas.Draw(minx+margex,miny+margey,piece);
end;


function mouvementpossible:integer;
var
 i,j,n:integer;
begin
 n:=0;
 
 for j:=1 to maxbloc-1 do
  for i:=j+1 to maxbloc do
   if nonbloque(j) and nonbloque(i) and estmemepiece(i,j) then inc(n);

result:=n;
end;


function finjeu:integer;
begin
 if maxbloc=0 then
  begin
   etat:=scoregagne;
   form1.Timer1.Interval:=100;
   anim:=0;
   messagebox(form1.Handle,'Bravo...','Bravo',0);
   AfficheScore;
   result:=0;
   exit;
  end;
 result:=mouvementpossible;
 if result=0 then
  begin
   etat:=scoreperdu;
   form1.Timer1.Interval:=100;
   anim:=0;
   messagebox(form1.Handle,'Plus de mouvement possible...','Perdu',0);
   AfficheScore;
   exit;
  end;
 etat:=Selectpiece;
end;

// affiche un text sans fond
procedure TForm1.AfficheText(bmp:byte;x,y:longint;t:string);
begin
 texttrans.canvas.Font.Size:=10;

 texttrans.Width:=texttrans.Canvas.TextWidth(t)+1;
 texttrans.height:=texttrans.Canvas.Textheight(t)+1;
 texttrans.Transparent:=false;
 texttrans.Canvas.Draw(-x,-y,dessindefond);
 if bmp<>0 then fond.Canvas.draw(x,y,texttrans)
           else canvas.Draw(x,y,texttrans);

 texttrans.Transparent:=true;
 texttrans.TransparentColor:=$0000FFFF;
 texttrans.Canvas.Brush.Color:=$0000FFFF;

 texttrans.canvas.Font.color:=clblack;

 texttrans.canvas.TextOut(0,0,t);
 if bmp<>0 then fond.Canvas.draw(x,y,texttrans)
           else canvas.Draw(x,y,texttrans);
 texttrans.canvas.Font.color:=clwhite;
 texttrans.Width:=texttrans.Canvas.TextWidth(t);
 texttrans.height:=texttrans.Canvas.Textheight(t);
 texttrans.canvas.TextOut(0,0,t);
 if bmp<>0 then fond.Canvas.draw(x+1,y+1,texttrans)
           else canvas.Draw(x+1,y+1,texttrans);
end;

procedure Tform1.AffichePieceSelect(p,n:integer);
begin
  dessinpieceselect.Width:=xp;
  dessinpieceselect.Height:=yp;
  if (p=1) then dessinpieceselect.Canvas.Draw(0,0,dessindefond)   // on récup le fond
           else dessinpieceselect.Canvas.Draw(-xp,0,dessindefond);

  if n>0   then dessinpieceselect.Canvas.Draw(0,0,pieces[n]);

  if (p=1) then fond.canvas.Draw(0,0,dessinpieceselect)           // on colle la piece sur le fond
           else fond.canvas.Draw(xp,0,dessinpieceselect);

  if (p=1) then canvas.Draw(0,0,dessinpieceselect)                // on colle la piece direct sur le canvas
           else canvas.Draw(xp,0,dessinpieceselect);
end;

procedure TForm1.dessinfond;
var
 i:integer;
begin
 fond.canvas.draw(0,0,dessindefond);
 for i:=1 to maxbloc do
  begin
   fond.Canvas.Draw(margex+integer(posPiece[i].x)*xx+dx*integer(posPiece[i].z),
                    margey+integer(posPiece[i].y)*yy+dy*integer(posPiece[i].z),
                    pieces[jeu[i]+42*byte((i=bloccourant) or (i=blocselect))]);
  end;
 AfficheText(1,20,clientheight-20,'Echap : Nouveau jeu     Retour Arrière : Annuler     Espace : pause    Entrée : Voir les pièces');
 AfficheText(1,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
 AfficheText(1,xp*3,0,'jeu : '+form1.Caption);
end;

procedure  TForm1.ouvreplateau(Name:string);
var
 f:integer;
 s:string[50];
 minx,miny,maxx,maxy:integer;
begin
   f:=fileopen(Name,fmOpenread);
   fileread(f,s,51);
   fileread(f,pospiece[1].x,3*144);
   fileclose(f);
   fichierouvert:=name;
   caption:=s;
   pospiece[145].x:=255;
   bloccourant:=0;
   reorganisepiece;
   plateau:=pospiece;
   minx:=0;
   miny:=0;
   maxx:=0;
   maxy:=0;
   for f:=1 to 144 do
    begin
     if minx>integer(pospiece[f].x)*xx+integer(pospiece[f].z)*dx then  minx:=integer(pospiece[f].x)*xx+integer(pospiece[f].z)*dx;
     if miny>integer(pospiece[f].y)*yy+integer(pospiece[f].z)*dy then  miny:=integer(pospiece[f].y)*yy+integer(pospiece[f].z)*dy;
     if maxx<integer(pospiece[f].x)*xx+integer(pospiece[f].z)*dx then  maxx:=integer(pospiece[f].x)*xx+integer(pospiece[f].z)*dx;
     if maxy<integer(pospiece[f].y)*yy+integer(pospiece[f].z)*dy then  maxy:=integer(pospiece[f].y)*yy+integer(pospiece[f].z)*dy;
    end;
  margex:=(Width-2*xp-(maxx-minx)) div 2;
  margey:=(Height-(maxy-miny)) div 2;
end;

procedure Annuletour;
begin
 if posretour>1 then
  begin
   dec(posretour);
   pospiece:=retour[posretour].p;
   jeu:=retour[posretour].j;
   bloccourant:=0;
   blocselect:=0;
   etat:=selectpiece;
   form1.dessinfond;
   form1.canvas.Draw(0,0,fond);
 end;
end;

procedure NouveauJeu;
begin
 bloccourant:=0;
 blocselect:=0;
 etat:=Selectpiece;
 pospiece:=plateau;
 melangejeu;
 form1.dessinfond;
 form1.canvas.Draw(0,0,fond);
 form1.Timer1.Interval:=1000;
 posretour:=1;
 retour[posretour].p:=pospiece;
 retour[posretour].j:=jeu;
 h:=0;
 m:=0;
 s:=0;
end;

procedure effacedeuxbloc;
var
 i,j:integer;
begin
 for j:=1 to maxbloc-1 do
     for i:=j+1 to maxbloc do
      if nonbloque(j) and nonbloque(i) and estmemepiece(i,j) then
       begin
        etat:=selectpiece;
        efface:=true;
        bloccourant:=i;
        blocselect:=j;
        form1.dessinzone(bloccourant);
        form1.dessinzone(blocselect);
        efface:=false;
        if blocselect>bloccourant then  dec(blocselect);
        delbloc(bloccourant);
        delbloc(blocselect);
        bloccourant:=0;
        blocselect:=0;
        if posretour>70 then
         blocselect:=0;
        inc(posretour);
        retour[posretour].p:=pospiece;
        // ici
        retour[posretour].j:=jeu;
        exit;
    end;
end;



procedure TForm1.quitter1Click(Sender: TObject);
begin
 close;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
 i:integer;
 tmp:tbitmap;
begin
 fillchar(Etoile,sizeof(etoile),0);
 canvas.brush.color:=clskyblue;
 randomize;
 for i:=0 to 83 do pieces[i]:=tbitmap.Create;
 piece:=tbitmap.Create;
 fond:=tbitmap.Create;
 dessinpieceselect:=tbitmap.Create;
 dessindefond:=tbitmap.Create;

 tmp:=tbitmap.Create;
 tmp.LoadFromFile('fond.bmp');
 dessindefond.Width:=form1.ClientWidth;
 dessindefond.Height:=form1.ClientHeight;
 dessindefond.Canvas.StretchDraw(dessindefond.Canvas.ClipRect,tmp);


 fond.Width:=ClientWidth;
 fond.Height:=ClientHeight;
 texttrans:=tbitmap.Create;

 fond.Canvas.Font.Assign(form1.font);

 loadbloc(extractfilepath(application.ExeName)+'default.blc');
 ouvreplateau(extractfilepath(application.ExeName)+'default.plt');
 melangejeu;
 posretour:=1;
 retour[posretour].p:=pospiece;
 retour[posretour].j:=jeu;
 h:=0;
 m:=0;
 s:=0;
 dessinfond;
end;

procedure TForm1.FormMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
var
 n:integer;
begin
 if not  Suividelasouris1.Checked then exit;
 xm:=x-margex;
 ym:=y-margey;
 case etat of
  selectpiece,selectpaire:
   begin
    n:=bloccourant;
    bloccourant:=cherchebloc(xm,ym);
    if bloccourant<>n then
     begin
      // on affiche opaque la piece transparente
      bloccourant:=0;
      dessinZone(n);
      // on dessine la piece transparente
      bloccourant:=cherchebloc(xm,ym);
      dessinZone(bloccourant);
      // on met à jour les pièces d'en haut à gauche
      if (bloccourant<>blocselect) and (bloccourant<>0) then
       case etat of
        selectpiece:affichepieceselect(1,jeu[bloccourant]);
        selectpaire:affichepieceselect(2,jeu[bloccourant]);
       end;
     end;
   end;
 end;
end;

procedure TForm1.FormResize(Sender: TObject);
var
 minx,miny,maxx,maxy:integer;
 f:integer;
 tmp:tbitmap;
begin
 fond.Width:=clientWidth;
 fond.Height:=clientHeight;
 tmp:=tbitmap.Create;
 tmp.LoadFromFile('fond.bmp');
 dessindefond.Width:=ClientWidth;
 dessindefond.Height:=ClientHeight;
 dessindefond.Canvas.StretchDraw(dessindefond.Canvas.ClipRect,tmp);

 minx:=0;
 miny:=0;
 maxx:=0;
 maxy:=0;
 for f:=1 to maxbloc do
  begin
   if minx>pospiece[f].x*xx+pospiece[f].z*dx then  minx:=pospiece[f].x*xx+pospiece[f].z*dx;
   if miny>pospiece[f].y*yy+pospiece[f].z*dy then  miny:=pospiece[f].y*yy+pospiece[f].z*dy;
   if maxx<pospiece[f].x*xx+pospiece[f].z*dx+xp then  maxx:=pospiece[f].x*xx+pospiece[f].z*dx+xp;
   if maxy<pospiece[f].y*yy+pospiece[f].z*dy+yp then  maxy:=pospiece[f].y*yy+pospiece[f].z*dy+yp;
  end;
 margex:=(fond.Width-(maxx-minx)) div 2;
 margey:=(fond.Height-(maxy-miny)) div 2;
 dessinfond;
end;

procedure TForm1.FormClick(Sender: TObject);
var
 t1,t2:integer;
 pt:tpoint;
 i,j,k:integer;
begin
 pt:=form1.ScreenToClient(mouse.CursorPos);
 xm:=pt.x-margex;
 ym:=pt.y-margey;
 case etat of
  showpiece:
   begin
    form1.dessinfond;
    form1.canvas.Draw(0,0,fond);
    etat:=selectpiece;
   end;
  Scoregagne,scoreperdu:nouveaujeu;
  showmove:
   begin
    k:=0;
    for j:=1 to maxbloc-1 do
     for i:=j+1 to maxbloc do
      if nonbloque(j) and nonbloque(i) and estmemepiece(i,j) then
       begin
        if k=0 then
         begin
          t1:=i;
          t2:=j;
         end;
        if k=nmove then
         begin
          t1:=i;
          t2:=j;
         end;
       inc(k);
      end;

    if k<nmove then nmove:=0;
    bloccourant:=t1;
    blocselect:=t2;
    inc(nmove);
    dessinfond;
    canvas.Draw(0,0,fond);
   end;

  selectpiece:
  begin
    bloccourant:=cherchebloc(xm,ym);
    if (bloccourant>0) and (nonbloque(bloccourant)) then
    begin
     etat:=selectpaire;
     blocselect:=bloccourant;
     if not Suividelasouris1.Checked then dessinzone(bloccourant);
    end;
   end;

  selectpaire:
   begin
    bloccourant:=cherchebloc(xm,ym);
    if (bloccourant>0) and (nonbloque(bloccourant)) and estmemepiece(bloccourant,blocselect) and
     (bloccourant<>blocselect) then
    begin
     etat:=selectpiece;
     efface:=true;
     dessinzone(bloccourant);
     dessinzone(blocselect);
     efface:=false;
     if blocselect>bloccourant then  dec(blocselect);
     delbloc(bloccourant);
     delbloc(blocselect);
     bloccourant:=0;
     blocselect:=0;
     affichepieceselect(2,0);
     inc(posretour);
     retour[posretour].p:=pospiece;
     retour[posretour].j:=jeu;
     if autofinish then while mouvementpossible=1 do effacedeuxbloc;
     i:=finjeu;
     AfficheText(1,20,clientheight-20,'Echap : Nouveau jeu     Retour Arrière : Annuler     Espace : pause    Entrée : Voir les pièces');
     AfficheText(0,20,clientheight-20,'Echap : Nouveau jeu     Retour Arrière : Annuler     Espace : pause    Entrée : Voir les pièces');
     AfficheText(1,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
     AfficheText(0,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
     AfficheText(1,xp*3,0,'jeu : '+form1.Caption);
     AfficheText(0,xp*3,0,'jeu : '+form1.Caption);
    end
    else
    begin
      t1:=bloccourant;
      t2:=blocselect;
      bloccourant:=0;
      blocselect:=0;
      dessinzone(t1);
      dessinzone(t2);
      etat:=selectpiece;
     end
   end;
 end; // End CASE
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 i,j,ti,tj:integer;
 p:tplateau;
 je:tjeu;
 n:integer;
begin
 case key of
  112: //F1
   begin
    etat:=scoregagne;
    anim:=0;
    form1.Timer1.Interval:=100;
   end;
  115: //F4
   begin
    etat:=scoreperdu;
    anim:=0;
    form1.Timer1.Interval:=100;
   end;
  113: //F2
  begin
   effacedeuxbloc;

   if autofinish then while mouvementpossible=1 do effacedeuxbloc;
   n:=finjeu;
   AfficheText(1,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
   AfficheText(0,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
   AfficheText(1,xp*3,0,'jeu : '+form1.Caption);
   AfficheText(0,xp*3,0,'jeu : '+form1.Caption);
   affichepieceselect(1,0);
   affichepieceselect(2,0);
  end;
  114: //F3
   begin
    n:=0; ti:=0;tj:=0;
    for j:=1 to maxbloc-1 do
     for i:=j+1 to maxbloc do
      if nonbloque(j) and nonbloque(i) and estmemepiece(i,j) then
       begin
        bloccourant:=i;
        blocselect:=j;
        p:=pospiece;
        je:=jeu;
        if blocselect>bloccourant then  dec(blocselect);
        delbloc(bloccourant);
        delbloc(blocselect);
        if n<=mouvementpossible then begin n:=mouvementpossible;ti:=i;tj:=j; end;
        pospiece:=p;
        jeu:=je;
        bloccourant:=0;
        blocselect:=0;
       end;

    if ti<>0 then
     begin
      etat:=selectpiece;
      efface:=true;
      bloccourant:=ti;
      blocselect:=tj;
      dessinzone(bloccourant);
      dessinzone(blocselect);
      AffichePieceSelect(0,1);
      AffichePieceSelect(0,2);
      efface:=false;
      if blocselect>bloccourant then  dec(blocselect);
      delbloc(bloccourant);
      delbloc(blocselect);
      bloccourant:=0;
      blocselect:=0;
      inc(posretour);
      retour[posretour].p:=pospiece;
      retour[posretour].j:=jeu;
      if autofinish then while mouvementpossible=1 do effacedeuxbloc;
      n:=finjeu;
      if etat in [scoregagne,scoreperdu] then exit;
      AfficheText(1,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
      AfficheText(0,xp*3,25,'Mouvement possible : '+completeg(inttostr(mouvementpossible),'0',2)+'   Nombres de pieces : '+completeg(inttostr(maxbloc),'0',3));
      AfficheText(1,xp*3,0,'jeu : '+form1.Caption);
      AfficheText(0,xp*3,0,'jeu : '+form1.Caption);
      affichepieceselect(1,0);
      affichepieceselect(2,0);
      exit;
     end;
   end;
  65 : Montrerunmouvementpossible1Click(sender)// A
  ;
  80,32 : // P espace
   case etat of
    pause: etat:=selectpiece;
    showpiece:;//rien
   else
    etat:=pause;
   end;
  8:  // retour
   annuletour;
  27: // ESC
   nouveaujeu;
  13: //entree
   voirtouteslespices1Click(self);
 end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 i,j:integer;
 t:string;
begin
 case etat of
 rien:;                              // rien
 pause:;                             // rien
 showpiece:;                         //rien
 showmove:;                          // rien
 scoregagne:                         // jolie truc
  begin
   AfficheAnimgagne;
  end;
 scoreperdu:                         // jolie truc aussi
  begin
   AfficheAnimperdu;
  end;
 else                                // sinon affiche le temps écoulé
  begin
   t:=Completeg(inttostr(h),'0',2)+':'+Completeg(inttostr(m),'0',2)+':'+Completeg(inttostr(s),'0',2);
   affichetext(0,20,ClientHeight-40,t);
   s:=s+1;
   if s=60 then begin s:=0; m:=m+1;end;
   if m=60 then begin m:=0; h:=h+1;end;
  end;
 end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
canvas.Draw(0,0,fond);
end;

procedure TForm1.NouveauJeu1Click(Sender: TObject);
begin
 nouveaujeu;
end;

procedure TForm1.Pause1Click(Sender: TObject);
begin
 if etat=pause then etat:=selectpiece else etat:=pause;
end;

procedure TForm1.Annuler1Click(Sender: TObject);
begin
 annuletour;
end;

procedure TForm1.Ouvrirunplateau1Click(Sender: TObject);
begin
 opendialog1.DefaultExt:='PLT';
 opendialog1.filter:='Fichier Plateau (*.plt)|*.plt|Tout (*.*)|*.*';
 opendialog1.Title:='Charger un plateau';
 if opendialog1.Execute then
  begin
   ouvreplateau(opendialog1.FileName);
   NouveauJeu;
  end;
end;

procedure TForm1.Montrerunmouvementpossible1Click(Sender: TObject);
var
 i,j:integer;
begin
 if not (etat in [selectpiece,selectpaire,showmove]) then exit;
 if etat=showmove then
  begin
    etat:=selectpiece;
    bloccourant:=0;
    blocselect:=0;
    dessinfond;
    canvas.Draw(0,0,fond);
    Montrerunmouvementpossible1.Caption:='Montrer un mouvement possible';
    exit;
  end;
 etat:=showmove;
 Montrerunmouvementpossible1.Caption:='Retour au jeu';
 for j:=1 to maxbloc-1 do
  for i:=j+1 to maxbloc do
   if nonbloque(j) and nonbloque(i) and estmemepiece(i,j) then
   begin
    bloccourant:=i;
    blocselect:=j;
    dessinfond;
    canvas.Draw(0,0,fond);
    nmove:=1;
    exit;
   end;
end;

procedure TForm1.Chargerdenouvellespices1Click(Sender: TObject);
var
 i:integer;
 p:tplateau;
begin
  opendialog1.DefaultExt:='blc';
  opendialog1.filter:='Fichier blocs (*.blc)|*.blc|Tout (*.*)|*.*';
  opendialog1.Title:='Charger des blocs';
  if opendialog1.Execute then
  begin
   p:=pospiece;
   pospiece:=plateau;
   loadbloc(opendialog1.FileName);
   // réorganise le jeu complet
   reorganisepiece;
   plateau:=pospiece;
   pospiece:=p;
   // réorganise le jeu en cours
   reorganisepiece;
   case etat of
   selectpiece,selectpaire,ShowMove,pause:
    begin
     dessinfond;
     canvas.Draw(0,0,fond);
    end;
    showpiece:voirtouteslespices1Click(self);
   end;


   //nouveaujeu;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
 i:integer;
begin
 form1.OnResize:=nil;
 form1.OnPaint:=nil;
 if ModifRes then ChangeDisplaySettings(modecourant, CDS_UPDATEREGISTRY);
 for i:=0 to 83 do pieces[i].Free;
 piece.free;
 fond.free;
end;

procedure TForm1.jouerfinishClick(Sender: TObject);
begin
autofinish:=jouerfinish.Checked;
end;

procedure TForm1.voirlesscores1Click(Sender: TObject);
begin
 form2.fin:=200;
 form2.Caption:='jeu : '+form1.Caption;
 if not (etat in [selectpiece,selectpaire,showmove]) then etat:=pause;
 form2.ShowModal;
 if etat=pause then etat:=selectpiece;
end;

procedure TForm1.Modecourant1Click(Sender: TObject);
begin
fres.showmodal;
end;

procedure TForm1.FormShow(Sender: TObject);
var
 hdc: THandle;
 i:integer;
 m:TDevMode;
 x,y,c:integer;
begin
 hdc := Form1.Canvas.Handle;
 x:=GetDeviceCaps(hdc, HORZRES);
 y:=GetDeviceCaps(hdc, VERTRES);
 c:=GetDeviceCaps(hdc, BITSPIXEL);
 i:=0;
 while EnumDisplaySettings(nil, i, m) do
  begin
   if (m.dmPelsWidth=x) and (m.dmPelsHeight=y) and (m.dmBitsPerPel=c) then modecourant:=m;
   inc(i);
  end;
 modecourant.dmDisplayFrequency:=0;

end;

procedure TForm1.voirtouteslespices1Click(Sender: TObject);
var
 i,j,k:integer;
 tab:array[0..41] of byte;              //0..33 - 34..37 - 38..41
begin
 etat:=showpiece;
 fond.Canvas.draw(0,0,dessindefond);
 fillchar(tab,42,1);
 fillchar(tab,34,4);
 for i:=1 to maxbloc do dec(tab[jeu[i]]);

 for i:=0 to 33 do
  begin
  for j:=1 to tab[i] do
   fond.Canvas.Draw((i div 9*8+j)*(xp div 2)+5,(i mod 9)*(yp+5)+5,pieces[i+42]);
  for j:=tab[i]+1 to 4 do
   fond.Canvas.Draw((i div 9*8+j)*(xp div 2)+5,(i mod 9)*(yp+5)+5,pieces[i]);
  end;

 for i:=34 to 41 do
  if tab[i]=1 then
   fond.Canvas.Draw((i-34)*xp+(i-34) div 4*20+5,10*(yp+6),pieces[i+42])
  else
   fond.Canvas.Draw((i-34)*xp+(i-34) div 4*20+5,10*(yp+6),pieces[i]);

 AfficheText(1,9*xp+45,10*(yp+6)+yp div 3,'cliquer pour revenir au jeu');

 form1.canvas.Draw(0,0,fond);
end;

procedure tform1.AfficheAnimgagne;
var
 i,j:integer;
 y:integer;
begin
 fond.Canvas.Draw(0,0,dessindefond);

 if anim=0 then   // debut
  begin
   animvx:=random(20)-10;
   animvy:=round(sqrt(fond.Height))+random(10);
   animx:=(fond.Width-xp) div 2-fond.Width div 4+random(fond.Width div 2);
   animy:=fond.Height-yp;
   animI:=random(84);
  end;


 if anim <fond.Height div 2 then   // monte
  begin
   fond.Canvas.Draw(animx+(anim*AnimVX div 5),animy,pieces[animI]);
   animy:=animy-AnimVy;
   animvy:=animvy-1;

   if animvy<=0 then
    begin
     j:=0;
     for i:=0 to MaxEtoile do
      if etoile[i].vie=0 then
      begin
       etoile[i].x:=animx+(anim*AnimVX div 5)+random(xp);
       etoile[i].y:=animy+random(yp);
       etoile[i].vx:=random(20)-10;
       etoile[i].vy:=random(20)-10;
       etoile[i].vie:=random(64)+64;
       inc(j);
       if j=MaxEtoilealafois then break;
      end;
     anim:=-1;
    end;
  end;


  for i:=0 to MaxEtoile do
   if etoile[i].vie>0 then
    begin
     fond.Canvas.Pixels[etoile[i].x,etoile[i].y-1]:=rgb(128,etoile[i].vie,0);
     fond.Canvas.Pixels[etoile[i].x,etoile[i].y+1]:=rgb(128,etoile[i].vie,0);
     fond.Canvas.Pixels[etoile[i].x-1,etoile[i].y]:=rgb(128,etoile[i].vie,0);
     fond.Canvas.Pixels[etoile[i].x+1,etoile[i].y]:=rgb(128,etoile[i].vie,0);
     fond.Canvas.Pixels[etoile[i].x,etoile[i].y]:=rgb(255,255,etoile[i].vie);
     etoile[i].x:=etoile[i].x+etoile[i].vx;
     etoile[i].y:=etoile[i].y+etoile[i].vy;
     inc(etoile[i].vy);
     dec(etoile[i].vie);
     if etoile[i].y>fond.Height then etoile[i].vie:=0;
     if etoile[i].x>fond.Width then etoile[i].vie:=0;
     if etoile[i].x<0 then etoile[i].vie:=0;
    end;

 form1.Canvas.Draw(0,0,fond);
 inc(anim);
end;

procedure tform1.AfficheAnimPerdu;
var
 i,j:integer;
 y:integer;
begin
 fond.Canvas.Draw(0,0,dessindefond);

 if anim=0 then   // debut
  begin
   animvx:=random(20)-10;
   animvy:=random(10);
   animx:=(fond.Width-xp) div 2-fond.Width div 4+random(fond.Width div 2);
   animy:=fond.height div 2-random(20);
  end;


 if anim <fond.Height div 2 then   // tombe
  begin
   fond.Canvas.Draw(animx+(anim*AnimVX div 5),animy,pieces[animI]);
   animy:=animy+AnimVy;
   animvy:=animvy+1;

   if animy+AnimVy+yp>=fond.Height then
    begin
     j:=0;
     for i:=0 to MaxEtoile do
      if etoile[i].vie=0 then
      begin
       etoile[i].x:=animx+(anim*AnimVX div 5)+random(xp);
       etoile[i].y:=animy+random(yp);
       etoile[i].vx:=random(20)-10;
       etoile[i].vy:=-random(20);
       etoile[i].vie:=random(64)+64;
       inc(j);
       if j=MaxEtoilealafois then break;
      end;
     anim:=-1;
    end;
  end;

  for i:=0 to MaxEtoile do
   if etoile[i].vie>0 then
    begin
     fond.Canvas.Pixels[etoile[i].x,etoile[i].y-1]:=rgb(0,0,etoile[i].vie);
     fond.Canvas.Pixels[etoile[i].x,etoile[i].y+1]:=rgb(0,0,etoile[i].vie);
     fond.Canvas.Pixels[etoile[i].x-1,etoile[i].y]:=rgb(0,0,etoile[i].vie);
     fond.Canvas.Pixels[etoile[i].x+1,etoile[i].y]:=rgb(0,0,etoile[i].vie);
     fond.Canvas.Pixels[etoile[i].x,etoile[i].y]:=rgb(etoile[i].vie,etoile[i].vie,255);
     etoile[i].x:=etoile[i].x+etoile[i].vx;
     etoile[i].y:=etoile[i].y+etoile[i].vy;
     inc(etoile[i].vy);
     dec(etoile[i].vie);
     if etoile[i].y>fond.Height then etoile[i].vie:=0;
     if etoile[i].x>fond.Width then etoile[i].vie:=0;
     if etoile[i].x<0 then etoile[i].vie:=0;
    end;

 form1.Canvas.Draw(0,0,fond);
 inc(anim);
end;



procedure TForm1.Piecestransparentes1Click(Sender: TObject);
begin
Piecestrans:=Piecestransparentes1.Checked;
end;

end.
