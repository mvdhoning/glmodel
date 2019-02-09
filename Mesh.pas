unit Mesh;

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

uses classes, glmatrix, glmath, Material;

type
  //texturemapping coords
  TMap = packed record
    tu: Single;
    tv: Single;
  end;

  //TODO: continue splitting up normal vertex and (texture)mapping (indices)
  //TODO: enable texturemapping indices in 3ds and msa

  //TODO: Enable face structure again make this a virtual mapping...
  //face structure (one triangle)
//  TFace = packed record
//    vertex: array [0..2] of word; //rewrite to xyz
//    normal: array [0..2] of word; //rewrite to xyz
    //texmap
//    neighbour: array [0..2] of word;
//    plane: TPlaneEq;
//    visible: Boolean;
//  end;

  //mesh data

  TBoneIdArray = array [0..3] of single;

  TBaseMesh = class;

  TBaseMeshClass = class of TBaseMesh;

  TBaseMesh = class(TComponent)
  protected
    FMatrix: array of Single;
    FVisible: boolean;

    FId: Integer;

    Fmatid: array of word;
    Fmatname: array of string;
    FMaximum: T3dPoint;
    FMinimum: T3dPoint;
    FName: string;

    FVertexIndices: array of word;
    FNormalIndices: array of word;
    FMappingIndices: array of word;
    fBoneIndices: array of TBoneIdArray;
    fBoneWeights: array of TBoneIdArray;

    FNumVertexIndices: Integer;
    FNumVertex: Integer;
    FNumNormals: Integer;
    FNumNormalIndices: Integer;
    FNumMappings: Integer;
    FNumMappingIndices: Integer;
    FNumFaces: Integer;


    Fpivot: T3DPoint;
    FShadDisplayList: Integer;

    Fvertex: array of T3dpoint;
    Fvnormal: array of T3dPoint;
    Fmapping: array of TMap;
    fNumBones: integer;
    //fBoneId: TBoneIdArray; //array of bone id that can incluence a single vertex

    function GetBoneWeight(VertexIndex, WeightIndex: integer): single;
    procedure SetBoneWeight(VertexIndex, WeightIndex: integer; aValue: single);

    function GetVertexIndex(Index: integer): Word;
    procedure SetVertexIndex(Index: integer; Value: Word);
    function GetMap(Index: integer): Word;
    procedure SetMap(Index: integer; Value: Word);
    function GetFace(Index: integer): Word;
    procedure SetFace(Index: integer; Value: Word);
    function GetNormal(Index: integer): Word;
    procedure SetNormal(Index: integer; Value: Word);
    function GetBoneId(VertexIndex, BoneIndex: integer): single;
 //   function GetFaces(Index: integer): TFace;
 //   procedure SetFaces(Index: integer; Value: TFace);
    function GetMapping(Index: integer): TMap;
    function GetMatID(Index: integer): Word;
    procedure SetMatID(Index: integer; Value: Word);
    function GetNormals(Index: integer): T3dPoint;
    procedure SetNormals(Index: integer; Value: T3dPoint);
    function GetVertex(Index: integer): T3dPoint;
    procedure SetVertex(Index: integer; Value: T3dPoint);
    procedure SetMapping(Index: integer; Value: TMap);
    procedure SetNumberOfVertex(Value: Integer);
    procedure SetNumberOfIndices(Value: Integer);
    procedure SetNumberOfNormals(Value: Integer);
    procedure SetNumberOfNormalIndices(Value: Integer);
