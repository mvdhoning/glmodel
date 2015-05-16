unit glvboMesh;

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

//TODO: implement support for bumpmapping

interface

uses classes, dglOpenGl, Mesh;

type
  PVertex = ^TVertex;
  TVertex = record
    U,V,
    NX,NY,NZ,
    X,Y,Z : GLFloat;
  end;

  TglvboMesh = class(TBaseMesh)
  protected
    FVBO: TGluInt;
    FIVBO: array of TGLuInt;
    FIVBOMatId: array of integer;
    FIVBOMatIdCount: array of integer;
    FVBOPointer: PVertex;
    FIVBOPointer: array of PGluShort;
    FCountMatUsed: integer;
    CMatId: array of word;
  public
    destructor Destroy; override;
    procedure Init; override;
    procedure Render; override;
    procedure RenderBoundBox; override;
  end;

implementation

uses Material, glMath, glMatrix, glMaterial, glModel, model;

destructor TglvboMesh.Destroy;
begin
  glDeleteBuffersARB(1, @FVBO); //remove the buffer (from video/main memory)
  glDeleteBuffersARB(FCountMatUsed, @FIVBO);
  inherited;
end;

procedure TglvboMesh.Init;
var
  i,m: Integer;
  matid: Integer;
  id1: Integer;
  v1: array [0..2] of single;
  matrix: clsMatrix;
  f: integer;
  found:boolean;
begin

  //find and count materials used in mesh
  matid:=-1;
  FCountMatUsed:=0;
  f:=0;
  while f <= FNumVertexIndices do
  begin
    if FMatId<>nil then
      matid := FMatId[f div 3];

    //have we found this one before?
    found:=false;
    for i := 0 to FCountMatUsed - 1 do
    begin
      if FIVBOMatId[i]=matid then
      begin
        FIVBOMatIdCount[i]:=FIVBOMatIdCount[i]+3;
        found:=true;
        break; //and exit as we found it...
      end;
    end;

    if not found then
    begin
      //new material
      FCountMatUsed:=FCountMatUsed+1;
      setLength(FIVBOMatId,FCountMatUsed);
      setLength(FIVBOMatIdCount,FCountMatUsed);
      FIVBOMatId[FCountMatUsed-1]:=matid;
      FIVBOMatIdCount[FCountMatUsed-1]:=3;
    end;

    f:=f+3;
  end;

  glGenBuffersARB(1, @FVBO); //create a vertex buffer
  glBindBufferARB(GL_ARRAY_BUFFER_ARB, FVBO); //bind the buffer
  glBufferDataARB(GL_ARRAY_BUFFER_ARB, (FNumVertexIndices)*SizeOf(TVertex), nil, GL_STATIC_DRAW_ARB); //reserve memory

  glEnableClientState( GL_TEXTURE_COORD_ARRAY );
  glEnableClientState( GL_NORMAL_ARRAY );
  glEnableClientState( GL_VERTEX_ARRAY );

  FVBOPointer := glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB); //get a pointer to the vbo

  //copy the vertex data into the vbo buffer
  for i := 0 to (FNumVertexIndices )-1 do
  begin
    FVBOPointer^.U := FMapping[FMappingIndices[i]].tu; //TODO: need to be looked up via indices
    FVBOPointer^.V := FMapping[FMappingIndices[i]].tv;

    FVBOPointer^.NX := FvNormal[FNormalIndices[i]].x; //TODO: need to be looked up via indices
    FVBOPointer^.NY := FvNormal[FNormalIndices[i]].y;
    FVBOPointer^.NZ := FvNormal[FNormalIndices[i]].z;

    //read vertex data for the face
    v1[0] := FVertex[FVertexIndices[i]].x;
    v1[1] := FVertex[FVertexIndices[i]].y;
    v1[2] := FVertex[FVertexIndices[i]].z;

    //if a skeleton is available then ...
    if TBaseModel(owner).NumSkeletons >= 1 then
    begin
      //if there is a bone then apply bone translate etc...
      if TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].NumBones>0 then
        if FBoneId <> nil then
          begin
            id1 := FBoneId[FVertexIndices[i]];
            if id1 <> -1 then
            begin
              matrix := TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[id1].Matrix;
              matrix.rotateVect(v1);
              matrix.translateVect(v1);
            end;
          end;
    end;

    FVBOPointer^.X := v1[0];
    FVBOPointer^.Y := v1[1];
    FVBOPointer^.Z := v1[2];

    if i < (FNumVertexIndices)-1 then
      inc(Cardinal(FVBOPointer), SizeOf(TVertex));

  end;
  glUnMapBufferARB(GL_ARRAY_BUFFER_ARB); //after filling unmap the filled buffer

  //now create indices buffer once for each material
  setLength(FIVBO,FCountMatUsed);
  setLength(FIVBOPointer,FCountMatUsed);

  glGenBuffersARB(FCountMatUsed, @FIVBO[0]);//verwijzen naar eerste element

  for m := 0 to FCountMatUsed - 1 do
  begin
	  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, FIVBO[m] );
	  glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, (FIVBOMatIdCount[m])*sizeof(GLushort), nil, GL_STREAM_DRAW_ARB); //allocate memory on board
    FIVBOPointer[m] := glMapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB); //get pointer to memory on board
    f:=0;
    while f <= FNumVertexIndices do
    begin
    if FMatId<>nil then
      if FIVBOMatId[m]=FMatId[f div 3] then
      begin
        FIVBOPointer[m]^ := f;//upload indices
        inc(Cardinal(FIVBOPointer[m]), SizeOf(TGluShort));
        FIVBOPointer[m]^ := f+1;//upload indices
        inc(Cardinal(FIVBOPointer[m]), SizeOf(TGluShort));
        FIVBOPointer[m]^ := f+2;//upload indices
        inc(Cardinal(FIVBOPointer[m]), SizeOf(TGluShort));
      end;
      f:=f+3;
    end;
	  glUnmapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB);
  end;

  glDisableClientState( GL_VERTEX_ARRAY );
  glDisableClientState( GL_NORMAL_ARRAY );
  glDisableClientState( GL_TEXTURE_COORD_ARRAY );

  // bind with 0, so, switch back to normal pointer operation
  glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
