unit gl3Mesh;

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

uses classes, dglOpenGl, Mesh, glMath, sysutils;

type

  Tgl3Mesh = class(TBaseMesh)
  protected
     fDrawStyle: GLenum;
     fNormalAttribId: GlInt;
     fColorAttribId: GlInt;
     fVertexAttribId: GlInt;
     fBoneAttribId: GlInt;
     fBoneAttribWeight: GlInt;
     fBones: GlInt;
  public
    destructor Destroy; override;
    procedure Init; override;
    procedure Render; override;
    property DrawStyle: GLenum read fDrawStyle write fDrawStyle;
    property VertexAttribId: GLInt read fVertexAttribId write fVertexAttribId;
    property ColorAttribId: GLInt read fColorAttribId write fColorAttribId;
    property NormalAttribId: GLInt read fNormalAttribId write fNormalAttribId;
    property BoneAttribId: GLInt read fBoneAttribId write fBoneAttribId;
    property BoneAttribWeight: GLInt read fBoneAttribWeight write fBoneAttribWeight;
    property Bones: GLInt read fBones write fBones;
  end;

implementation

uses Material, model, Render, gl3Render, glvbo;

destructor Tgl3Mesh.Destroy;
begin
  inherited;
end;

procedure Tgl3Mesh.Init;
var
  j: integer;
  test: TVBOVertex;
begin

  if (fdrawstyle = 0) then fDrawStyle:=GL_TRIANGLES;

  // fill the vbo buffer with vertices and colors and normals (and uv tex coords)
  for j:=0 to fnumvertexindices-1 do
  begin
    test.Position:=fVertex[fVertexIndices[j]];
    test.Normal:=fvNormal[fNormalIndices[j]];
    test.Color.r:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseRed;
    test.Color.g:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseGreen;
    test.Color.b:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseBlue;
    test.Color.a:=TBaseModel(owner).material[fmatid[j div 3]].Transparency;
    test.TexCoord.tu:=fMapping[fMappingIndices[j]].tu;
    test.TexCoord.tv:=fMapping[fMappingIndices[j]].tv;
    test.BoneIndex.x:=fBoneIndices[FVertexIndices[j],0]; //only one bone for now
    test.BoneIndex.y:=0.0;
    test.BoneIndex.z:=0.0;
    test.BoneIndex.w:=0.0;
    Tgl3Render(TBaseModel(Owner).Owner).VBO.AddVertex(test);
  end;
  //TODO: implement further
end;

procedure Tgl3Mesh.Render;
begin
  TBaseRender(TBaseModel(Owner).Owner).Render(TBaseModel(Owner).Id); //render with model id that mesh belongs to
end;

end.