//    procedure SetNumberOfFaces(Value: Integer);
    procedure SetNumberOfMappings(Value: Integer);
    procedure SetNumberOfMappingIndices(Value: Integer);

    procedure SetBoneId(VertexIndex, BoneIndex: integer; aValue: single);
    function GetMatName(Index: integer): string;
    procedure SetMatName(Index: integer; Value: string);
    function GetValFromMatrix(Index: integer): Single;
    procedure SetValInMatrix(Index: integer; Value: Single);
    function GetNumMaterials: integer;
    function GetNumBones(): integer;
    procedure SetNumBones(aValue: integer);
  public
    destructor Destroy; override;
    procedure Init; virtual; abstract;
    procedure Render; virtual; abstract;
    procedure RenderBoundBox; virtual; abstract;
    procedure Assign(Source: TPersistent); override;
    procedure CalculateSize;
    procedure CalculateNormals;
    procedure AddFace(v1, v2, v3: T3DPoint; fmaterial: TBaseMaterial);
    property Visible: boolean read FVisible write FVisible;
    property Face[Index: integer]: Word read GetFace write SetFace;
    property Normal[Index: integer]: Word read GetNormal write SetNormal;
    property Map[Index: integer]: Word read GetMap write SetMap;
    //property Faces[Index: integer]: TFace read GetFaces write SetFaces;
    property MatName[Index: integer]: string read GetMatName write SetMatName;
    property BoneId[VertexIndex, BoneIndex: integer]: single read GetBoneId write SetBoneId;
    property BoneWeight[VertexIndex, WeightIndex: integer]: single read GetBoneWeight write SetBoneWeight;
    property Id: Integer read FId write FId;
    property Mapping[Index: integer]: TMap read GetMapping write SetMapping;
    property MatID[Index: integer]: Word read GetMatID write SetMatId;
    property Maximum: T3dPoint read FMaximum;
    property Minimum: T3dPoint read FMinimum;
    property Name: string read FName write FName;
    property Normals[Index: integer]: T3dPoint read GetNormals write SetNormals;

    property NumVertexIndices: Integer read FNumVertexIndices write SetNumberOfIndices;
    property NumVertex: Integer read FNumVertex write SetNumberOfVertex;

    property NumNormals: Integer read FNumNormals write SetNumberofNormals;
    property NumNormalIndices: Integer read FNumNormalIndices write SetNumberOfNormalIndices;

    property NumMappingIndices: Integer read FNumMappingIndices write SetNumberOfMappingIndices;
    property NumMappings: Integer read FNumMappings write SetNumberofMappings;

    property NumMaterials: Integer read GetNumMaterials;
    property NumBones: Integer read GetNumBones write SetNumBones; //number of bones that can influence a vertex in a mesh

    //    property NumFaceRecords: Integer read FNumFaces write SetNumberOfFaces;
    property Vertex[Index: integer]: T3dPoint read GetVertex write SetVertex;
    property VertexIndices[Index: integer]: Word read GetVertexIndex write SetVertexIndex;
    property Pivot: T3dPoint read FPivot write FPivot; //TODO: move to 3ds only?
    property Matrix[Index: integer]: Single read GetValFromMatrix write SetValInMatrix; //TODO: move to 3ds only?
  end;

  //TMesh = class(TBaseMesh)
  //end;

implementation

uses
  SysUtils;

function TBaseMesh.GetNumMaterials: integer;
begin
  if FMatId = nil then result:=0 else result:=High(FMatId);
end;

function TBaseMesh.GetNumBones: integer;
begin
  result := fnumbones;
end;

procedure TBaseMesh.SetNumBones(AValue: integer);
begin
  fnumbones:=aValue;
end;

destructor TBaseMesh.Destroy;
begin
  FName := '';
  SetLength(FVertex, 0);
  SetLength(FMatName, 0);
  SetLength(FVnormal, 0);
  SetLength(FMapping, 0);
  SetLength(FMatId, 1); //minimale lengte op 1 entry zetten????
  SetLength(FVertexIndices, 0);
  Setlength(FNormalIndices, 0);
  Setlength(FMappingIndices,0);
  //SetLength(FBoneId, 0);
  SetLength(FBoneIndices, 0);
  SetLength(FBoneWeights, 0);
  FVertex := nil;
  FMatName := nil;
  FVnormal := nil;
  FMapping := nil;
  FMatId := nil;
  FVertexIndices := nil;
  FNormalIndices := nil;
  FMappingIndices := nil;
  FBoneIndices := nil;
  FBoneWeights := nil;
  //FBoneId := nil;
  inherited Destroy;
end;



