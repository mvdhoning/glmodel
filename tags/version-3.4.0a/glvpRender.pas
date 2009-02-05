unit glvpRender;

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

 //Example implementation not complete only renders 1st mesh of 1st model

interface

uses classes, model, render, dglopengl, glmodel, glmesh, glmaterial, glskeleton;

type
  PVertex = ^TVertex;
  TVertex = packed record
    X,Y,Z : TGLFloat;
  end;

type TglvpRender = class(TBaseRender)
  protected
    FVBO: TGluInt;
    FIVBO: TGLuInt;
    FVBOPointer: PVertex;
    FIVBOPointer: PGluShort;
    FVP: TGluInt;
    procedure CreateVertexBufferObject;
    procedure CreateIndexedVertexBufferObject;
    procedure DestroyVertexBufferObject;
    procedure RenderVertexBufferObject;
    procedure InitializeVertexProgram;
    procedure RenderVertexBufferObjectUsingVertexProgram;
  public
    destructor Destroy; override;
    procedure AddModel(Value: TBaseModel); overload; override;
    procedure AddModel; overload; override;
    procedure Render; override;
    procedure Init; override;
end;

implementation

procedure TglvpRender.Init;
begin
  CreateIndexedVertexBufferObject;
end;

procedure TglvpRender.AddModel(Value: TBaseModel);
begin
  inherited;

  Models[FNumModels-1].MeshClass := TGLMesh;
  Models[FNumModels-1].MaterialClass := TGLMaterial;
  Models[FNumModels-1].SkeletonClass := TGLSkeleton;
end;

procedure TglvpRender.AddModel;
begin
  AddModel(TGlModel.Create(self));
end;

destructor TglvpRender.Destroy;
var
  I: Integer;
begin
  DestroyVertexBufferObject;
  inherited;
end;

procedure TglvpRender.Render;
var
  I: Integer;
begin
  RenderVertexBufferObjectUsingVertexProgram;
end;

procedure TglvpRender.CreateVertexBufferObject;
var
  i: integer;
begin
  glEnableClientState(GL_VERTEX_ARRAY); //enable the buffer
  glGenBuffersARB(1, @FVBO); //create a vertex buffer
  glBindBufferARB(GL_ARRAY_BUFFER_ARB, FVBO); //bind the buffer
  glBufferDataARB(GL_ARRAY_BUFFER_ARB, (FModels[0].Mesh[0].NumVertexIndices)*SizeOf(TVertex), nil, GL_STATIC_DRAW_ARB); //reserve memory
  FVBOPointer := glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB); //get a pointer to the vbo

  //copy the vertex data into the vbo buffer
  for i := 0 to (FModels[0].Mesh[0].NumVertexIndices)-1 do
  begin
    FVBOPointer^.X := FModels[0].Mesh[0].Vertex[FModels[0].Mesh[0].Face[i]].x;
    FVBOPointer^.Y := FModels[0].Mesh[0].Vertex[FModels[0].Mesh[0].Face[i]].y;
    FVBOPointer^.Z := FModels[0].Mesh[0].Vertex[FModels[0].Mesh[0].Face[i]].z;
    if i < (FModels[0].Mesh[0].NumVertexIndices)-1 then
      inc(Cardinal(FVBOPointer), SizeOf(TVertex));
  end;

  glUnMapBufferARB(GL_ARRAY_BUFFER_ARB); //after filling unmap the filled buffer
end;

procedure TglvpRender.CreateIndexedVertexBufferObject;
var
  i: integer;
begin
  glEnableClientState(GL_VERTEX_ARRAY); //enable the buffer
  glGenBuffersARB(1, @FVBO); //create a vertex buffer
  glBindBufferARB(GL_ARRAY_BUFFER_ARB, FVBO); //bind the buffer
  glBufferDataARB(GL_ARRAY_BUFFER_ARB, (FModels[0].Mesh[0].NumVertex)*SizeOf(TVertex), nil, GL_STATIC_DRAW_ARB); //reserve memory
  FVBOPointer := glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB); //get a pointer to the vbo

  //copy the vertex data into the vbo buffer
  for i := 0 to (FModels[0].Mesh[0].NumVertex )-1 do
  begin
    FVBOPointer^.X := FModels[0].Mesh[0].Vertex[i].x;
    FVBOPointer^.Y := FModels[0].Mesh[0].Vertex[i].y;
    FVBOPointer^.Z := FModels[0].Mesh[0].Vertex[i].z;
    if i < (FModels[0].Mesh[0].NumVertexIndices)-1 then
      inc(Cardinal(FVBOPointer), SizeOf(TVertex));
  end;

  glUnMapBufferARB(GL_ARRAY_BUFFER_ARB); //after filling unmap the filled buffer

  //now create indices buffer
  glGenBuffersARB(1, @FIVBO);
	glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, FIVBO);
	glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, (FModels[0].Mesh[0].NumVertexIndices)*sizeof(GLushort), nil, GL_STREAM_DRAW_ARB); //allocate memory on board

	FIVBOPointer := glMapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB); //get pointer to memory on board
	for i:= 0 to (FModels[0].Mesh[0].NumVertexIndices)-1 do
  begin
    FIVBOPointer^ := FModels[0].Mesh[0].Face[i]; //upload indices
    inc(Cardinal(FIVBOPointer), SizeOf(TGluShort));
  end;

	glUnmapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB);
end;

procedure TglvpRender.DestroyVertexBufferObject;
begin
glDeleteBuffersARB(1, @FVBO); //remove the buffer (from video/main memory)
end;

procedure TglvpRender.RenderVertexBufferObject;
begin
  //normal render
  //glInterleavedArrays(GL_V3F, SizeOf(TVertex), nil);
  //glDrawArrays(GL_TRIANGLES, 0, FModels[0].Mesh[0].NumFaces );

  //indexed render
  glVertexPointer(3, GL_FLOAT, 0, nil);
  glDrawElements(GL_TRIANGLES, FModels[0].Mesh[0].NumVertexIndices, GL_UNSIGNED_SHORT, 0);
end;

procedure TglvpRender.InitializeVertexProgram;
var
  programstring: pchar;
  arbprogramfile: TStringList;
begin
  //Load the vertex program from textfile to pchar
  arbprogramfile := TStringList.Create;
  arbprogramfile.LoadFromFile('vp1.txt');
  programstring := pchar(arbprogramfile.text);
  arbprogramfile.Free;

  //generate vertex program
  glEnable(GL_VERTEX_PROGRAM_ARB);
  glGenProgramsARB(1, @FVP);
  glBindProgramARB(GL_VERTEX_PROGRAM_ARB, FVP);
  glProgramStringARB(GL_VERTEX_PROGRAM_ARB, GL_PROGRAM_FORMAT_ASCII_ARB, length(programstring), programstring);

  //errorstring := glGetString(GL_PROGRAM_ERROR_STRING_ARB); //check for errors
end;

procedure TglvpRender.RenderVertexBufferObjectUsingVertexProgram;
begin
  //glBindProgramARB(GL_VERTEX_PROGRAM_ARB, FVP);
  //glEnable(GL_VERTEX_PROGRAM_ARB);
  RenderVertexBufferObject;
  //glDisable(GL_VERTEX_PROGRAM_ARB);
end;

end.
