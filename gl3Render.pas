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

uses classes, sysutils, model, render, dglopengl, gl3mesh, gl3model, gl3material, gl3skeleton, glvbo;

type Tgl3Render = class(TBaseRender)
  protected
    fvbo: TglVbo;
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
  I,J,M: Integer;
  test: TVBOVertex;
begin
  //uploads models and meshes to the gpu via vbo

  //TODO: calculate model offset and size here and not in glvbo (wrongly called addmesh there)
  //TODO: also calculate offset and size for individual meshes
  //TODO: merge glvbo code to here and rename init here to upload

  for I := 0 to FNumModels-1 do
  begin
    fModels[i].Id:=fvbo.AddMesh(GL_TRIANGLES);
    for m:=0 to FModels[i].NumMeshes-1 do
    begin
      for j:=0 to FModels[i].Mesh[m].NumVertexIndices-1 do
      begin
        //TODO: move to mesh
        test.Position:=FModels[i].Mesh[m].Vertex[FModels[i].Mesh[m].VertexIndices[j]];
        test.Normal:=FModels[i].Mesh[m].Normals[FModels[i].Mesh[m].Normal[j]];
        test.Color.r:=FModels[i].material[FModels[i].Mesh[m].matid[j div 3]].DiffuseRed;
        test.Color.g:=FModels[i].material[FModels[i].Mesh[m].matid[j div 3]].DiffuseGreen;
        test.Color.b:=FModels[i].material[FModels[i].Mesh[m].matid[j div 3]].DiffuseBlue;
        test.Color.a:=FModels[i].material[FModels[i].Mesh[m].matid[j div 3]].Transparency;
        test.TexCoord.tu:=FModels[i].Mesh[m].Mapping[FModels[i].Mesh[m].Map[j]].tu;
        test.TexCoord.tv:=FModels[i].Mesh[m].Mapping[FModels[i].Mesh[m].Map[j]].tv;
        fvbo.AddVertex(test);
      end;
    end;
    Tgl3Model(FModels[i]).Offset:=fvbo.getOffset(fModels[i].Id);
    Tgl3Model(FModels[i]).Size:=fvbo.getSize(fModels[i].Id);

  end;
  fvbo.init();
end;

procedure Tgl3Render.Render(id: integer);
begin
  fvbo.render(id);
end;

procedure Tgl3Render.Render(amodel: TBaseModel);
begin
  glDrawElements(TGL3Mesh(amodel.Mesh[0]).DrawStyle, TGL3Model(amodel).size, GL_UNSIGNED_SHORT, pointer(sizeof(word)*TGL3Model(amodel).offset));
end;

procedure Tgl3Render.Render;
begin
  fvbo.PreRender;
  fvbo.render;
  fvbo.PostRender;
end;

end.