procedure TBaseMesh.Assign(Source: TPersistent);
begin

  //TODO: Implement copying of protected vars.
  if Source is TBaseMesh then
  begin
    with TBaseMesh(Source) do
    begin
      self.FMatrix:=FMatrix;
      self.FVisible:=FVisible;
      //self.Fboneid:= Fboneid;
      self.FboneIndices:= FboneIndices;
      self.FBoneWeights:= FboneWeights;
      //self.FDisplaylist:= FDisplaylist;
      self.FId:= FId;
      self.FVertexIndices:= FVertexIndices;
      self.Fmapping:= Fmapping;
      self.Fmatid:= Fmatid;
      self.Fmatname:= Fmatname;
      self.FMaximum:= FMaximum;
      self.FMinimum:= FMinimum;
      self.FName:= FName;
      self.Fnumnormalindices:= Fnumnormalindices;
      self.Fnormalindices:= Fnormalindices;
      self.FMappingIndices := FMappingIndices;
      self.FNumVertexIndices:= FNumVertexIndices;
      self.FNumVertex:= FNumVertex;
      self.FNumNormals := FNumNormals;
      self.FNumMappings := FNumMappings;
      self.Fpivot:= Fpivot;
      self.FShadDisplayList:= FShadDisplayList;
      self.Fvertex:= Fvertex;
      self.Fvnormal:= Fvnormal;
    end;
  end
  else
    inherited;
end;

procedure TBaseMesh.CalculateSize;
var
  f: Integer;
  x, y, z: Single;
begin
  //am i allowed to assume the the first vertex is a minimum and/or maximum?
  FMinimum.x := FVertex[FVertexIndices[0]].x;
  FMinimum.y := FVertex[FVertexIndices[0]].y;
  FMinimum.z := FVertex[FVertexIndices[0]].z;
  FMaximum.x := FVertex[FVertexIndices[0]].x;
  FMaximum.y := FVertex[FVertexIndices[0]].y;
  FMaximum.z := FVertex[FVertexIndices[0]].z;
  for f := 0 to FNumVertexIndices - 1 do
    begin
      x := FVertex[FVertexIndices[f]].x;
      y := FVertex[FVertexIndices[f]].y;
      z := FVertex[FVertexIndices[f]].z;
      if x < FMinimum.x then FMinimum.x := x;
      if y < FMinimum.y then FMinimum.y := y;
      if z < FMinimum.z then FMinimum.z := z;
      if x > FMaximum.x then FMaximum.x := x;
      if y > FMaximum.y then FMaximum.y := y;
      if z > FMaximum.z then FMaximum.z := z;
    end;
end;

procedure TBaseMesh.CalculateNormals;
var
  v, f: integer;
  vertexn: t3dpoint;
  summedvertexn: t3dpoint;
  tempvertexn : T3dpoint;
  //tempnormals : array of T3dPoint;
  shared: integer;
begin
if self.NumVertexIndices > 0 then
    begin
      //SetLength(tempnormals, self.NumVertex); //init tempnormals
      f := 0;
      while f <= self.NumVertexIndices -3 do // go through all vertexes and
      begin

        vertexn := CalcNormalVector(self.Vertex[self.Face[f]],
          self.Vertex[self.Face[f + 1]], self.Vertex[self.Face[f + 2]]);

        //add all normals and normalize
        tempvertexn:=vertexn;//Normalize(vertexn);


        //tempnormals[f div 3] := tempvertexn;
        //self.Normals[self.Face[f div 3]] := tempvertexn;
        self.Normals[f div 3] := tempvertexn;


        //TODO: should be in seperate pass
