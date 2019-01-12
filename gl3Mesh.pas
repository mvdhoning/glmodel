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

uses classes, dglOpenGl, Mesh, glMath;

type

  TVBOVertex = packed record
    Position: T3dPoint;
    Normal: T3dPoint;
    Color: TGLColor;
  end;

  TVBOBuffer = array of TVBOVertex;

  Tgl3Mesh = class(TBaseMesh)
  protected
     FIBO: GLuint;
     FVBO: GLuint;
     FvboBuffer: TvboBuffer;
     FvboIndices: array of word;
  public
    destructor Destroy; override;
    procedure Init; override;
    procedure Render; override;
  end;

implementation

uses Material, glMatrix, glMaterial, glModel, model;

destructor Tgl3Mesh.Destroy;
begin
  glDeleteBuffersARB(1, @FVBO); //remove the buffer (from video/main memory)
  glDeleteBuffersARB(1, @FIBO);
  setLength(fvboBuffer,0); //remove the vbo buffer
  inherited;
end;

procedure Tgl3Mesh.Init;
var
  i: integer;
begin
  // fill the vbo buffer with vertices and colors and normals (and uv tex coords)
  setlength(FVBOBuffer, fNumVertexIndices);
  for i:=0 to fnumvertexindices-1 do
  begin
    fVboBuffer[i].Position:=FVertex[FVertexIndices[i]];
    fVboBuffer[i].Normal:=FvNormal[FNormalIndices[i]];
    fVboBuffer[i].Color.red:=TBaseModel(owner).material[fmatid[i div 3]].DiffuseRed;
    fVboBuffer[i].Color.green:=TBaseModel(owner).material[fmatid[i div 3]].DiffuseGreen;
    fVboBuffer[i].Color.blue:=TBaseModel(owner).material[fmatid[i div 3]].DiffuseBlue;
    fVboBuffer[i].Color.alpha:=1.0;
  end;
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
begin
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

  glBindBuffer(GL_ARRAY_BUFFER, FVBO);
  glVertexPointer(3, GL_FLOAT, sizeof(TvboVertex), pointer(0));
  glNormalPointer(GL_FLOAT, sizeof(TvboVertex), pointer(sizeof(T3dPoint)));
  glColorPointer(4, GL_FLOAT, sizeof(TvboVertex), pointer(sizeof(T3dPoint)*2));
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, FIBO);

  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glDrawElements(GL_TRIANGLES, fnumvertexindices, GL_UNSIGNED_SHORT, nil);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY );
  glDisableClientState(GL_VERTEX_ARRAY);
end;

end.
