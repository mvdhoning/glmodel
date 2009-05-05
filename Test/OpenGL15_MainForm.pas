// =============================================================================
//   OpenGL1.5 - VCL Template (opengl15_vcl_template.zip)
// =============================================================================
//   Copyright © 2003 by DGL - http://www.delphigl.com
// =============================================================================
//   Contents of this file are subject to the GNU Public License (GPL) which can
//   be obtained here : http://opensource.org/licenses/gpl-license.php
// =============================================================================
//   History :
//    Version 1.0 - Initial Release                            (Sascha Willems)
// =============================================================================

unit OpenGL15_MainForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  dglOpenGL,
//  gl3ds;

  //Render,
  glRender,
  Model,
  Model3ds,
  ModelObj,
  ModelX,
  ModelMsa,
  Mesh,
  MeshGen,
  Material,
  glMath;
 // Material,
 // glMaterial,
 // glModel;


type
  TGLForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private-Deklarationen }
  public
    RC        : HGLRC;
    DC        : HDC;
    ShowFPS   : Boolean;
    FontBase  : GLUInt;
    StartTick : Cardinal;
    Frames    : Integer;
    FPS       : Single;
    procedure GoToFullScreen(pWidth, pHeight, pBPP, pFrequency : Word);
    procedure BuildFont(pFontName : String);
    procedure PrintText(pX,pY : Integer; const pText : String);
    procedure ShowText;
  end;

var
  GLForm: TGLForm;


  scene1: TglRender;
  model1: TBaseModel;
  
 // mesh2: TglModel;

//  mesh1: TAll3dsMesh;
  //mat: TBaseMaterial;

  //ambience: array[0..3] of glfloat = (0.5, 0.5, 0.5, 1.0);
  //diffuse: array[0..3] of glfloat = (0.8, 0.8, 0.8, 1.0);
  //specular: array[0..3] of glfloat = (0.6, 0.6, 0.6, 1.0);
  //g_LightPosition: array[0..3] of glfloat = ( -1.5, 1.0, -4.0, 1.0);

  g_LightPosition : Array[0..3] of glFloat = ( 0.0, 4.0, 6.0, 1.0);	// Light Position
  ambience : Array[0..3] of glFloat = ( 0.2, 0.2, 0.2, 1.0);	// Ambient Light Values
  diffuse : Array[0..3] of glFloat = ( 0.6, 0.6, 0.6, 1.0);	// Diffuse Light Values
  specular : Array[0..3] of glFloat = ( 0.1, 0.1, 0.1, 1.0);	// Specular Light Values


implementation

{$R *.dfm}

// =============================================================================
//  TForm1.GoToFullScreen
// =============================================================================
//  Wechselt in den mit den Parametern angegebenen Vollbildmodus
// =============================================================================
procedure TGLForm.GoToFullScreen(pWidth, pHeight, pBPP, pFrequency : Word);
var
 dmScreenSettings : DevMode;
begin
// Fenster vor Vollbild vorbereiten
WindowState := wsMaximized;
BorderStyle := bsNone;
ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
with dmScreenSettings do
 begin
 dmSize              := SizeOf(dmScreenSettings);
 dmPelsWidth         := pWidth;                    // Breite
 dmPelsHeight        := pHeight;                   // Höhe
 dmBitsPerPel        := pBPP;                      // Farbtiefe
 dmDisplayFrequency  := pFrequency;                // Bildwiederholfrequenz
 dmFields            := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL or DM_DISPLAYFREQUENCY;
 end;
if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
 begin
 MessageBox(0, 'Konnte Vollbildmodus nicht aktivieren!', 'Error', MB_OK or MB_ICONERROR);
 exit
 end;
end;

// =============================================================================
//  TForm1.BuildFont
// =============================================================================
//  Displaylisten für Bitmapfont erstellen
// =============================================================================
procedure TGLForm.BuildFont(pFontName : String);
var
 Font : HFONT;
