unit glMesh;

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
 *  Sascha Willems
 *  Jan Michalowsky
 *
 *)

interface

uses classes, Mesh;

type
    TglMesh = class(TBaseMesh)
    public
      procedure Render; override;
      procedure RenderBoundBox; override;
    end;

    //TODO: fix texturing
    //TODO: fix bumpmapping

implementation

uses dglOpenGl, Material, glMath, glMatrix, glMaterial, glModel, model;

procedure TglMesh.Render;
var
  f: Integer;
  matid: Integer;
  id1, id2, id3: Integer;
  v1, v2, v3: array [0..2] of single;
  calcv1, calcv2, calcv3: T3dPoint;
  lightv1, lightv2, lightv3: t3dpoint;
  matrix: clsMatrix;
  offset: Single;

  //bumpmapping strength

begin

   // glpushmatrix();



   //gltranslatef(FMatrix[3],FMatrix[7],FMatrix[11]);


   //glrotatef(FMatrix[0],1,0,0);
   //glrotatef(FMatrix[5],0,1,0);
   //glrotatef(FMatrix[10],0,0,1);

   //glmultmatrixf(@FMatrix);

   //glLoadMatrixf(@FMatrix);

  //if fdisplaylist<>0
  //then glcalllist(fdisplaylist)
  //else
  //begin
    matid := 999; //hmm since material now starts with 0 this has to be higher...
    glpushmatrix();
    if NumVertexIndices > 0 then
    begin
      f := 0;
      while f < NumVertexIndices - 1 do
      begin
          //set the id for picking
        //if pickmesh then
         // glColor3f((Fid and $FF)/255,((Fid shr 8) and $FF)/255,((Fid shr 16)and $FF)/255);
        //if pickface then
        //  glColor3f(((f div 3) and $FF)/255,(((f div 3) shr 8) and $FF)/255,(((f div 3) shr 16)and $FF)/255);

          //begin setting material
          //only set material if different from previous

          //TODO: Wrong material is assigned....


        if FMatId<>nil then
//        if FMatId[0] >= 0 then //does this always evaluate to true?
//        begin
          if FMatId[f div 3] <> matid then
          begin
            matid := FMatId[f div 3];
            if matid > -1 then
            //if not ambientmode then
             if (TBaseModel(owner).material[matid] is TBaseMaterial) then
               TBaseModel(owner).material[matid].apply;

             //with TBaseModel(owner).material[matid] as TglMaterial do
             //begin
             //   Apply;
             //end;

          end;
            //end setting material
