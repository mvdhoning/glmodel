unit gl3Render;

(* Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the gl3ds main unit.
 *
 * The Initial Developer of the Original Code is
 * Noeska Software.
 * Portions created by the Initial Developer are Copyright (C) 2007
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

{$IFDEF FPC}
  {$MODE Delphi}
  {$H+}
  {$M+}
  {$codepage utf8}
  {$IFNDEF WINDOWS}
    {$LINKLIB c}
  {$ENDIF}
{$ENDIF}  
 
interface

uses classes, sysutils, model, render, dglopengl, gl3mesh, gl3model, gl3material, gl3skeleton, glvbo, glshader;

type Tgl3Render = class(TBaseRender)
  protected
    fvbo: TglVbo;                       // a vertex buffer object
    fBoneMatLocation: GLint;
    fUseBonesLocation: GLint;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure AddModel(Value: TBaseModel); overload; override;
    procedure AddModel; overload; override;
    procedure Render; overload; override;
    procedure Render(id: integer); overload; override;
    procedure Render(amodel: TBaseModel); overload; override;
    procedure Init; override;
    property VBO: TglVbo read fvbo write fvbo;
    property BoneMatLocation: GLint read fBoneMatLocation write fBoneMatLocation;
    property UseBonesLocation: GLint read fUseBonesLocation write fUseBonesLocation;
end;

implementation

constructor Tgl3Render.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FName := 'TGL3Render';
  fvbo:=TglVbo.Create;
end;

destructor Tgl3Render.Destroy();
begin
  FreeAndNil(fvbo);
  inherited Destroy;
end;

procedure Tgl3Render.AddModel(Value: TBaseModel);
begin
  inherited;
  Models[FNumModels-1].MeshClass := TGL3Mesh;
  Models[FNumModels-1].MaterialClass := TGL3Material;
  Models[FNumModels-1].SkeletonClass := TGL3Skeleton;
end;

procedure Tgl3Render.AddModel;
begin
  AddModel(TGl3Model.Create(self));
end;

procedure Tgl3Render.Init;
var
  i: Integer;
begin
  //uploads models and meshes to the gpu via vbo

  //TODO: calculate model offset and size here and not in glvbo (wrongly called addmesh there)
  //TODO: also calculate offset and size for individual meshes
  //TODO: merge glvbo code to here and rename init here to upload

  glUniform1f(fUseBonesLocation, 0);
  for i := 0 to FNumModels-1 do
  begin

    if fModels[i].NumSkeletons >= 1 then
    begin
      glUniform1f(fUseBonesLocation, 1);
      fModels[i].Skeleton[0].InitBones; //initialize bone matrices
      //fModels[i].InitSkin;            //bind mesh to bones
    end;

    fModels[i].Init;

  end;

  fvbo.init();
end;

procedure Tgl3Render.Render(id: integer);
begin
  fvbo.render(id);
end;

procedure Tgl3Render.Render(amodel: TBaseModel);
begin
  //TODO: reimplement
end;

procedure Tgl3Render.Render;
var
  i: integer;
begin
  fvbo.PreRender;
  for i := 0 to FNumModels-1 do
    fModels[i].Render;
  fvbo.PostRender;
end;

end.
