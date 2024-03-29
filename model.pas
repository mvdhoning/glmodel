unit Model;

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

uses classes, Material, Skeleton, Mesh
, glmatrix, glmath, animation;

//TODO: new math and matrix unit needed that are independend of opengl
//TODO: inject mesh material and skeleton classes (and vbo like class?)
//TODO: remove gl3 units
//TODO: rework glvboRender to work with having one big vbo for multiple meshes
//TODO: how to refer to vbo in glvbo render by id or inject the vbo into each unit

type

  TBaseModel = class;

  TBaseModelClass = class of TBaseModel;

  TBaseModel = class(TComponent)
  protected
    FMeshClass : TBaseMeshClass;
    FMaterialClass: TBaseMaterialClass;
    FSkeletonClass: TBaseSkeletonClass;

    fAnimation: array of TBaseAnimationController;

    fCurrentAnimation: Integer;

    FCurrentSkeleton: Integer;
    FDisplayList: Integer;
    FLoadSkeleton: Boolean;
    FMasterScale: Single;
    FMaterial: array of TBaseMaterial;
    FMaximum: T3dPoint;
    FMesh: array of TBaseMesh;
    FMinimum: T3dPoint;
    FName: string;
    FId: integer;
    FNumMaterials: Integer;
    FNumMeshes: Integer;
    FNumSkeletons: Integer;
    FRenderOrder: array of integer;
    FSkeleton: array of TBaseSkeleton;
    FTexturePath: string;
    FPath: string;
    FType: Integer;
    function GetMaterial(Index: integer): TBaseMaterial;
    function GetMaterialIdByName(s: string): Integer;
    function GetMesh(Index: integer): TBaseMesh;
    function GetRenderOrder(Index: integer): Integer;
    function GetSkeleton(Index: integer): TBaseSkeleton;
    procedure CalculateScale;
    function GetAnimation(Index: integer): TBaseAnimationController;
    procedure SetAnimation(Index: integer; Value: TBaseAnimationController);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init; virtual;
    procedure Render; virtual; abstract;
    procedure RenderBoundBox; virtual; abstract;
    procedure RenderSkeleton; virtual; abstract;
    procedure UpdateTextures; virtual; abstract;
    procedure Assign(Source: TPersistent); override;
    procedure AddMaterial;
    procedure AddMesh;
    procedure AddSkeleton;
    procedure CalculateRenderOrder;
    procedure CalculateSize;
    procedure CalculateNormals;
    function GetMaterialByName(s: string): TBaseMaterial;
    function GetMeshByName(s: string): TBaseMesh;
    procedure InitSkin;
    procedure AdvanceAnimation(time: single); overload; virtual;
    procedure LoadFromFile(AFilename: string); overload; virtual;
    procedure LoadFromStream(Stream: TStream); overload; virtual;
    procedure LoadFromStream(AType: TBaseModelClass; Stream: TStream); overload;
    procedure LoadFromFile(AType: TBaseModelClass; AFileName: string); overload;
    procedure SaveToFile(AType: TBaseModelClass; AFileName: string); overload;
    procedure SaveToFile(AFilename: string); overload; virtual;
    procedure SaveToStream(Stream: TStream); virtual;

    property MeshClass : TbaseMeshClass read FMeshClass write FMeshClass;
    property MaterialClass: TbaseMaterialClass read FMaterialClass write FMaterialClass;
    property SkeletonClass: TbaseSkeletonClass read FSkeletonClass write FSkeletonClass;

    property CurrentAnimation: Integer read fCurrentAnimation write fCurrentAnimation;
    property CurrentSkeleton: Integer read FCurrentSkeleton write FCurrentSkeleton;
    property FileType: Integer read FType write FType;
    property MasterScale: Single read FMasterScale write FMasterScale;
    property Material[Index: integer]: TBaseMaterial read GetMaterial;
    property Maximum: T3dPoint read FMaximum;
    property Mesh[Index: integer]: TBaseMesh read GetMesh;
    property Minimum: T3dPoint read FMinimum;
    property Name: string read FName write FName;
    property Id: integer read FId write FId;
    property NumMaterials: Integer read FNumMaterials;
    property NumMeshes: Integer read FNumMeshes;
    property NumSkeletons: Integer read FNumSkeletons;
    property RenderOrder[Index: integer]: Integer read GetRenderOrder;
    property Skeleton[Index: integer]: TBaseSkeleton read GetSkeleton;
    property TexturePath: string read FTexturePath write FTexturePath;
    property Path: string read FPath write FPath;
    property Animation[Index: integer]: TBaseAnimationController read GetAnimation write SetAnimation;
  end;

  procedure RegisterModelFormat(const AExtension, ADescription: string;
      ABaseModelClass: TBaseModelClass);

  procedure UnRegisterModelClass(ABaseModelClass: TBaseModelClass);