//        end;


          //read vertex data for the face
  (*        v1[0] := FVertex[FIndices[f]].x;
          v1[1] := FVertex[FIndices[f]].y;
          v1[2] := FVertex[FIndices[f]].z;

          v2[0] := FVertex[FIndices[f + 1]].x;
          v2[1] := FVertex[FIndices[f + 1]].y;
         v2[2] := FVertex[FIndices[f + 1]].z;

          v3[0] := FVertex[FIndices[f + 2]].x;
          v3[1] := FVertex[FIndices[f + 2]].y;
          v3[2] := FVertex[FIndices[f + 2]].z; *)
          // the new way
          //DONE: FFaces contains wrong DATA!!!!



        //v1[0] := FVertex[FFaces[f div 3].Vertex[0]].x;
        //v1[1] := FVertex[FFaces[f div 3].Vertex[0]].y;
        //v1[2] := FVertex[FFaces[f div 3].Vertex[0]].z;

        //v2[0] := FVertex[FFaces[f div 3].Vertex[1]].x;
        //v2[1] := FVertex[FFaces[f div 3].Vertex[1]].y;
        //v2[2] := FVertex[FFaces[f div 3].Vertex[1]].z;

        //v3[0] := FVertex[FFaces[f div 3].Vertex[2]].x;
        //v3[1] := FVertex[FFaces[f div 3].Vertex[2]].y;
        //v3[2] := FVertex[FFaces[f div 3].Vertex[2]].z;

        v1[0] := FVertex[FVertexIndices[f]].x;
        v1[1] := FVertex[FVertexIndices[f]].y;
        v1[2] := FVertex[FVertexIndices[f]].z;

        v2[0] := FVertex[FVertexIndices[f+1]].x;
        v2[1] := FVertex[FVertexIndices[f+1]].y;
        v2[2] := FVertex[FVertexIndices[f+1]].z;

        v3[0] := FVertex[FVertexIndices[f+2]].x;
        v3[1] := FVertex[FVertexIndices[f+2]].y;
        v3[2] := FVertex[FVertexIndices[f+2]].z;


          //     id1:=0;
          //     id2:=0;
          //     id3:=0;

          //if a skeleton is available then ...


          //TODO: move this to base mesh?
          if TBaseModel(owner).NumSkeletons >= 1 then

        //if TModel(owner).Skeleton[0]<>nil then
          //if there is a bone then apply bone translate etc...
        if TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].NumBones>0 then
        if FBoneId <> nil then
        begin
          id1 := FBoneId[FVertexIndices[f]] ;
          id2 := FBoneId[FVertexIndices[f + 1]] ;
          id3 := FBoneId[FVertexIndices[f + 2]] ;

          if id1 <> -1 then
          begin
            matrix := TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[id1].Matrix;
            matrix.rotateVect(v1);
            matrix.translateVect(v1);
          end;

          if id2 <> -1 then
          begin
            matrix := TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[id2].Matrix;
            matrix.rotateVect(v2);
            matrix.translateVect(v2);
          end;

          if id3 <> -1 then
          begin
            matrix := TBaseModel(owner).Skeleton[TBaseModel(owner).CurrentSkeleton].Bone[id3].Matrix;
            matrix.rotateVect(v3);
            matrix.translateVect(v3);
          end;

        end;


        offset:=0;
        if FMatId<>nil then
        If TBaseModel(owner).material[matid].Hasbumpmap then
        begin
            //calculate bumpmapping
          Calcv1.x := V1[0];
          Calcv1.y := V1[1];
          Calcv1.z := V1[2];
          Calcv2.x := V2[0];
          Calcv2.y := V2[1];
          Calcv2.z := V2[2];
          Calcv3.x := V3[0];
          Calcv3.y := V3[1];
          Calcv3.z := V3[2];

            //think about calculating this only once...
       //   LightV1 := VectorSubtract(ObjLightPos,CalcV1);
       //   LightV1 := Normalize(LightV1);
       //   LightV2 := VectorSubtract(ObjLightPos,CalcV2);
       //   LightV2 := Normalize(LightV2);
       //   LightV3 := VectorSubtract(ObjLightPos,CalcV3);
       //   LightV3 := Normalize(LightV3);

          offset:=TBaseModel(owner).Material[matid].BumpmapStrength;
        end
        else
        begin
            //no bumpmapping
          LightV1.x:=0;
          LightV1.y:=0;
          LightV1.z:=0;
          LightV2.x:=0;
          LightV2.y:=0;
          LightV2.z:=0;
          LightV3.x:=0;
          LightV3.y:=0;
          LightV3.z:=0;
          offset:=0;
        end;


         //DONE: Normals are wrong WHERE loading calculating modifying?

          //render the face
        glbegin(GL_TRIANGLES);
        if FNumNormals >=1 then glNormal3fv(@FVnormal[FNormalIndices[f]]);
        glMultiTexCoord2f(GL_TEXTURE0,FMapping[FMappingIndices[f]].tu, FMapping[FMappingIndices[f]].tv);
        glMultiTexCoord2f(GL_TEXTURE1,FMapping[FMappingIndices[f]].tu + (lightv1.x*offset), FMapping[FMappingIndices[f]].tv + (lightv1.y*offset));
        //if pickvertex then
        //  glColor3f((f and $FF)/255,((F shr 8) and $FF)/255,((f shr 16)and $FF)/255);
        glVertex3fv(@v1);

        if FNumNormals >=1 then glNormal3fv(@FVnormal[FNormalIndices[f + 1]]);
        glMultiTexCoord2f(GL_TEXTURE0,FMapping[FMappingIndices[f + 1]].tu, FMapping[FMappingIndices[f + 1]].tv);
        glMultiTexCoord2f(GL_TEXTURE1,FMapping[FMappingIndices[f + 1]].tu + (lightv2.x*offset), FMapping[FMappingIndices[f + 1]].tv + (lightv2.y*offset));
        //if pickvertex then
        //  glColor3f(((f+1) and $FF)/255,(((f+1) shr 8) and $FF)/255,(((f+1) shr 16)and $FF)/255);
        glVertex3fv(@v2);

        if FNumNormals >=1 then glNormal3fv(@FVnormal[FNormalIndices[f + 2]]);
        glMultiTexCoord2f(GL_TEXTURE0,FMapping[FMappingIndices[f + 2]].tu, FMapping[FMappingIndices[f + 2]].tv);
        glMultiTexCoord2f(GL_TEXTURE1,FMapping[FMappingIndices[f + 2]].tu + (lightv3.x*offset), FMapping[FMappingIndices[f + 2]].tv + (lightv3.y*offset));
        //if pickvertex then
        //  glColor3f(((f+2) and $FF)/255,(((f+2) shr 8) and $FF)/255,(((f+2) shr 16)and $FF)/255);
        glVertex3fv(@v3);

        glend;

        f := f + 3;
      end;
      //glpopmatrix();
    end;
    glpopmatrix();
    //end;
  //end;

end;

procedure TglMesh.RenderBoundBox;
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