begin
// Displaylisten für 256 Zeichen erstellen
FontBase := glGenLists(96);
// Fontobjekt erstellen
Font     := CreateFont(16, 0, 0, 0, FW_MEDIUM, 0, 0, 0, ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
                       ANTIALIASED_QUALITY, FF_DONTCARE or DEFAULT_PITCH, PChar(pFontName));
// Fontobjekt als aktuell setzen
SelectObject(DC, Font);
// Displaylisten erstellen
wglUseFontBitmaps(DC, 0, 256, FontBase);
// Fontobjekt wieder freigeben
DeleteObject(Font)
end;

// =============================================================================
//  TForm1.PrintText
// =============================================================================
//  Gibt einen Text an Position x/y aus
// =============================================================================
procedure TGLForm.PrintText(pX,pY : Integer; const pText : String);
begin
if (pText = '') then
 exit;
glPushAttrib(GL_LIST_BIT);
 glRasterPos2i(pX, pY);
 glListBase(FontBase);
 glCallLists(Length(pText), GL_UNSIGNED_BYTE, PChar(pText));
glPopAttrib;
end;

// =============================================================================
//  TForm1.ShowText
// =============================================================================
//  FPS, Hilfstext usw. ausgeben
// =============================================================================
procedure TGLForm.ShowText;
begin
// Tiefentest und Texturierung für Textanzeige deaktivieren
glDisable(GL_DEPTH_TEST);
glDisable(GL_TEXTURE_2D);
// In orthagonale (2D) Ansicht wechseln
glMatrixMode(GL_PROJECTION);
glLoadIdentity;
glOrtho(0,640,480,0, -1,1);
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;
PrintText(5,15, FloatToStr(FPS)+' fps');
glEnable(GL_DEPTH_TEST);
glEnable(GL_TEXTURE_2D);
end;

var
  s: string;
  xspeed: single;
  yspeed: single;

  xangle: single;
  yangle: single;

  v1: T3dPoint;
  map: TMap;
  tel: integer;

// =============================================================================
//  TForm1.FormCreate
// =============================================================================
//  OpenGL-Initialisierungen kommen hier rein
// =============================================================================
procedure TGLForm.FormCreate(Sender: TObject);
begin
DecimalSeparator:='.'; //always use . as decimal seperator if it is , for dutch language!

// Wenn gewollt, dann hier in den Vollbildmodus wechseln
// Muss vorm Erstellen des Kontextes geschehen, da durch den Wechsel der
// Gerätekontext ungültig wird!
// GoToFullscreen(1600, 1200, 32, 75);

// OpenGL-Funtionen initialisieren
InitOpenGL;
// Gerätekontext holen
DC := GetDC(Handle);
// Renderkontext erstellen (32 Bit Farbtiefe, 24 Bit Tiefenpuffer, Doublebuffering)
RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0);
// Erstellten Renderkontext aktivieren
ActivateRenderingContext(DC, RC);
// Tiefenpuffer aktivieren
glEnable(GL_DEPTH_TEST);
// Nur Fragmente mit niedrigerem Z-Wert (näher an Betrachter) "durchlassen"
glDepthFunc(GL_LESS);
// Löschfarbe für Farbpuffer setzen
glClearColor(0,0,0,0);
// Displayfont erstellen
BuildFont('MS Sans Serif');



Model1 := TBaseModel.Create(nil);
Model1.LoadFromFile('models\tulip.3ds');
Model1.SaveToFile('tulip.txt');
Model1.Free;


// Load 3ds meshes

//mesh1 := TAll3dsMesh.Create(nil);
//mesh1.TexturePath :='textures\';
//mesh1.LoadFromFile('models\character2.txt');

scene1 := TglRender.Create(nil);


//mat := TGLMaterial.Create(nil);

//mesh1:=TMsaModel.Create(nil);
//mesh1 := TBaseModelFactory.LoadModel(T3dsModel, 'models\tulip.3ds');

scene1.AddModel();
//mesh1 := TBaseModel.Create(nil);

//mesh1.TexturePath:='textures\';  // no use at this point...

