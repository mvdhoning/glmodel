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
  (*
  TVBOVertex = packed record
    Position: T3dPoint;
    Normal: T3dPoint;
    Color: TGLColor;
    BoneIndex: TBoneIdArray;
    BoneWeight: TBoneIdArray;
  end;

  TVBOBuffer = array of TVBOVertex;
  *)

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

uses Material, glMatrix, glMaterial, glModel, model, Render, glvbo;

destructor Tgl3Mesh.Destroy;
begin
  inherited;
end;

procedure Tgl3Mesh.Init;
var
  i,j,m: integer;
    test: TVBOVertex;
begin
  i:=0;
  m:=0;
  writeln('gl3mesh init called');
  writeln(TBaseRender(TBaseModel(Owner).Owner).Name); //call the render function on render class
  writeln('---');
  if (fdrawstyle = 0) then fDrawStyle:=GL_TRIANGLES;
  // fill the vbo buffer with vertices and colors and normals (and uv tex coords)
  //setlength(FVBOBuffer, fNumVertexIndices);
  for j:=0 to fnumvertexindices-1 do
  begin

    test.Position:=fVertex[fVertexIndices[j]];
    test.Normal:=fvNormal[fNormalIndices[j]];
    test.Color.r:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseRed;
    test.Color.g:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseGreen;
    test.Color.b:=TBaseModel(owner).material[fmatid[j div 3]].DiffuseBlue;
    test.Color.a:=TBaseModel(owner).material[fmatid[j div 3]].Transparency;
    //Tgl3Render(TBaseModel(Owner).Owner).fVBO;


    //fVboBuffer[i].Position:=FVertex[FVertexIndices[i]];

    //fVboBuffer[i].Normal:=FvNormal[FNormalIndices[i]];
    //fVboBuffer[i].Color.r:=TBaseModel(owner).material[fmatid[i div 3]].DiffuseRed;
    //fVboBuffer[i].Color.g:=TBaseModel(owner).material[fmatid[i div 3]].DiffuseGreen;
    //fVboBuffer[i].Color.b:=TBaseModel(owner).material[fmatid[i div 3]].DiffuseBlue;
    //fVboBuffer[i].Color.a:=0.2;//TBaseModel(owner).material[fmatid[i div 3]].Transparency;//1.0;

    //writeln( FloatToStr(fVboBuffer[i].Color.a) );

    //fVboBuffer[i].BoneIndex[0]:=fBoneIndices[FVertexIndices[i]][0];
    //fVboBuffer[i].BoneIndex[1]:=fBoneIndices[FVertexIndices[i]][1];
    //fVboBuffer[i].BoneIndex[2]:=fBoneIndices[FVertexIndices[i]][2];
    //fVboBuffer[i].BoneIndex[3]:=fBoneIndices[FVertexIndices[i]][3];

    //fVboBuffer[i].BoneWeight[0]:=fBoneWeights[FVertexIndices[i]][0];
    //fVboBuffer[i].BoneWeight[1]:=fBoneWeights[FVertexIndices[i]][1];
    //fVboBuffer[i].BoneWeight[2]:=fBoneWeights[FVertexIndices[i]][2];
    //fVboBuffer[i].BoneWeight[3]:=fBoneWeights[FVertexIndices[i]][3];


    (*
    writeln('');
    writeln('-----------------------------------');
    writeln(FVertexIndices[i]);
    writeln('-----------------------------------');
    writeln(fVboBuffer[i].BoneIndex[0]);
    writeln(fVboBuffer[i].BoneIndex[1]);
    writeln(fVboBuffer[i].BoneIndex[2]);
    writeln(fVboBuffer[i].BoneIndex[3]);
    writeln('===================================');
    writeln(fVboBuffer[i].BoneWeight[0]);
    writeln(fVboBuffer[i].BoneWeight[1]);
    writeln(fVboBuffer[i].BoneWeight[2]);
    writeln(fVboBuffer[i].BoneWeight[3]);
    writeln('===================================');
    *)

  end;
  (*
  // make a new index buffer
  setLength(FVBOIndices, fNumVertexIndices);
  for i:=0 to fnumvertexindices-1 do
  begin
    fVboIndices[i]:=i;
  end;

  //assign the vbo buffer to opengl
  glGenBuffers(1, @FVBO);
  glBindBuffer(GL_ARRAY_BUFFER, FVBO);
  glBufferData(GL_ARRAY_BUFFER, fNumVertexIndices*sizeof(TvboVertex), @FvboBuffer[0], GL_STATIC_DRAW);
  //writeln(glGetError());

  //assign the index buffer to opengl
  glGenBuffers(1, @FIBO);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, FIBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, fNumVertexIndices*sizeof(word), @FVboIndices[0], GL_STATIC_DRAW);
  //writeln(glGetError());
  *)
  (* //buffer draw
  glGenBuffers(1, @FVBO);
  glBindBuffer(GL_ARRAY_BUFFER, FVBO);
  glBufferData(GL_ARRAY_BUFFER, fNumVertex*sizeof(T3dPoint), @Fvertex[0], GL_STATIC_DRAW);
  writeln(glGetError());

  glGenBuffers(1, @FIBO);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, FIBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, fNumVertexIndices*sizeof(word), @FVertexIndices[0], GL_STATIC_DRAW);
  writeln(glGetError());
  *)
