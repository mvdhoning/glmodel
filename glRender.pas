unit glRender;

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

interface

uses classes, model, render, dglopengl, glmodel, glmesh, glmaterial, glskeleton;

type TGLRender = class(TBaseRender)
  protected
  public
    procedure AddModel(Value: TBaseModel); overload; override;
    procedure AddModel; overload; override;
    procedure Render; override;
    procedure Init; override;
end;

implementation

procedure TglRender.Init;
var
  i: integer;
begin
  for i := 0 to FNumModels-1 do
  begin
    if fModels[i].NumSkeletons >= 1 then
    begin
      fModels[i].Skeleton[0].InitBones; //initialize bone matrices
      fModels[i].InitSkin;              //bind mesh to bones
    end;
  end;
end;

procedure TglRender.AddModel(Value: TBaseModel);
begin
  inherited;

  Models[FNumModels-1].MeshClass := TGLMesh;
  Models[FNumModels-1].MaterialClass := TGLMaterial;
  Models[FNumModels-1].SkeletonClass := TGLSkeleton;
end;

procedure TglRender.AddModel;
begin
  AddModel(TGlModel.Create(self));
end;

procedure TglRender.Render;
var
  I: Integer;
begin
  for I := 0 to FNumModels-1 do
  begin
    glpushmatrix();
    FModels[i].Render;
    glpopmatrix();
  end;
end;

end.