implementation

uses
  SysUtils, FileFormats3d;

var
  FileFormats: TModelFormatList;

function GetFileFormats: TModelFormatList;
begin
  if FileFormats = nil then FileFormats := TModelFormatList.Create;
  Result := FileFormats;
end;

constructor TBaseModel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMeshClass := TBaseMesh;
  FMaterialClass := TBaseMaterial;
  FSkeletonClass := TBaseSkeleton;
end;

destructor TBaseModel.Destroy;
begin
  FName := '';
  inherited Destroy; //this will automaticaly free the meshes, materials, bones...
  //however do free the dynamic arrays used
  SetLength(FMesh, 0);
  SetLength(FMaterial, 0);
  SetLength(FSkeleton, 0);
  Setlength(fAnimation,0);
end;

procedure TBaseModel.CalculateScale;
var
  f, m: Integer;
  tempPoint: T3dPoint;
begin
  for m := 0 to FNumMeshes - 1 do
  begin
    if FMesh[m].NumVertex > 0 then
    begin
      f := 0;
      while f < FMesh[m].NumVertex do // go through all vertexes and
      begin
        tempPoint := FMesh[m].Vertex[f];
        tempPoint.x := tempPoint.x * fmasterscale;
        tempPoint.y := tempPoint.y * fmasterscale;
        tempPoint.z := tempPoint.z * fmasterscale;
        FMesh[m].Vertex[f]:=tempPoint;

        f := f + 1;
      end;
    end;
  end;
end;

procedure TBaseModel.CalculateSize;
var
  m: Integer;
  x, y, z: Single;
begin
  FMinimum.x := 0;
  FMinimum.y := 0;
  FMinimum.z := 0;
  FMaximum.x := 0;
  FMaximum.y := 0;
  FMaximum.z := 0;
  for m := 0 to FNumMeshes - 1 do
    if FMesh[m].NumVertexIndices > 0 then
    begin
      FMesh[m].CalculateSize;
      x := FMesh[m].Minimum.x;
      y := FMesh[m].Minimum.y;
      z := FMesh[m].Minimum.z;
      if x < FMinimum.x then FMinimum.x := x;
      if y < FMinimum.y then FMinimum.y := y;
      if z < FMinimum.z then FMinimum.z := z;
      if x > FMaximum.x then FMaximum.x := x;
      if y > FMaximum.y then FMaximum.y := y;
      if z > FMaximum.z then FMaximum.z := z;
      x := FMesh[m].Maximum.x;
      y := FMesh[m].Maximum.y;
      z := FMesh[m].Maximum.z;
      if x < FMinimum.x then FMinimum.x := x;
      if y < FMinimum.y then FMinimum.y := y;
      if z < FMinimum.z then FMinimum.z := z;
      if x > FMaximum.x then FMaximum.x := x;
      if y > FMaximum.y then FMaximum.y := y;
      if z > FMaximum.z then FMaximum.z := z;
    end;
end;

function TBaseModel.GetMaterial(Index: integer): TBaseMaterial;
begin
  Result := FMaterial[index];
end;

function TBaseModel.GetMaterialByName(s: string): TBaseMaterial;
var
  i: Integer;
begin
  Result := nil;
  if FNumMaterials > 0 then
  begin
    for i := 0 to High(FMaterial) do
    begin
      if uppercase(FMaterial[i].Name) = uppercase(s) then
      begin
        Result := FMaterial[i];
        break;
      end;
    end;
  end;
end;

