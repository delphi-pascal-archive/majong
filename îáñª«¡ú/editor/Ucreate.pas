unit Ucreate;

(*
 Création des plateaux et des pièces pour le jeu du mah jong

 - le mode construction intelligente permet de placer les blocs à la
   hauteur minimun automatiquement
   Ce mode est réaliste et "respect" les lois de la gravité
 - en mode manuel, l'utilisateur doit definir lui même la hauteur de la pièce
   Ce mode permet de faire des plateaux impossible à faire en vrai puisque des pièces
   peuvent être en lévitation.
   Attention à la jouabilité car certains blocs risque de ne pas êtres visibles mais
   pouvant être joué quand même

   
*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ImgList, Spin, Buttons, AppEvnts, UScores;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    fichier1: TMenuItem;
    quitter1: TMenuItem;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    SpinEdit2: TSpinEdit;
    CheckBox1: TCheckBox;
    Button1: TButton;
    SpeedButton1: TSpeedButton;
    ImageList1: TImageList;
    ApplicationEvents1: TApplicationEvents;
    OuvrirPlateau1: TMenuItem;
    EnregistrerPlateau1: TMenuItem;
    N1: TMenuItem;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Label2: TLabel;
    NouveauPlateau1: TMenuItem;
    Option1: TMenuItem;
    EditerlesScores1: TMenuItem;
    Label4: TLabel;
    procedure quitter1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure EnregistrerPlateau1Click(Sender: TObject);
    procedure OuvrirPlateau1Click(Sender: TObject);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure EditerlesScores1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }     
     procedure dessinfond;
     function placeblocNiv(xm,ym,niv:integer):boolean;
     procedure placebloc(xm,ym:integer);
     procedure dessinzone(x1,y1,x2,y2:integer);
  end;

type
 // coordonnées d'une pièce
 tposPiece=record x,y,z:byte; end;
 // états possible
 TEtat=(Rien,AutoPlacer,ManuPlacer,SelectDeplacer,AutoDeplacer,ManuDeplacer,Supprimer);


const
 scoresvide:Tscores=
  ('01.                      -- 99:59:59 -- 000',
   '02.                      -- 99:59:59 -- 000',
   '03.                      -- 99:59:59 -- 000',
   '04.                      -- 99:59:59 -- 000',
   '05.                      -- 99:59:59 -- 000',
   '06.                      -- 99:59:59 -- 000',
   '07.                      -- 99:59:59 -- 000',
   '08.                      -- 99:59:59 -- 000',
   '09.                      -- 99:59:59 -- 000',
   '10.                      -- 99:59:59 -- 000',
   '11.                      -- 99:59:59 -- 000',
   '12.                      -- 99:59:59 -- 000',
   '13.                      -- 99:59:59 -- 000',
   '14.                      -- 99:59:59 -- 000',
   '15.                      -- 99:59:59 -- 000',
   '16.                      -- 99:59:59 -- 000',
   '17.                      -- 99:59:59 -- 000',
   '18.                      -- 99:59:59 -- 000',
   '19.                      -- 99:59:59 -- 000',
   '20.                      -- 99:59:59 -- 000');

var
  Form1: TForm1;
  Etat:Tetat=Autoplacer;   // état en cours
  niveau:integer;          // niveau manuel pour le placement des blocs
  piece1:tbitmap;          // images des pièces normales
  piece2:tbitmap;          // images des pièces selectionnées
  xp,yp:integer;           // taille des pièces
  maxx,maxy:integer;       // taille max du plateau
  xx,yy:integer;           // taille de la grille (=une demi-pièce)
  xm,ym:integer;           // coordonnées souris sur la grille
  titre:string[50];        // titre du plateau
  xmc,ymc:integer;         // coordonnées courante de la souris sur la grille
  fond:tbitmap;            // buffer du paintbox
  bloccourant:byte;        // bloc courant (lors des déplacements)
  posPiecetemp,posPiece:array[1..145] of tposPiece;
                           // dessus : tableau des positions des pièces
                           // dessous : Tableau des scores
  scores:Tscores;           //scores


implementation



