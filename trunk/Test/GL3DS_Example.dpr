program GL3DS_Example;



uses
  Forms,
  OpenGL15_MainForm in 'OpenGL15_MainForm.pas' {GLForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGLForm, GLForm);
  Application.Run;
end.