function TBaseModel.GetMaterialIdByName(s: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if FNumMaterials > 0 then
  begin
    for i := 0 to High(FMaterial) do
    begin
      if uppercase(FMaterial[i].Name) = uppercase(s) then
      begin
        Result := i;
        break;
      end;
    end;
  end;
end;

function TBaseModel.GetMesh(Index: integer): TBaseMesh;
begin
  Result := FMesh[index];
end;

function TBaseModel.GetMeshByName(s: string): TBaseMesh;
var
  i: Word;
begin
  Result := nil;
  for i := 0 to High(FMesh) do
    if uppercase(FMesh[i].Name) = uppercase(s) then
    begin
      Result := FMesh[i];
      break;
    end;
end;

procedure TBaseModel.AddMaterial;
begin
  FNumMaterials := FNumMaterials + 1;
  SetLength(FMaterial, FNumMaterials);
  FMaterial[FNumMaterials - 1] := FMaterialClass.Create(self);
end;

procedure TBaseModel.AddMesh;
begin
  FNumMeshes := FNumMeshes + 1;
  SetLength(FMesh, FNumMeshes);
  SetLength(FRenderOrder, FNumMeshes);
  FMesh[FNumMeshes - 1] := FMeshClass.Create(self);
  FRenderOrder[FNumMeshes-1]:=FNumMeshes-1;
end;

procedure TBaseModel.AddSkeleton;
begin
  FNumSkeletons := FNumSkeletons + 1;
  SetLength(FSkeleton, FNumSkeletons);
  FSkeleton[FNumSkeletons - 1] := FSkeletonClass.Create(self);
end;

procedure TBaseModel.Assign(Source: TPersistent);
var
    i: integer;
begin
  if Source is TBaseModel then
  begin
    With TBaseModel(source) do
    begin
      FCurrentSkeleton:= self.FCurrentSkeleton;
      FDisplayList:= self.FDisplayList;
      FLoadSkeleton:= self.FLoadSkeleton;
      FMasterScale:= self.FMasterScale;

      self.FNumMaterials :=FNumMaterials;
      setlength(self.FMaterial, FNumMaterials);
      for i := 0 to FNumMaterials - 1 do
        begin
          self.FMaterial[i] := FMaterialClass.Create(self);
          self.FMaterial[i].Assign(FMaterial[i]);
        end;
      self.FMaximum:= FMaximum;

      self.FNumMeshes := FNumMeshes;
      setlength(self.FMesh,FNumMeshes);
      for I := 0 to FNumMeshes - 1 do
        begin
          self.FMesh[i] := FMeshClass.Create(self);
          self.FMesh[i].Assign(FMesh[i]);
        end;

      self.FMinimum := FMinimum;
      self.FName := FName;
      self.FRenderOrder := FRenderOrder;

      self.FNumSkeletons := FNumSkeletons;
      setlength(self.FSkeleton,FNumSkeletons);
      for I := 0 to FNumSkeletons - 1 do
        begin
          self.FSkeleton[i] := FSkeletonClass.Create(self);
          self.FSkeleton[i].Assign(FSkeleton[i]);
        end;

      self.FTexturePath := FTexturePath;
      self.FType := FType;


      writeln('assign anims: ');
      setlength(self.fAnimation,length(FAnimation));
      for i := 0 to length(FAnimation)-1 do
        begin
          writeln(fAnimation[i].Name);
          writeln(Animation[i].Name);

          self.FAnimation[i] := TBaseAnimationController.Create(self);
          self.FAnimation[i].Assign(FAnimation[i]);
        end;

    end;
  end
  else
     inherited
end;

function TBaseModel.GetRenderOrder(Index: integer): Integer;
begin
  Result := FRenderOrder[index];
end;

function TBaseModel.GetSkeleton(Index: integer): TBaseSkeleton;
begin
  Result := FSkeleton[index];
end;

procedure TBaseModel.Init;
var
    i,j: integer;
begin
  if self.NumSkeletons=1 then
  begin
    self.Skeleton[0].InitBones;
    //link each animation to a bone
    for j:=0 to length(self.fAnimation)-1 do
      for i:=0 to self.animation[j].NumElements-1 do
        begin
          self.Animation[j].Element[i].Item:=self.Skeleton[0].Bone[self.Animation[j].Element[i].BoneId];
        end;
    end;
end;

procedure TBaseModel.InitSkin;
var
  f, m: Integer;
  v: array [0..2] of single;
  t: T3dPoint;
  matrix: clsMatrix;
  tempbone: Integer;
begin

  if FNumSkeletons >= 1 then
  begin

  //do not call init skin if you want to save the mesh later on !!!
  for m := 0 to FNumMeshes - 1 do
  begin
    if FMesh[m].NumVertexIndices > 0 then
    begin
      f := 0;
      while f < FMesh[m].NumVertex do // go through all vertexes and
      begin
        tempbone := trunc(FMesh[m].BoneId[f,0]);

        if tempbone<>-1 then
        begin

          matrix := FSkeleton[FCurrentSkeleton].Bone[tempbone].Matrix;
          v[0] := FMesh[m].Vertex[f].x;
          v[1] := FMesh[m].Vertex[f].y;
          v[2] := FMesh[m].Vertex[f].z;
          matrix.InverseTranslateVect(v);
          matrix.InverseRotateVect(v);

          t.x:= v[0];
          t.y:= v[1];
          t.z:= v[2];
          FMesh[m].Vertex[f] := t;

        end;

        f := f + 1;
      end;
    end;
  end;

  end;
end;

procedure TBaseModel.AdvanceAnimation(time: single);
var
  i: integer;
begin
  //increase the currentframe
  self.Animation[fCurrentAnimation].AdvanceAnimation(time); //first advance the animation

  //pass new calculated positions and rotations on to the bone
  //or set animation element to the bone in model.init call
  (*
  for i:=0 to self.Animation[1].NumElements-1 do
  begin
    self.Skeleton[0].Bone[self.Animation[1].Element[i].BoneId].Position:=self.Animation[1].Element[i].Position;
    self.Skeleton[0].Bone[self.Animation[1].Element[i].BoneId].Rotation:=self.Animation[1].Element[i].Rotation;
  end;
  *)

  self.Skeleton[0].UpdateBones; //update bones to the new frame data
end;

procedure TBaseModel.LoadFromFile(AFilename: string);
var
  Ext: string;
  GraphicClass: TBaseModelClass;
begin
  Ext := ExtractFileExt(AFilename);
  Delete(Ext, 1, 1);
  GraphicClass := FileFormats.FindExt(Ext);
  LoadFromFile(GraphicClass, AFilename);
  Calculatesize;        //calculate min and max size
  CalculateRenderOrder; //set transparency order...
  Init;
end;

procedure TBaseModel.LoadFromFile(AType: TBaseModelClass; AFileName: string);
var
  LoadModel: TBaseModel;
begin
  LoadModel:= AType.Create(nil);
  LoadModel.MeshClass := self.FMeshClass;
  LoadModel.MaterialClass := self.FMaterialClass;
  LoadModel.SkeletonClass := self.FSkeletonClass;
  LoadModel.LoadFromFile(AFileName);
  self.Assign(LoadModel);
  LoadModel.Free;
end;

procedure TBaseModel.LoadFromStream(Stream: TStream);
begin
  Raise Exception.Create('TModel.LoadFromStream not implemented');
end;

procedure TBaseModel.LoadFromStream(AType: TBaseModelClass; Stream: TStream);
var
  LoadModel: TBaseModel;
begin
  LoadModel:= AType.Create(nil);
  LoadModel.MeshClass := self.FMeshClass;
  LoadModel.MaterialClass := self.FMaterialClass;
  LoadModel.SkeletonClass := self.FSkeletonClass;
  LoadModel.LoadFromStream(Stream);
  self.Assign(LoadModel);
  LoadModel.Free;
end;

procedure TBaseModel.SaveToFile(AType: TBaseModelClass; AFileName: string);
var
  SaveModel: TBaseModel;
begin
  SaveModel:= Atype.Create(nil);
  SaveModel.MeshClass := self.FMeshClass;
  SaveModel.MaterialClass := self.FMaterialClass;
  SaveModel.SkeletonClass := self.FSkeletonClass;
  SaveModel.Assign(self);
  SaveModel.SaveToFile(AFileName);
  SaveModel.Free;
end;

procedure TBaseModel.SaveToFile(AFilename: string);
var
  Ext: string;
  GraphicsClass: TBaseModelClass;
begin
  Ext := ExtractFileExt(AFilename);
  Delete(Ext, 1, 1);
  GraphicsClass := FileFormats.FindExt(Ext);
  SaveToFile(GraphicsClass, AFilename);
end;

procedure TBaseModel.SaveToStream(Stream: TStream);
begin
  raise Exception.Create('TModel.SaveToStream is not implemented')
end;

procedure TBaseModel.CalculateRenderOrder;
begin
  //TODO: order meshes by transparency
end;

procedure TBaseModel.CalculateNormals;
var
  m: Integer;
begin
  //get basic normals
  for m := 0 to FNumMeshes - 1 do
  begin
    FMesh[m].CalculateNormals;
  end;
end;

procedure TBaseModel.SetAnimation(Index: Integer; Value: TBaseAnimationController);
begin
  fAnimation[Index] := Value;
end;

function TBaseModel.GetAnimation(Index: Integer): TBaseAnimationController;
begin
  result := fAnimation[Index];
end;

{ TModel }

procedure RegisterModelFormat(const AExtension, ADescription: string;
      ABaseModelClass: TBaseModelClass);
begin
  GetFileFormats.Add(AExtension, ADescription, ABaseModelClass);
end;

procedure UnRegisterModelClass(ABaseModelClass: TBaseModelClass);
begin
  GetFileFormats.Remove(ABaseModelClass);
end;

finalization
  FreeAndNil(FileFormats);

end.