//scene1.Models[0].LoadFromFile('models\tulip.3ds');  //Yeah it works again!!!...
scene1.Models[0].LoadFromFile('models\hog2.txt');
//scene1.Models[0].LoadFromFile('models\soccerball.obj');
//scene1.Models[0].LoadFromFile('models\trashbin.obj');
//scene1.Models[0].LoadFromFile('models\houseobjtexwin.obj');
//scene1.Models[0].LoadFromFile('models\housewiththickwalls.obj');
//scene1.Models[0].LoadFromFile('models\houseobj.x');
//scene1.Models[0].LoadFromFile('c:\test\accel\cell.x');

//scene1.AddModel; //this gives error on calculation normals after loading soccerball.obj
//scene1.Models[1].LoadFromFile('models\tulip.3ds'); //was tulip.3ds


//scene1.AddModel;
//scene1.Models[2].LoadFromFile('models\tulip.3ds');

//mesh1.LoadFromFile('models\character2.txt'); //Load the mesh...
//mesh1.LoadFromFile('models\bend.txt');

scene1.Models[0].TexturePath:='textures\'; //set texturepath again since it is lost...
//scene1.Models[1].TexturePath:='models\';

//TMsaModel(mesh1).SaveToFile('tulip.txt');
//scene1.Models[0].SaveToFile('hog.txt');
//TBaseModelFactory.SaveModel(TMsaModel, 'new.txt', mesh1);

  scene1.UpdateTextures; //If this is forgotten disaster happens... FIX ASAP

  //dynamic mesh creation example ...
  scene1.AddModel; //new model
  scene1.Models[1].AddMesh; //new mesh
  scene1.Models[1].AddMaterial;  //new material
  scene1.Models[1].Material[0].DiffuseRed:= 1.0; //make it red
  scene1.Models[1].Material[0].DiffuseBlue:= 0.0;
  scene1.Models[1].Material[0].DiffuseGreen:= 0.0;
  scene1.Models[1].Material[0].AmbientRed:= 0.5; //make it red
  scene1.Models[1].Material[0].IsAmbient:=true;
  scene1.Models[1].Material[0].Name:='RedMat';

  //generate cube
  //TMeshGen(scene1.Models[1].Mesh[0]).GenerateCube(2,2,2);
  //TMeshGen(scene1.Models[1].Mesh[0]).GeneratePlane(2,2);
  //TMeshGen(scene1.Models[1].Mesh[0]).GenerateDisc(2);
  TMeshGen(scene1.Models[1].Mesh[0]).GenerateCylinder(2,2);

  //apply material (optional?)
  scene1.Models[1].Mesh[0].MatName[0]:=scene1.Models[1].Material[0].Name;
  scene1.Models[1].Mesh[0].MatID[0]:=0; //first material in model

  //calculate size for bounding box
  scene1.Models[1].CalculateSize;

  //determine render order even with one mesh
  scene1.Models[1].CalculateRenderOrder;

  //save test
  scene1.Models[1].SaveToFile('test.obj');

  //end dynamic mesh creation example ...

  //glinit;
    glClearColor(0.0, 0.0, 0.0, 0.0); 	   // Black Background
  glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
  glClearDepth(1.0);                       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
  glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations



  glenable(GL_LIGHTING);
	glLightfv(GL_LIGHT0, GL_SPECULAR, @specular);		// Input our specular to OpenGL
	glLightfv( GL_LIGHT0, GL_AMBIENT,  @ambience );		// Set our ambience light values
	glLightfv( GL_LIGHT0, GL_DIFFUSE,  @diffuse );		// Set our diffuse light color
	glLightfv( GL_LIGHT0, GL_POSITION, @g_LightPosition );	// This sets our light position
  glenable(GL_LIGHT0);
  glLightfv( GL_LIGHT0, GL_POSITION, @g_LightPosition );

  glEnable (GL_BLEND); glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


// Idleevent für Rendervorgang zuweisen
Application.OnIdle := ApplicationEventsIdle;
// Zeitpunkt des Programmstarts für FPS-Messung speichern
StartTick := GetTickCount;

//glEnable(GL_NORMALIZE);
  s := gluErrorString(glGetError);

    xSpeed :=0.4;   // start with some movement
  ySpeed :=0.4;