{$R *.dfm}

// donne le dernier bloc placé
function maxbloc:byte;
var
 i:integer;
begin
 i:=145;
 while (i>0) and (pospiece[i].x=255) do dec(i);
 result:=i;
end;


// retire un bloc
procedure Delbloc(n:integer);
var
 i:integer;
begin
 for i:=n to maxbloc do
  begin
   pospiece[i].x:=pospiece[i+1].x;
   pospiece[i].y:=pospiece[i+1].y;
   pospiece[i].z:=pospiece[i+1].z;
  end;
 bloccourant:=0; 
end;

// retire tous les blocs
procedure EraseBloc;
var
 i:integer;
begin
 for i:=1 to 145 do posPiece[i].x:=255;
 bloccourant:=0;
end;

// inverse deux pièce
function swappiece(i,j:integer):boolean;
var
 xt,yt,zt:integer;
begin
 result:=false;
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
end;

// cherche un bloc à la position (xm,ym)
// renvois le numéro du bloc s'il existe, 0 sinon
function cherchebloc(xm,ym:integer):byte;
var
 i:integer;
begin
 result:=0;
 for i:=maxbloc downto 1 do
  if (pospiece[i].x-xm<1) and (pospiece[i].x-xm>-2) and
     (pospiece[i].y-ym<1) and (pospiece[i].y-ym>-2) and (result=0) then result:=i;
end;

// réorganise les bloc sur le plateau pour un affichage correct
procedure reorganisepiece;
var
 i:integer;
 ok:boolean;
begin
 ok:=false;
 while not ok do
  begin
   ok:=true;
   for i:=1 to maxbloc-1 do
    // si le premier est sur le deuxième (dans le plan Z), les inverser
    if pospiece[i].z>pospiece[i+1].z then ok:=swappiece(i,i+1)
    else
    // si le premier est le deuxième sont sur le même plan et que
    // le premier est plus bas que le deuxième, les inverser
    if (pospiece[i].y>pospiece[i+1].y) and (pospiece[i].z=pospiece[i+1].z) then ok:=swappiece(i,i+1)
    else
    // si le premier est le deuxième sont sur le même plan et que
    // le premier est plus à droite que le deuxième, les inverser
    if (pospiece[i].x>pospiece[i+1].x) and (pospiece[i].y=pospiece[i+1].y) and (pospiece[i].z=pospiece[i+1].z)then ok:=swappiece(i,i+1);
  end;
end;

// rajoute un bloc à la position (xm,ym) et à la profondeur la plus basse
procedure TForm1.placebloc(xm,ym:integer);
var
 i:integer;    // indice dans blocs
 prof:integer; // profondeur
 ok:boolean;   // =false si un bloc existe déjà à cette profondeur
begin
 ok:=false;
 prof:=-1;
 while (not ok) do
  begin
   ok:=true;
   inc(prof);
   for i:=1 to maxbloc do
    if (abs(pospiece[i].x-xm)<=1) and (abs(pospiece[i].y-ym)<=1) and (pospiece[i].z=prof) then ok:=false;
  end;
 i:=maxbloc+1;
 pospiece[i].x:=xm;
 pospiece[i].y:=ym;
 pospiece[i].z:=prof;
 bloccourant:=i;
 reorganisepiece;
end;

// rajoute un bloc à la position (xm,ym) et à la profondeur niv
// renvois false si c'est pas possible
function TForm1.placeblocNiv(xm,ym,niv:integer):boolean;
var
 i:integer;    // indice dans blocs
 prof:integer; // profondeur
begin
 result:=true;
 prof:=niv;
 for i:=1 to maxbloc do
  if (abs(pospiece[i].x-xm)<=1) and (abs(pospiece[i].y-ym)<=1) and (pospiece[i].z=prof) then result:=false;
 if not result then exit;
 i:=maxbloc+1;
 pospiece[i].x:=xm;
 pospiece[i].y:=ym;
 pospiece[i].z:=prof;
 bloccourant:=i;
 reorganisepiece;
end;


// dessine la zone de (x1,y1) à (x2,y2)
procedure TForm1.dessinzone(x1,y1,x2,y2:integer);
var
 i:integer;
 tmp:tbitmap;