end;

procedure TglvboMesh.Render;
var
  m: integer;
begin
  for m := 0 to FCountMatUsed - 1 do
  begin
    //apply material...
    if FIVBOMatId[m]<>-1 then
      TBaseModel(owner).material[FIVBOMatId[m]].apply;

    //render mesh...
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glEnableClientState( GL_NORMAL_ARRAY );
    glEnableClientState( GL_VERTEX_ARRAY );

    // bind VBOs for vertex array and index array
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, FVBO);          // for vertex coordinates

    glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, FIVBO[m]); // for indices

    //Set Offset Pointer for texcoords, normals and vertices
    glTexCoordPointer( 2, GL_FLOAT, sizeof(TVertex), ptr(0) );
    glNormalPointer( GL_FLOAT, sizeof(TVertex), ptr(2*sizeof(GLFLOAT)+0) );
    glVertexPointer( 3, GL_FLOAT, sizeof(TVertex), ptr((5*sizeof(GLFLOAT))+0) );

    glDrawElements(GL_TRIANGLES, FIVBOMatIdCount[m], GL_UNSIGNED_SHORT, nil);

    glDisableClientState( GL_VERTEX_ARRAY );
    glDisableClientState( GL_NORMAL_ARRAY );
    glDisableClientState( GL_TEXTURE_COORD_ARRAY );

    // bind with 0, so, switch back to normal pointer operation
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
    glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
  end;
end;

procedure TglvboMesh.RenderBoundBox;
begin
  glBegin(GL_LINE_LOOP);
    glVertex3f(minimum.x, minimum.y, minimum.z);
    glVertex3f(maximum.x, minimum.y, minimum.z);
    glVertex3f(maximum.x, maximum.y, minimum.z);
    glVertex3f(minimum.x, maximum.y, minimum.z);
  glEnd;
  glBegin(GL_LINE_LOOP);
    glVertex3f(minimum.x, minimum.y, maximum.z);
    glVertex3f(maximum.x, minimum.y, maximum.z);
    glVertex3f(maximum.x, maximum.y, maximum.z);
    glVertex3f(minimum.x, maximum.y, maximum.z);
  glEnd;
  glBegin(GL_LINES);
    glVertex3f(minimum.x, minimum.y, minimum.z);
    glVertex3f(minimum.x, minimum.y, maximum.z);
    glVertex3f(maximum.x, minimum.y, minimum.z);
    glVertex3f(maximum.x, minimum.y, maximum.z);
    glVertex3f(maximum.x, maximum.y, minimum.z);
    glVertex3f(maximum.x, maximum.y, maximum.z);
    glVertex3f(minimum.x, maximum.y, minimum.z);
    glVertex3f(minimum.x, maximum.y, maximum.z);
  glEnd;
end;

end.