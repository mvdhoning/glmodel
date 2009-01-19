program GL3DS_Example;

{%TogetherDiagram 'ModelSupport_OpenGL15_Template\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\SkeletonMsa\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\glModel\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\KeyFrame\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\glBone\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Skeleton\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\ModelMsa\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\glMesh\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Material\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Model3ds\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\ModelObj\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\OpenGL15_MainForm\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Mesh\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\glMaterial\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Model\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Bone\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Render\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\OpenGL15_Template\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\default.txvpck'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\Model\default.txvpck'}
{%TogetherDiagram 'ModelSupport_OpenGL15_Template\OpenGL15_Template\default.txvpck'}
{%File 'ModelSupport\OpenGL15_MainForm\OpenGL15_MainForm.txvpck'}
{%File 'ModelSupport\default.txvpck'}

uses
  Forms,
  OpenGL15_MainForm in 'OpenGL15_MainForm.pas' {GLForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGLForm, GLForm);
  Application.Run;
end.