begin
 piece2.Width:=xx*(x2-x1+1);
 piece2.Height:=yy*(y2-y1+1);
 piece2.Canvas.fillrect(piece2.Canvas.ClipRect);
 for i:=1 to maxbloc do
  if (posPiece[i].x>=x1-1) and (posPiece[i].y>=y1-1) and (posPiece[i].x<=x2+1) and (posPiece[i].y<=y2+1)then
  begin
   if posPiece[i].z>8 then imagelist1.GetBitmap(8+9*byte(i<>bloccourant),piece1)
                      else imagelist1.GetBitmap(posPiece[i].z+9*byte(i<>bloccourant),piece1);

   piece2.Canvas.Draw((posPiece[i].x-x1)*xx,(posPiece[i].y-y1)*yy,piece1);
  end;
 fond.Canvas.Draw(x1*xx,y1*yy,piece2);
end;

// décale les pièces de (dx,dy) sur la grille
procedure decale(dx,dy:integer);
var
 i:integer;
begin
 for i:=1 to maxbloc do
  begin
   pospiece[i].x:=pospiece[i].x+dx;
   pospiece[i].y:=pospiece[i].y+dy;
  end;
end;

// dessin le buffer en entier (donc toutes les pièces déjà placé)
procedure TForm1.dessinfond;
var
 i:integer;
begin
 fond.Canvas.FillRect(fond.Canvas.ClipRect);
 for i:=1 to maxbloc do
  begin
   if posPiece[i].z>8 then imagelist1.GetBitmap(8+9*byte(i<>bloccourant),piece1)
                      else imagelist1.GetBitmap(posPiece[i].z+9*byte(i<>bloccourant),piece1);

   fond.Canvas.Draw(posPiece[i].x*xx,posPiece[i].y*yy,piece1);
  end;
end;

// heu... quitte le prog
procedure TForm1.quitter1Click(Sender: TObject);
begin
 close;
end;

// à la création, il faud biensûr faire des choses
procedure TForm1.FormCreate(Sender: TObject);
begin
 // effacer les tableaux
 EraseBloc;
 pospiecetemp:=pospiece;
 scores:=scoresvide;

 // affecter les constants (qui le sont pas vraiment)
 xp:=ImageList1.Width;
 yp:=ImageList1.Height;
 xx:=xp div 2;
 yy:=yp div 2;

 // créer les bitmaps des pièces
 piece1:=tbitmap.Create;
 piece1.Width:=xp;
 piece1.Height:=yp;
 piece1.TransparentColor:=clwhite;
 piece1.Transparent:=true;

 piece2:=tbitmap.Create;
 piece2.Width:=xp;
 piece2.Height:=yp;

 // créer le buffer
 fond:=tbitmap.Create;
 fond.Width:=paintbox1.Width;
 fond.Height:=paintbox1.Height;
 // affecter des constantes qui "changent" aussi lors d'un redimensionnement
 FormResize(self);
end;


// met à jour le paintbox
procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
 paintbox1.Canvas.Draw(0,0,fond);
end;


// la fenêtre change de dimension
procedure TForm1.FormResize(Sender: TObject);
begin
 fond.Width:=paintbox1.Width;
 fond.Height:=paintbox1.Height;
 // on peu faire un plateau plus grand
 maxx:=paintbox1.Width div xx;
 maxy:=paintbox1.Height div yy;
 // on réaffiche tout
 dessinfond;
end;

// construction intelligente <-> manuelle
procedure TForm1.CheckBox1Click(Sender: TObject);
begin
 SpinEdit2.Enabled:=not checkbox1.Checked;

 if checkbox1.Checked then
  case etat of
   Manuplacer:  etat:=Autoplacer;
   Manudeplacer:etat:=Autodeplacer;
  end
 else
  case etat of
   Autoplacer:  etat:=Manuplacer;
   Autodeplacer:etat:=Manudeplacer;
  end
end;

