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

uses
  Forms,
  OpenGL15_MainForm in 'OpenGL15_MainForm.pas' {GLForm},
  Model in 'Model.pas',
  Material in 'Material.pas',
  Skeleton in 'Skeleton.pas',
  Mesh in 'Mesh.pas',
  glMaterial in 'glMaterial.pas',
  Bone in 'Bone.pas',
  KeyFrame in 'KeyFrame.pas',
  Model3ds in 'Model3ds.pas',
  ModelMsa in 'ModelMsa.pas',
  ModelObj in 'ModelObj.pas',
  glMesh in 'glMesh.pas',
  glModel in 'glModel.pas',
  Render in 'Render.pas',
  SkeletonMsa in 'SkeletonMsa.pas',
  glBone in 'glBone.pas',
  ModelFactory in 'ModelFactory.pas',
  FileFormats3d in 'FileFormats3d.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGLForm, GLForm);
  Application.Run;
end.
