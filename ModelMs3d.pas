unit ModelMs3d;

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
 *  Micronix-TRSI
 *
 *)

interface

uses Classes, Model;

type
  TMs3dModel = class(TBaseModel)
  public
    procedure LoadFromFile(AFileName: string); override;
    procedure LoadFromStream(stream: Tstream); override;
    procedure SaveToFile(AFileName: string); override;
    procedure SaveToStream(stream: TStream); override;
  end;

implementation

uses
  SysUtils, glMath, Skeleton, Mesh, Material, Bone, KeyFrame;

//The milkshape binry reader is inspired by the following example on the pascalgamedev forum:
//https://www.pascalgamedevelopment.com/showthread.php?13405-Milkshape-MS3D-Animation&s=ecd0bb6d00faba1c4b2308fe06b25bc6

//Milkshape 3D file sturcture records
type
  ThreeSingles = array [0..2] of single;
  FourSingles = array [0..3] of single;
  ThreeWords = array [0..2] of word;
  ThreeThreeSingles = array [0..2] of T3dPoint;

  MS3D_Header = packed record
    Id: array [0..9] of char;
    Version: integer
  end;

  MS3D_Vertex = packed record
    Flags: byte;
    Position: T3dpoint;
    BoneID: shortint;
    refCount: byte
  end;

  MS3D_Triangle = packed record
    Flags: word;
    VertexIndices: ThreeWords;
    VertexNormals: ThreeThreeSingles;
    S, T: ThreeSingles;
    SmoothingGroup,
    GroupIndex: byte
  end;

  MS3D_Group = packed record
    Flags: byte;
    Name: array [0..31] of char;
    nTriangles: word;
    TriangleIndices: array of word;
    MaterialIndex: byte
  end;

  MS3D_Material = packed record
    Name: array [0..31] of char;
    Ambient,
    Diffuse,
    Specular,
    Emissive: FourSingles;
    Shininess,
    Transparency: single;
    Mode: byte; //unused!
    Texture,
    Alphamap: array [0..127] of char
  end;

  MS3D_Joint = packed record
    Flags: byte;
    Name,
    ParentName: array [0..31] of char;
    Rotation,
    Translation: T3dPoint;
    nRotKeyframes,
    nTransKeyframes: word
  end;

  MS3D_Keyframe = packed record
    Time: single;
    Parameter: T3dPoint;
  end;

procedure TMs3dModel.LoadFromFile(AFileName: string);
var
  stream: TFilestream;
begin
  FPath := ExtractFilePath(AFilename);
  if FTexturePath = '' then
    FTexturePath := FPath;

  stream := TFilestream.Create(AFilename, $0000);
  LoadFromStream(stream);
  stream.Free;

  // Skeleton will be loaded if available from ModelMs3d
  // maybe later introduce a SkeletonMs3d class

end;

procedure TMs3dModel.LoadFromStream(stream: Tstream);
var
  m, c, c2, i: integer;
  ms3dHeader: MS3D_header;
  ms3dVertex: MS3D_vertex;
  ms3dTriangle: MS3D_Triangle;
  ms3dmaterial: MS3D_Material;
  ms3dJoint      : MS3D_Joint;
  ms3dKeyframe   : MS3D_Keyframe;
  ms3dGroup: MS3D_Group;
  numVertex, numTriangles, numGroups, numMat, numJoints, nTriangles, triangleidx: word;
  AnimFPS        : SINGLE;
  CurrentTime    : SINGLE;
  TotalFrames    : LONGINT;
  tempmap: TMap;
  tempmesh: TBaseMesh;
  s: string;
  p: char;
 tempkeyframe: TKeyFrame;
 ms3dsubversion: word;
 numcomments,commentindex, commentsize: word;
 comment: string;