// on efface tout et on recommence
procedure TForm1.Button1Click(Sender: TObject);
begin
 scores:=scoresvide;
 EraseBloc;
 dessinfond;
 paintbox1.Canvas.Draw(0,0,fond);
end;

// que faire quand la souris passe (le chat danse ???)
procedure TForm1.PaintBox1MouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
var
 tx,ty:integer;
begin
// calculer les coordonées selon la grille
 // seulement sur les cases paires de la grille
 if checkbox2.Checked then
  begin
   xm:=x div xx;
   ym:=y div yy;
   if xm mod 2=1 then xm:=xm-1;
   if ym mod 2=1 then ym:=ym-1;
  end
 // sur toutes les cases de la grille
 else
  begin
   xm:=x div xx;
   ym:=y div yy;
  end;

 // si les coordonées ont vraiment changé
 if (xm<>xmc) or (ym<>ymc) then
 begin
 // suivant l'état courant
 case etat of
  // faire apparaitre une pièce à l'endroit pointé
  AutoPlacer,Autodeplacer,ManuPlacer,Manudeplacer:
   begin
    if maxbloc=144 then exit;
    pospiecetemp:=pospiece;
    if etat in [ManuPlacer,Manudeplacer] then
      begin
       if not placeblocniv(xm,ym,niveau) then exit;
      end
    else
      placebloc(xm,ym);

    dessinZone(xmc,ymc,xmc+1,ymc+1);
    dessinZone(xm,ym,xm+1,ym+1);
    pospiece:=pospiecetemp;
    xmc:=xm;
    ymc:=ym;
   end;
  // cherche une pièce à selectionner ou à supprimer
  Supprimer,selectdeplacer:
   begin
    bloccourant:=cherchebloc(xm,ym);
    if bloccourant>0 then
    label2.Caption:='Niveau : '+inttostr(pospiece[bloccourant].z+1)
    else
    label2.Caption:='Niveau : ';
    dessinZone(xmc,ymc,xmc+1,ymc+1);
    xmc:=pospiece[bloccourant].x;
    ymc:=pospiece[bloccourant].y;
    dessinZone(xmc,ymc,xmc+1,ymc+1);
   end;
  rien:;
  end;
  // met à jour le paintbox
  paintbox1.Canvas.Draw(0,0,fond);
 end;
end;



// on clique sur le paintbox, quoi faire???
procedure TForm1.PaintBox1Click(Sender: TObject);
begin
 case etat of
  rien:;   // ben,... rien
  AutoPlacer,AutoDeplacer:
   begin
    if maxbloc<144 then
     begin
      placebloc(xm,ym);
      bloccourant:=0;
      dessinzone(xm,ym,xm+1,ym+1);
      xmc:=-1;
      xmc:=-1;
      if maxbloc=144 then paintbox1.Canvas.Draw(0,0,fond);
      if etat=Autodeplacer then etat:=selectdeplacer;
     end;
   end;
  ManuPlacer,ManuDeplacer:
   begin
    if maxbloc<144 then
     begin
      if not placeblocNiv(xm,ym,Niveau) then exit;
      bloccourant:=0;
      dessinzone(xm,ym,xm+1,ym+1);
      xmc:=-1;
      xmc:=-1;
      if maxbloc=144 then paintbox1.Canvas.Draw(0,0,fond);
      if etat=ManuDeplacer then etat:=selectdeplacer;
     end;
   end;
  Supprimer,SelectDeplacer:
   begin
    bloccourant:=cherchebloc(xmc,ymc);
    if bloccourant>0 then
    begin
    if etat=selectdeplacer then
     if CheckBox1.Checked then etat:=Autodeplacer
                          else etat:=Manudeplacer;
    delbloc(bloccourant);
    reorganisepiece;
    dessinzone(xmc-1,ymc-1,xmc+2,ymc+2);
    paintbox1.Canvas.Draw(0,0,fond);

    end;
   end;
 end; // End CASE
 label1.Caption:='Nombre de pieces : '+inttostr(144-maxbloc);
end;


// gère les évenements claviers
procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
 x,y:integer;