//        self.Normal[f] := self.Face[f];
//        self.Normal[f + 1] := self.Face[f+1];
//        self.Normal[f + 2] := self.Face[f+2];
        self.Normal[f] := f div 3;
        self.Normal[f+1] := f div 3;
        self.Normal[f+2] := f div 3;

        f := f + 3;
      end;
        (*
      summedvertexn.x:=0.0;
      summedvertexn.y:=0.0;
      summedvertexn.z:=0.0;
      shared:=0;
      for v:=0 to self.NumVertex-1 do
      begin
        f:=0;
        while f <= self.NumVertexIndices -3  do
        begin
          if (self.Face[f]=v) or (self.Face[f+1]=v) or (self.Face[f+2]=v) then
          begin
            summedvertexn:=VectorAdd(summedvertexn, tempnormals[v]);
            shared:=shared+1;
            self.Normal[f] := f div 3;
            self.Normal[f+1] := f div 3;
            self.Normal[f+2] := f div 3;
          end;
          f:=f+3;
        end;
        self.Normals[v]:=Normalize(VectorDiv(summedvertexn, -shared));

        summedvertexn.x:=0.0;
        summedvertexn.y:=0.0;
        summedvertexn.z:=0.0;
        shared:=0;
      end;
      *)
      //SetLength(tempnormals,0);
    end;
end;

function TBaseMesh.GetVertexIndex(Index: integer): Word;
begin
  Result := FVertexIndices[index];
end;

function TBaseMesh.GetMap(Index: integer): Word;
begin
  Result := FMappingIndices[index];
end;

function TBaseMesh.GetFace(Index: integer): Word;
begin
  Result := FVertexIndices[index];
end;

function TBaseMesh.GetBoneId(VertexIndex, BoneIndex: integer): single;
begin
  Result := FBoneIndices[VertexIndex][BoneIndex];
end;

function TBaseMesh.GetBoneWeight(VertexIndex, WeightIndex: integer): single;
begin
  Result := FBoneWeights[VertexIndex][WeightIndex];
end;

function TBaseMesh.GetMapping(Index: integer): TMap;
begin
  Result := FMapping[index];
end;

function TBaseMesh.GetMatID(Index: integer): Word;
begin
  if fmatid <> nil then
    Result := FMatid[index]
  else
    Result := 0;
end;

procedure TBaseMesh.SetMatID(Index: Integer; Value: Word);
begin
  FMatId[Index]:=Value;
end;

function TBaseMesh.GetNormals(Index: integer): T3dPoint;
begin
  Result := FVnormal[index];
end;

function TBaseMesh.GetValFromMatrix(Index: integer): Single;
begin
  result := FMatrix[Index];
end;

function TBaseMesh.GetVertex(Index: integer): T3dPoint;
begin
  Result := FVertex[index];
end;

procedure TBaseMesh.SetValInMatrix(Index: integer; Value: Single);
begin
  FMatrix[Index]:=Value;
end;

procedure TBaseMesh.SetVertex(Index: integer; Value: T3DPoint);
begin
  FVertex[index]  :=Value;
end;

procedure TBaseMesh.SetVertexIndex(Index: integer; Value: word);
begin
  FVertexIndices[index]:=Value;
end;

procedure TBaseMesh.SetMap(Index: integer; Value: word);
begin
  FMappingIndices[index]:=Value;
end;

procedure TBaseMesh.SetMapping(Index: integer; Value: TMap);
begin
  FMapping[index]:=Value;
end;