end;

procedure Tgl3Mesh.Render;
var
  bonematrices:array [0..(4*16)-1] of single;
  mmatrix : array[0..15] of single;
  imatrix : array[0..15] of single;
  mat: array[0..15] of single;
  i: integer;
begin

  //TBaseRender(TBaseModel(Owner).Owner).Render(fId);
  TBaseRender(TBaseModel(Owner).Owner).Render(TBaseModel(Owner).Id); //render with model id that mesh belongs to
  //TBaseRender(TBaseModel(Owner).Owner).Render(TBaseModel(Owner));

  (* //static draw
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3,GL_FLOAT,0,@FVertex[0]);
  glDrawElements(GL_TRIANGLES, fNumVertexIndices, GL_UNSIGNED_SHORT, @FVertexIndices[0]);
  glDisableClientState(GL_VERTEX_ARRAY);
  *)

  (* //buffer draw
  glBindBuffer(GL_ARRAY_BUFFER, FVBO);
  glVertexPointer(3, GL_FLOAT, sizeof(T3dPoint), pointer(0));
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, FIBO);

  glEnableClientState(GL_VERTEX_ARRAY);
  glDrawElements(GL_TRIANGLES, fnumvertexindices, GL_UNSIGNED_SHORT, nil);
  glDisableClientState(GL_VERTEX_ARRAY);
  *)

  (*
  if TBaseModel(owner).NumSkeletons >= 1 then
    begin
      //if there is a bone then apply bone translate etc...
      if TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].NumBones>0 then
         if FBoneIndices <> nil then
            begin
              //writeln('bork');
              TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[0].Matrix.getMatrix(mmatrix);
              TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[0].InverseMatrix.getMatrix(imatrix);
              MatrixMultiply(mat,mmatrix,imatrix);
              for i:=0 to 15 do
                  bonematrices[i]:=mat[i];

              TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[1].Matrix.getMatrix(mmatrix);
              TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[1].InverseMatrix.getMatrix(imatrix);
              MatrixMultiply(mat,mmatrix,imatrix);
              for i:=0 to 15 do
                  bonematrices[16+i]:=mat[i];

              TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[2].Matrix.getMatrix(mmatrix);
              TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[2].InverseMatrix.getMatrix(imatrix);
              MatrixMultiply(mat,mmatrix,imatrix);
              for i:=0 to 15 do
                  bonematrices[32+i]:=mat[i];

              for i:=0 to 15 do
                  bonematrices[32+16+i]:=0;

              //for i:=0 to (4*16)-1 do
              //    writeln(bonematrices[i]);
              glUniformMatrix4fv(fBones, 4, False, @bonematrices[0] );
            end;
    end;


  glBindBuffer(GL_ARRAY_BUFFER, FVBO);
  //glVertexPointer(3, GL_FLOAT, sizeof(TvboVertex), pointer(0)); //vertex
  glEnableVertexAttribArray(fVertexAttribId);
  glVertexAttribPointer(fVertexAttribId,3,GL_FLOAT, GL_FALSE, sizeof(TvboVertex), pointer(0)); //vertex

  if fnormalattribid<>-1 then
     begin
          //glNormalPointer(GL_FLOAT, sizeof(TvboVertex), pointer(sizeof(T3dPoint))); //normal
          glEnableVertexAttribArray(fNormalAttribId); //normal
     end;
  //glVertexAttribPointer(fNormalAttribId,3,GL_FLOAT, GL_FALSE, sizeof(TvboVertex), pointer(sizeof(T3dPoint))); //normal

  //glColorPointer(4, GL_FLOAT, sizeof(TvboVertex), pointer(sizeof(T3dPoint)*2)); //color
  glEnableVertexAttribArray(fColorAttribId);
  glVertexAttribPointer(fColorAttribId,3,GL_FLOAT, GL_FALSE, sizeof(TvboVertex), pointer(sizeof(T3dPoint)*2)); //color

  glEnableVertexAttribArray(fBoneAttribId);
  glVertexAttribPointer(fBoneAttribId,4,GL_FLOAT, GL_FALSE, sizeof(TvboVertex), pointer((sizeof(T3dPoint)*2)+sizeof(TGLColor))); //bone ids
  glEnableVertexAttribArray(fBoneAttribWeight);
  glVertexAttribPointer(fBoneAttribWeight,4,GL_FLOAT, GL_FALSE, sizeof(TvboVertex), pointer((sizeof(T3dPoint)*2)+sizeof(TGLColor)+sizeof(TBoneIdArray))); //bone ids
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, FIBO);

  //glEnableClientState(GL_VERTEX_ARRAY);
  //glEnableClientState(GL_NORMAL_ARRAY);
  //glEnableClientState(GL_COLOR_ARRAY);
  glDrawElements(fDrawStyle, fnumvertexindices, GL_UNSIGNED_SHORT, nil);
  //glDisableClientState(GL_COLOR_ARRAY);
  //glDisableClientState(GL_NORMAL_ARRAY );
  //glDisableClientState(GL_VERTEX_ARRAY);

  glDisableVertexAttribArray(fBoneAttribWeight);
  glDisableVertexAttribArray(fBoneAttribId);
  glDisableVertexAttribArray(fVertexAttribId);
  *)

end;

end.
