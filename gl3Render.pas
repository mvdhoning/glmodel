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

uses classes, model, render, dglopengl, gl3mesh, glmodel, glmaterial{, glskeleton};

type Tgl3Render = class(TBaseRender)
  protected
  public
    procedure AddModel(Value: TBaseModel); overload; override;
    procedure AddModel; overload; override;
    procedure Render; override;
    procedure Init; override;
end;

implementation

procedure Tgl3Render.AddModel(Value: TBaseModel);
begin
  inherited;

  Models[FNumModels-1].MeshClass := TGL3Mesh;
  Models[FNumModels-1].MaterialClass := TGLMaterial;
  //Models[FNumModels-1].SkeletonClass := TGLSkeleton;
end;

procedure Tgl3Render.AddModel;
begin
  AddModel(TGlModel.Create(self));
end;

procedure Tgl3Render.Init;
var
  I: Integer;
begin
  for I := 0 to FNumModels-1 do
  begin
    FModels[i].Init;
  end;
end;

procedure Tgl3Render.Render;
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