begin
if  (msg.message=WM_KEYdown) and (paintbox1.ScreenToClient(mouse.CursorPos).X>0)
and (paintbox1.ScreenToClient(mouse.CursorPos).y>0) then
 begin
  if msg.wParam in [32,37,38,39,40] then
  begin
   x:=xm*xx;
   y:=ym*yy;
   case msg.wParam of
    32:PaintBox1Click(self);
    37:x:=x-xx-xx*byte(checkbox2.Checked);
    38:y:=y-yy-yy*byte(checkbox2.Checked);
    39:x:=x+xx+xx*byte(checkbox2.Checked);
    40:y:=y+yy+yy*byte(checkbox2.Checked);
   end;
  if x<0 then x:=0;
  if y<0 then y:=0;
  if x div xx>maxx then x:=maxx*xx;
  if y div yy>maxy then y:=maxy*yy;
  PaintBox1MouseMove(self,[],x,y);
  handled:=true;
  ApplicationEvents1.CancelDispatch;
  end;
 end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
 if not Speedbutton1.Down then etat:=Rien
 else
 if CheckBox1.Checked then etat:=AutoPlacer else etat:=Manuplacer;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
 if not Speedbutton2.Down then etat:=Rien
 else
 etat:=Supprimer;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
 if not Speedbutton3.Down then etat:=Rien
 else
  etat:=SelectDeplacer
end;

function Peutdeplace(dx,dy:integer):boolean;
var
 i:integer;
begin
 result:=true;
  for i:=1 to maxbloc do
    begin
     if pospiece[i].x+dx<0 then result:=false;
     if pospiece[i].y+dy<0 then result:=false;
     if pospiece[i].x+dx>maxx then result:=false;
     if pospiece[i].y+dy>maxy then result:=false;
    end;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
 if not Peutdeplace(1,0) then exit;
 decale(1,0);
 dessinfond;
 paintbox1.Canvas.Draw(0,0,fond);
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
 if not Peutdeplace(-1,0) then exit;
 decale(-1,0);
 dessinfond;
 paintbox1.Canvas.Draw(0,0,fond);
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
 if not Peutdeplace(0,-1) then exit;
 decale(0,-1);
 dessinfond;
 paintbox1.Canvas.Draw(0,0,fond);
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
 if not Peutdeplace(0,1) then exit;
 decale(0,1);
 dessinfond;
 paintbox1.Canvas.Draw(0,0,fond);
end;

procedure TForm1.EnregistrerPlateau1Click(Sender: TObject);
var
 i:integer;
 f:integer;
begin
 if maxbloc<144 then
  begin
   messagebox(handle,'Des blocs n''ont pas été placés','Attention',0);
   exit;
  end;

 if savedialog1.Execute then
  begin
   f:=filecreate(savedialog1.FileName);
   if f=-1 then messagebox(handle,'erreur lors de l''enregistrement','erreur',0);
   filewrite(f,titre,51);
   filewrite(f,pospiece[1].x,3*144);
   filewrite(f,scores,sizeof(scores));
   fileclose(f);
  end;

end;

procedure TForm1.OuvrirPlateau1Click(Sender: TObject);
var
 i:integer;
 f:integer;
begin
 if opendialog1.Execute then
  begin
   f:=fileopen(opendialog1.FileName,fmOpenread);
   fileread(f,titre,51);
   fileread(f,pospiece[1].x,3*144);
   fileread(f,scores,sizeof(scores));
   fileclose(f);
   edit1.text:=titre;
   pospiece[145].x:=255;
   xm:=-1;
   ym:=-1;
   bloccourant:=0;
   label1.Caption:='Nombre de pieces : '+inttostr(144-maxbloc);
   dessinfond;
   paintbox1.Canvas.Draw(0,0,fond);
  end;
end;

procedure TForm1.PaintBox1DblClick(Sender: TObject);
begin
 PaintBox1Click(sender);
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
 titre:=edit1.text;
 caption:=titre;
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
niveau:=spinedit2.Value-1;
end;

procedure TForm1.EditerlesScores1Click(Sender: TObject);
begin
 form2.scores:=scores;
 if form2.showmodal<>mrok then exit;
 scores:=form2.scores;
end;

end.
