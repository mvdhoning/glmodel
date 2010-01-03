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

 //TODO: render once to new datastructure and use that to fill buffer
 //and indices ... also do sort the new datastructure on vertexindex?

interface

uses classes, dglOpenGl, Mesh, logger, sysutils;

type
  PVertex = ^TVertex;
  TVertex = record
    U,V,
    NX,NY,NZ,
    X,Y,Z : GLFloat; //TODO: extend with u,v,nx,ny,nz
  end;

  TglvboMesh = class(TBaseMesh)
  protected
    FVBO: TGluInt;
    FIVBO: array of TGLuInt;
    FIVBOMatId: array of word;
    FIVBOMatIdCount: array of word;
    FVBOPointer: PVertex;
    FIVBOPointer: array of PGluShort;
    CountMatUsed: integer;
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
  inherited;
end;

procedure TglvboMesh.Init;
var
  i,m,mcount: Integer;
  matid: Integer;
  id1, id2, id3: Integer;
  v1, v2, v3: array [0..2] of single;
  calcv1, calcv2, calcv3: T3dPoint;
  lightv1, lightv2, lightv3: t3dpoint;
  matrix: clsMatrix;
  offset: Single;

  f: integer;
  counter, min, temp, look: integer;

  teller: integer;
begin
  SetLength(CMatId, NumMaterials+1);
  for counter := 0 to NumMaterials do
  begin
    CMatId[counter]:=FMatId[counter];
  end;

  //Sort CMatId
  for counter:=0 to NumMaterials do
  begin
    min:=counter;
    for look:=counter+1 to NumMaterials do
      if CMatID[look]<CMatID[min] then
        min:=look;
      temp:=CMatID[min]; CMatID[min]:=CMatID[counter];
      CMatID[counter]:=temp;
  end;

  matid:=-1;
  for counter:=0 to NumMaterials do
  begin
    if matid <> CMatId[counter] then
    begin
      matid := CMatId[counter];
      CountMatUsed:=CountMatUsed+1;
      setLength(FIVBOMatId,CountMatUsed);
      setLength(FIVBOMatIdCount,CountMatUsed);
      FIVBOMatId[CountMatUsed-1]:=matid;
      FIVBOMatIdCount[CountMatUsed-1]:=1;
    end else
    begin
      FIVBOMatIdCount[CountMatUsed-1]:=FIVBOMatIdCount[CountMatUsed-1]+1;
    end;
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
            id1 := FBoneId[i];
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

  //now create indices buffer one for each material
  setLength(FIVBO,CountMatUsed);
  setLength(FIVBOPointer,CountMatUsed);

  glGenBuffersARB(CountMatUsed, @FIVBO[0]);//verwijzen naar eerste element

  //if countmatused >=2 then
  for m := 0 to CountMatUsed - 1 do
  begin
	  glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, FIVBO[m] );
	  glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, (FIVBOMatIdCount[m])*sizeof(GLushort), nil, GL_STREAM_DRAW_ARB); //allocate memory on board

    log.Writeln('matid['+IntToStr(m)+']: '+IntToStr(FIVBOMatId[m]));
    log.Writeln('matidcount['+IntToStr(m)+']: '+IntToStr(FIVBOMatIdCount[m]));

    //TODO: multiple indices buffer e.g. per material
    FIVBOPointer[m] := glMapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB); //get pointer to memory on board
    f:=0;
    teller:=0;
    while f < FNumVertexIndices do
    begin
      if FIVBOMatId[m]=FMatId[f] then
      begin
        FIVBOPointer[m]^ := f;//upload indices
        inc(Cardinal(FIVBOPointer[m]), SizeOf(TGluShort));
        teller:=teller+1;
      end;
      f:=f+1;
    end;
    log.Writeln('written elements: '+inttostr(teller));
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
  matid: integer;
  m: integer;
begin
  for m := 0 to CountMatUsed - 1 do
  begin
    //apply material...
    TBaseModel(owner).material[m].apply;

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

    glDrawElements(GL_TRIANGLES, FIVBOMatIdCount[m], GL_UNSIGNED_SHORT, 0);

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
