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
     foffset: integer;
     fsize: integer;
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
    property Offset: integer read foffset write foffset;
    property Size: integer read fsize write fsize;
  end;

implementation

uses Material, model, gl3Render, glvbo;

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

  fId:= Tgl3Render(Owner.Owner).VBO.AddMesh(GL_TRIANGLES);

  // fill the vbo buffer with vertices and colors and normals (and uv tex coords)
  for j:=0 to fnumvertexindices-1 do
  begin
    test.Position:=fVertex[fVertexIndices[j]];
    test.Normal:=fvNormal[fNormalIndices[j]];

    if TBaseModel(owner).NumMaterials>=1 then
    begin
      test.Color.r:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseRed;
      test.Color.g:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseGreen;
      test.Color.b:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseBlue;
      test.Color.a:=TBaseModel(owner).material[fmatid[j div 3]].Transparency;
    end
    else
    begin
      test.Color.r:=1.0;
      test.Color.g:=1.0;
      test.Color.b:=1.0;
      test.Color.a:=1.0;
    end;

    if high(fMappingIndices)>=1 then
    begin
      test.TexCoord.tu:=fMapping[fMappingIndices[j]].tu;
      test.TexCoord.tv:=fMapping[fMappingIndices[j]].tv;
    end
    else
    begin
      test.TexCoord.tu:=0.0;
      test.TexCoord.tv:=0.0;
    end;

    test.BoneIndex.x:=fBoneIndices[FVertexIndices[j],0]; //only one bone for now
    test.BoneIndex.y:=fBoneIndices[FVertexIndices[j],1];
    test.BoneIndex.z:=fBoneIndices[FVertexIndices[j],2];
    test.BoneIndex.w:=fBoneIndices[FVertexIndices[j],3];
    test.BoneWeight.x:=fBoneWeights[FVertexIndices[j],0]; //only one bone for now
    test.BoneWeight.y:=fBoneWeights[FVertexIndices[j],1];
    test.BoneWeight.z:=fBoneWeights[FVertexIndices[j],2];
    test.BoneWeight.w:=fBoneWeights[FVertexIndices[j],3];
    Tgl3Render(TBaseModel(Owner).Owner).VBO.AddVertex(test);
  end;

  fOffset:=Tgl3Render(Owner.Owner).VBO.getOffset(fId);
  fSize:=Tgl3Render(Owner.Owner).VBO.getSize(fId);

  //TODO: implement further
end;

procedure Tgl3Mesh.Render;
var
  imatid: integer;
begin

  imatid := FMatId[0];
  if TBaseModel(owner).NumMaterials >0 then
    if (TBaseModel(owner).material[imatid]<>nil) then
      if (TBaseModel(owner).material[imatid] is TBaseMaterial) then
        TBaseModel(owner).material[imatid].apply;

  Tgl3Render(Owner.Owner).Render(fId);

end;

end.