begin
  //Read Header
  stream.Read(ms3dheader, SizeOf(ms3dheader));

  //First read mesh data into temporary mesh
  tempmesh := FMeshClass.Create(self);
  tempmesh.Name := 'Mesh0';

  //Read vertices
  Stream.Read(numVertex, SizeOf(numVertex));

  tempmesh.numVertex := numVertex;
  for c := 0 to numVertex - 1 do
  begin
    Stream.Read(ms3dvertex, SizeOf(ms3dvertex));
    tempmesh.Vertex[c] := ms3dvertex.Position;
    tempmesh.BoneId[c, 0] := ms3dvertex.BoneID;
  end;

  //Read triangles
  stream.Read(numTriangles, SizeOf(NumTriangles));
  tempmesh.NumVertexIndices := numTriangles * 3;
  tempmesh.NumNormalIndices := numTriangles * 3;
  tempmesh.NumMappingIndices := numTriangles * 3;
  tempmesh.NumMappings := numTriangles * 3;
  tempmesh.NumNormals := numTriangles * 3;
  for c := 0 to NumTriangles - 1 do
  begin

    stream.Read(ms3dtriangle, SizeOf(ms3dtriangle));
    for i := 0 to 2 do
    begin
      //indces
      tempmesh.Face[(c * 3) + i] := ms3dtriangle.VertexIndices[i];
      //mapping
      tempmap := tempmesh.Mapping[(c * 3) + i];
      tempmap.tu := ms3dtriangle.S[i];
      tempmap.tv := 1.0-ms3dtriangle.T[i];
      tempmesh.Map[(c * 3) + i] := (c * 3) + i;
      tempmesh.Mapping[(c * 3) + i] := tempmap;

      //normals
      tempmesh.Normal[(c * 3) + i] := (c * 3) + i;
      tempmesh.Normals[(c * 3) + i] := ms3dtriangle.VertexNormals[i];
    end;

  end;

  //Read Groups (meshes?)
  stream.Read(numGroups, SizeOf(NumGroups));

  FNumMeshes := numGroups;
  SetLength(FMesh, numGroups);
  SetLength(FRenderOrder, numGroups);

  //For each group make a submesh and copy over data form temp mesh
  for c := 0 to NumGroups - 1 do
  begin
    FRenderOrder[c] := c;
    stream.Read(ms3dgroup.flags, SizeOf(ms3dgroup.flags)); //2 byte
    stream.Read(ms3dgroup.Name, SizeOf(ms3dgroup.Name));  //32 byte
    stream.Read(nTriangles, SizeOf(nTriangles));      //2 byte
    //Read all indices at once?
    //setlength(ms3dgroup.TriangleIndices,ntriangles);
    //stream.Read(ms3dgroup.TriangleIndices[0],ntriangles*sizeof(word));
    FMesh[c] := FMeshClass.Create(self);
    FMesh[c].Visible := True;
    Fmesh[c].Name := 'Mesh' + IntToStr(c);

    s := '';
    for i := 0 to high(ms3dgroup.Name) - 1 do
    begin
      p := ms3dgroup.Name[i];
      s := PChar(s + p);
    end;

    FMesh[c].Name := s;

    fmesh[c].Id := c;
    fmesh[c].numVertex := nTriangles * 3;
    fmesh[c].NumVertexIndices := nTriangles * 3;
    fmesh[c].NumNormalIndices := nTriangles * 3;
    fmesh[c].NumMappings := nTriangles * 3;
    fmesh[c].NumMappingIndices := nTriangles * 3;
    fmesh[c].NumNormals := nTriangles * 3;


    for c2 := 0 to nTriangles - 1 do
    begin
      stream.Read(triangleidx, SizeOf(triangleidx)); //read per indice
      //triangleidx:=ms3dgroup.TriangleIndices[c2]; //read pre read indices
      for i := 0 to 2 do
      begin
        //indces
        fMesh[c].Face[(c2 * 3) + i] := (c2 * 3 + i);
        //vertices
        fmesh[c].Vertex[(c2 * 3) + i] := tempmesh.Vertex[tempmesh.Face[(triangleidx * 3) + i]];
        //bone id
        fmesh[c].BoneId[(c2 * 3) + i, 0] := tempmesh.BoneId[tempmesh.Face[(triangleidx * 3) + i], 0];
        fmesh[c].BoneWeight[(c2 * 3) + i, 0] := 1.0; //with only one bone set weight to 1.0
        //mapping
        fMesh[c].map[(c2 * 3) + i] :=(c2 * 3 + i);
        fMesh[c].Mapping[(c2 * 3) + i] := tempmesh.Mapping[tempmesh.map[(triangleidx * 3) + i]];
        //normals
        fmesh[c].Normal[(c2 * 3) + i] := (c2 * 3 + i);
        fMesh[c].Normals[(c2 * 3) + i] := tempmesh.Normals[tempmesh.Normal[(triangleidx * 3) + i]];
      end; //for begin i
    end; //for begin c2

    stream.Read(ms3dgroup.materialIndex, SizeOf(ms3dgroup.materialIndex));  //2 byte
    fMesh[c].MatId[0] := ms3dgroup.materialIndex;
    fMesh[c].MatName[0] := '';

    //setlength(ms3dgroup.TriangleIndices,0); //cleanup memory no longer needed
  end;

  //temp mesh data is no longer needed
  tempmesh.Free;

  //Read Materials
  stream.Read ( numMat, SizeOf ( numMat ) );
  setlength(FMaterial, numMat );
  FNumMaterials := numMat;
  for c := 0 to NumMaterials - 1 do
  begin
    stream.Read ( ms3dmaterial, SizeOf ( ms3dmaterial ) );
    FMaterial[c] := FMaterialClass.Create(self);
    FMaterial[c].Name:=ms3dMaterial.Name;
    FMaterial[c].AmbientRed:=ms3dMaterial.Ambient[0];
    FMaterial[c].AmbientGreen:=ms3dMaterial.Ambient[1];
    FMaterial[c].AmbientBlue:=ms3dMaterial.Ambient[2];
    FMaterial[c].DiffuseRed:=ms3dMaterial.Diffuse[0];
    FMaterial[c].DiffuseGreen:=ms3dMaterial.Diffuse[1];
    FMaterial[c].DiffuseBlue:=ms3dMaterial.Diffuse[2];
    FMaterial[c].SpecularRed:=ms3dMaterial.Specular[0];
    FMaterial[c].SpecularGreen:=ms3dMaterial.Specular[1];
    FMaterial[c].SpecularBlue:=ms3dMaterial.Specular[2];
    FMaterial[c].EmissiveRed:=ms3dMaterial.Emissive[0];
    FMaterial[c].EmissiveGreen:=ms3dMaterial.Emissive[1];
    FMaterial[c].EmissiveBlue:=ms3dMaterial.Emissive[2];
    FMaterial[c].Shininess:=ms3dMaterial.Shininess;
    FMaterial[c].Transparency:=ms3dMaterial.Transparency;
    FMaterial[c].TextureFilename:=ms3dmaterial.texture;
    if FMaterial[c].TextureFilename <> '' then
      FMaterial[c].Hastexturemap := True;
  end;

  //Read Bones
  stream.Read ( AnimFPS, SizeOf ( AnimFPS ) );
  stream.Read ( CurrentTime, SizeOf ( CurrentTime ) );
  stream.Read ( TotalFrames, SizeOf ( TotalFrames ) );
  stream.Read ( numJoints, SizeOf ( NumJoints ) );

  if numJoints > 0 then
    begin
      fnumskeletons:=1;
      setlength(fskeleton, fnumskeletons);
      fskeleton[0]:=FSkeletonClass.Create(self);
      fskeleton[0].Animation[0].NumFrames:=TotalFrames;
      fskeleton[0].Animation[0].AnimFps:=AnimFPS;
      fskeleton[0].Animation[0].CurrentFrame:=1;

      for c := 0 to numJoints - 1 do
      begin
        stream.Read(ms3dJoint,SizeOf(ms3dJoint));
        fskeleton[0].AddBone;
        fskeleton[0].Bone[c].Name:=ms3dJoint.Name;

        fskeleton[0].Bone[c].Rotate := ms3dJoint.Rotation;
        fskeleton[0].Bone[c].Translate := ms3dJoint.Translation;
        fskeleton[0].Bone[c].ParentName:= ms3dJoint.ParentName;
        fskeleton[0].Bone[c].Animation[0].NumRotateFrames := ms3dJoint.nRotKeyframes;
        fskeleton[0].Bone[c].Animation[0].NumTranslateFrames := ms3dJoint.nTransKeyframes;

        //skip animation info
        //stream.Position := stream.Position + SizeOf ( ms3dKeyframe ) * ( ms3dJoint.nRotKeyframes + ms3dJoint.nTransKeyframes );

        //read animation data
        for c2 := 0 to ms3dJoint.nRotKeyframes - 1 do
        begin
          stream.Read(ms3dKeyframe,sizeof(ms3dKeyframe));
          tempkeyframe := fskeleton[0].Bone[c].Animation[0].RotateFrame[c2];
          tempkeyframe.time := ms3dKeyframe.Time*fskeleton[0].Animation[0].AnimFps;
          tempkeyframe.Value.x := ms3dKeyframe.Parameter.x;
          tempkeyframe.Value.y := ms3dKeyframe.Parameter.y;
          tempkeyframe.Value.z := ms3dKeyframe.Parameter.z;
          fskeleton[0].Bone[c].Animation[0].RotateFrame[c2] := tempkeyframe;
        end;

        for c2 := 0 to ms3dJoint.nTransKeyframes - 1 do
        begin
          stream.Read(ms3dKeyframe,sizeof(ms3dKeyframe));
          tempkeyframe := fskeleton[0].Bone[c].Animation[0].TranslateFrame[c2];
          tempkeyframe.time := ms3dKeyframe.Time*fskeleton[0].Animation[0].AnimFps;
          tempkeyframe.Value.x := ms3dKeyframe.Parameter.x;
          tempkeyframe.Value.y := ms3dKeyframe.Parameter.y;
          tempkeyframe.Value.z := ms3dKeyframe.Parameter.z;
          fskeleton[0].Bone[c].Animation[0].TranslateFrame[c2] := tempkeyframe;
        end;

      end;

    end;

  //read additional info from file if not end of file
  (*
  if stream.Position < stream.Size then
    begin
      writeln('check for comments');
      stream.Read(ms3dsubversion,sizeof(ms3dsubversion));
      writeln(ms3dsubversion);
      if ms3dsubversion=1 then
        begin
          writeln('comments');
          //read group comments
          stream.Read(numComments,sizeof(numComments));
          writeln(numComments);
          for i:=0 to numComments-1 do
          begin
            writeln('group');
            //index
            stream.Read(commentindex,sizeof(commentindex));
            //commentsize
            stream.Read(commentsize,sizeof(commentsize));
            //comment
            SetLength(comment,commentsize);
            stream.Read(comment,sizeof(commentsize));
            writeln(comment);
          end;
          //read material comments
          stream.Read(numComments,sizeof(numComments));
          writeln(numComments);
          //read joint comments
          stream.Read(numComments,sizeof(numComments));
          writeln(numComments);
          //read model
          stream.Read(numComments,sizeof(numComments));
          writeln(numComments);
        end;
    end;

  //read vertex info is still not end of file

  //can have 2 subersions

  //for each vertex in model there is the following extra data
  //1: 3 bone id's, 3 weights
  //2: 3 bone id's, 3 weights, extra
  //with the already read bone id that makes 4 bones pers vertice

  if stream.Position < stream.Size then
  begin
    writeln('check for extra vertex info');
    stream.Read(ms3dsubversion,sizeof(ms3dsubversion));
    writeln(ms3dsubversion);
    if ms3dsubversion=1 then
      begin
      end;
  end;

  //read extra joint info from file if not end of file
  //one subversion known
  //for each join
  //1: color
  if stream.Position < stream.Size then
  begin
    writeln('check for extra joint info');
    stream.Read(ms3dsubversion,sizeof(ms3dsubversion));
    writeln(ms3dsubversion);
    if ms3dsubversion=1 then
      begin
      end;
  end;

  //read extra model info from file if not end of file
  //one subversion knwon
  //1: jointsize, transparenency mode, alpharef
  if stream.Position < stream.Size then
  begin
    writeln('check for extra model info');
    stream.Read(ms3dsubversion,sizeof(ms3dsubversion));
    writeln(ms3dsubversion);
    if ms3dsubversion=1 then
      begin
      end;
  end;
  *)

  //fill matnames into meshes
  If FnumMeshes > 0 then
  for m:= 0 to FNumMeshes -1 do
  begin
    if (fMesh[m].MatId[0]<>255)  then
    begin
      FMesh[m].MatName[0] := FMaterial[fMesh[m].MatId[0]].Name;
    end;
  end;

end;

procedure TMs3dModel.SaveToFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, fmCreate);
  SaveToStream(stream);
  stream.Free;
end;

procedure TMs3dModel.SaveToStream(stream: Tstream);
begin
  //TODO: write export code for ms3d binary format
end;

initialization
  RegisterModelFormat('ms3d', 'Milkshape 3D binary model', TMs3dModel);

finalization
  UnRegisterModelClass(TMs3dModel);

end.