procedure TBaseMesh.AddFace(v1, v2, v3: T3DPoint; fmaterial: TBaseMaterial);
begin
  //first add vertices
  FNumVertex := FNumVertex + 3;
  SetLength(FVertex, FNumVertex);
  //increase the number of indices
  FNumVertexIndices := FNumVertexIndices + 3;
  SetLength(FVertexIndices, FNumVertexIndices);

  //add the data
  FVertexIndices[FNumVertexIndices - 3] := FNumVertexIndices - 3;
  FVertexIndices[FNumVertexIndices - 2] := FNumVertexIndices - 2;
  FVertexIndices[FNumVertexIndices - 1] := FNumVertexIndices - 1;

  FVertex[FVertexIndices[FNumVertexIndices - 3]].x := v1.x;
  FVertex[FVertexIndices[FNumVertexIndices - 3]].y := v1.y;
  FVertex[FVertexIndices[FNumVertexIndices - 3]].z := v1.z;

  FVertex[FVertexIndices[FNumVertexIndices - 2]].x := v2.x;
  FVertex[FVertexIndices[FNumVertexIndices - 2]].y := v2.y;
  FVertex[FVertexIndices[FNumVertexIndices - 2]].z := v2.z;

  FVertex[FVertexIndices[FNumVertexIndices - 1]].x := v3.x;
  FVertex[FVertexIndices[FNumVertexIndices - 1]].y := v3.y;
  FVertex[FVertexIndices[FNumVertexIndices - 1]].z := v3.z;

  //add the material
  SetLength(FMatName, 1);
  FMatName[0] := fmaterial.Name;
  SetLength(FMatID, (FNumVertexIndices div 3));

  //TODO: rewrite material usage....
  FMatId[(FNumVertexIndices div 3) - 1] := fmaterial.TexID;
  //add mapping...
  SetLength(FMapping, FNumVertexIndices);
  FMapping[FVertexIndices[FNumVertexIndices - 3]].tu := v1.x;
  FMapping[FVertexIndices[FNumVertexIndices - 3]].tv := v1.y;
  FMapping[FVertexIndices[FNumVertexIndices - 2]].tu := v2.x;
  FMapping[FVertexIndices[FNumVertexIndices - 2]].tv := v2.y;
  FMapping[FVertexIndices[FNumVertexIndices - 1]].tu := v3.x;
  FMapping[FVertexIndices[FNumVertexIndices - 1]].tv := v3.y;
end;

procedure TBaseMesh.SetNumberOfVertex(Value: Integer);
begin
   FNumVertex:=Value;
   SetLength(FVertex, Value);
   SetLength(FBoneIndices, Value);
   SetLength(FBoneWeights, Value);
   SetLength(FMapping, Value);
end;

procedure TBaseMesh.SetBoneId(VertexIndex, BoneIndex: integer; aValue: single);
begin
  FBoneIndices[VertexIndex][BoneIndex] := aValue;
  //writeln(avalue);
end;

procedure TBaseMesh.SetBoneWeight(VertexIndex, WeightIndex: integer; aValue: single);
begin
  FBoneWeights[VertexIndex][WeightIndex] := aValue;
  //writeln(avalue);
end;

procedure TBaseMesh.SetMatName(Index: Integer; Value: string);
begin
  //TODO: Rewrite...
  if ( Length(FMatName) <= Index ) then setlength(FMatName, Index+1);

  FMatName[Index] := Value;
end;

function TBaseMesh.GetMatName(Index: Integer): string;
begin
  result := FMatName[Index];
end;

procedure TBaseMesh.SetNumberOfIndices(Value: Integer);
begin
  FNumVertexIndices := Value;
  SetLength(FVertexIndices, Value);
  SetLength(FMatId, Value);
end;

procedure TBaseMesh.SetNumberOfMappings(Value: Integer);
begin
  FNumMappings:=Value;
  SetLength(FMapping, Value);
end;

procedure TBaseMesh.SetNumberOfMappingIndices(Value: Integer);
begin
  FNumMappingIndices := Value;
  SetLength(FMappingIndices, Value);
end;

procedure TBaseMesh.SetNumberOfNormals(Value: Integer);
begin
  FNumNormals:=Value;
  //SetLength(FNormalIndices, Value); //TODO: should be removed here.
  SetLength(FVnormal, Value);
end;

procedure TBaseMesh.SetNumberOfNormalIndices(Value: Integer);
begin
  FNumNormalIndices := Value;
  SetLength(FNormalIndices, Value);
end;

procedure TBaseMesh.SetFace(Index: Integer; Value: Word);
begin
  FVertexIndices[Index] := Value;
end;

procedure TBaseMesh.SetNormals(Index: Integer; Value: T3dpoint);
begin
  FVNormal[Index] := Value;
end;

function TBaseMesh.GetNormal(Index: Integer): Word;
begin
  result:=FNormalIndices[Index];
end;

procedure TBaseMesh.SetNormal(Index: Integer; Value: Word);
begin
  FNormalIndices[Index]:=Value;
end;

end.