end;

// =============================================================================
//  TForm1.FormDestroy
// =============================================================================
//  Hier sollte man wieder alles freigeben was man so im Speicher belegt hat
// =============================================================================
procedure TGLForm.FormDestroy(Sender: TObject);
begin

  //mat.free;
  Scene1.Free;


// Renderkontext deaktiveren
DeactivateRenderingContext;
// Renderkontext "befreien"
wglDeleteContext(RC);
// Erhaltenen Gerätekontext auch wieder freigeben
ReleaseDC(Handle, DC);
// Falls wir im Vollbild sind, Bildschirmmodus wieder zurücksetzen
ChangeDisplaySettings(devmode(nil^), 0);

end;



// =============================================================================
//  TForm1.ApplicationEventsIdle
// =============================================================================
//  Hier wird gerendert. Der Idle-Event wird bei Done=False permanent aufgerufen
// =============================================================================
procedure TGLForm.ApplicationEventsIdle(Sender: TObject; var Done: Boolean);

begin

  s := gluErrorString(glGetError);

glenable(GL_LIGHTING);

// In die Projektionsmatrix wechseln
glMatrixMode(GL_PROJECTION);
// Identitätsmatrix laden
glLoadIdentity;
// Viewport an Clientareal des Fensters anpassen
glViewPort(0, 0, ClientWidth, ClientHeight);
// Perspective, FOV und Tiefenreichweite setzen
gluPerspective(60, ClientWidth/ClientHeight, 1, 128);

// In die Modelansichtsmatrix wechseln
glMatrixMode(GL_MODELVIEW);
// Identitätsmatrix laden
glLoadIdentity;
// Farb- und Tiefenpuffer löschen
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

Scene1.AdvanceAnimation;
//advance animation
//if mesh1.NumSkeletons >= 1 then
//begin
//  mesh1.Skeleton[0].AdvanceAnimation();
//  mesh1.calculatesize; //TODO: does not help as mesh is altered during rendering...
//end;

//glLightfv( GL_LIGHT0, GL_POSITION, @g_LightPosition );
glLoadIdentity();


// Render the mesh
//glpushmatrix();

 //gltranslatef(0.0,-15.0,-100.0);



 //Scene1.Render;

// glPushMatrix();

//  glrotatef(180,1.0,1.0,1.0);



 glTranslatef(0.0,0.0, -10.0);
 //glscalef(0.25,0.25,0.25);



 //glRotatef(-90.0,0.0,0.0,1.0);
 glRotatef(xangle,1.0,0.0,0.0);
 glRotatef(yangle,0.0,1.0,0.0);

  Scene1.Models[0].Render;
  Scene1.Models[1].Render;

 //TglModel(mesh1).Render; //uggly?

glClear(GL_DEPTH_BUFFER_BIT); //clear the depth buffers before drawing boundbox and bones

gldisable(GL_LIGHTING);

//mat.Apply;

//Scene1.Models[0].RenderBoundBox;
//TglModel(mesh1).RenderBoundBox;

//if Scene1.Models[0].NumSkeletons >= 1 then
//  Scene1.Models[0].RenderSkeleton;

//glpopmatrix();



// Show fps
ShowText;

// Hinteren Puffer nach vorne bringen
SwapBuffers(DC);

// Windows denken lassen, das wir noch nicht fertig wären
Done := False;

// Nummer des gezeichneten Frames erhöhen
inc(Frames);
// FPS aktualisieren
if GetTickCount - StartTick >= 500 then
 begin
 FPS       := Frames/(GetTickCount-StartTick)*1000;
 Frames    := 0;
 StartTick := GetTickCount
 end;

  xAngle :=xAngle + xSpeed;
  yAngle :=yAngle + ySpeed;

//  if s <> 'no error' then
//    Showmessage('OpenGL meldet: "' + s + '"');
end;

// =============================================================================
//  TForm1.FormKeyPress
// =============================================================================
procedure TGLForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
case Key of
 #27 : Close;
end;
end;

end.
