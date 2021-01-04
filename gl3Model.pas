unit gl3Model;

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
 * Portions created by the Initial Developer are Copyright (C) 2002-2004
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

uses classes, Model;

type
  Tgl3Model = class(TBaseModel)
    private
      foffset: integer;
      fsize: integer;
    public
      procedure Init; override;
      procedure Render; override;
      procedure RenderBoundBox; override;
      procedure RenderSkeleton; override;
      procedure UpdateTextures; override;
      property Offset: integer read foffset write foffset;
      property Size: integer read fsize write fsize;
  end;

implementation

uses dglOpenGl, Render, gl3Render;

procedure Tgl3Model.Init;
var
  m: Integer;
begin
    fId := Tgl3Render(Owner).VBO.AddMesh(GL_TRIANGLES);
    for m := 0 to FNumMeshes - 1 do
    begin
      FMesh[FRenderOrder[m]].Init;
    end;
    fOffset:=Tgl3Render(Owner).VBO.getOffset(fId);
    fSize:=Tgl3Render(Owner).VBO.getSize(fId);

end;

procedure Tgl3Model.Render;
begin
    TBaseRender(owner).render(self);
end;

procedure Tgl3Model.RenderBoundBox;
var
  loop: Integer;
begin
  if fnummeshes>0 then
    for loop:=0 to fnummeshes-1 do
    begin
      fmesh[loop].RenderBoundBox;
    end;
end;

procedure Tgl3Model.RenderSkeleton;
var
  b: integer;
begin
  for b := 0 to fSkeleton[0].NumBones - 1 do
begin
  fSkeleton[0].Bone[b].Render;
end;
end;

procedure Tgl3Model.UpdateTextures;
var
  m: integer;
begin
  for m := 0 to FNumMaterials - 1 do
  begin
    fmaterial[m].UpdateTexture;
  end;
end;

end.
