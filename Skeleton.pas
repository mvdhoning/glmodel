unit Skeleton;

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

uses classes, Bone, glmath;

type

  TBaseSkeleton = class;

  TBaseSkeletonClass = class of TBaseSkeleton;

  TBaseSkeleton = class(TComponent)
  protected
    FBoneClass : TBaseBoneClass;
    FBone: array of TBaseBone;
    FCurrentFrame: single;//Integer;
    FName: string;
    FNumBones: Integer;
    FNumFrames: Integer;
    FAnimFps: Single;
    function GetBone(Index: integer): TBaseBone;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property BoneClass: TBaseBoneClass read FBoneClass write FBoneClass;
    procedure AddBone;
    procedure Assign(Source: TPersistent); override;
    procedure InitBones;
    procedure AdvanceAnimation; overload;
    procedure AdvanceAnimation(time: single); overload; virtual;
    function GetBoneByName(s: string): TBaseBone;
    procedure LoadFromFile(Filename: string); virtual; abstract;
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToFile(AFilename: string); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    property Bone[Index: integer]: TBaseBone read GetBone;
    property CurrentFrame: single read FCurrentFrame write FCurrentFrame;
    property Name: string read FName write FName;
    property NumBones: Integer read FNumBones;
    property NumFrames: Integer read FNumFrames write FNumFrames;
    property AnimFps: Single read FAnimFps write FAnimFps;
  end;

implementation

uses
  SysUtils;

procedure TBaseSkeleton.Assign(Source: TPersistent);
var
  i: integer;
begin
  if Source is TBaseSkeleton then
  begin
    with TBaseSkeleton(Source) do
    begin
      self.FNumBones := FNumBones;

      setlength(self.FBone, FNumBones);
      for i := 0 to FNumBones - 1 do
        begin
          self.FBone[i] := FBoneClass.Create(self);
          self.FBone[i].Assign(FBone[i]);
        end;

      self.FCurrentFrame :=FCurrentFrame;
      self.FAnimFps:= FAnimFps;
      self.FName := FName;

      self.FNumFrames :=FNumFrames;

    end;
  end
  else
    inherited;

end;

constructor TBaseSkeleton.Create(AOwner: TComponent);
begin
  inherited;
  FBoneClass := TBaseBone; //Make sure a bone class is set
end;

destructor TBaseSkeleton.Destroy;
begin
  inherited Destroy; //this will automaticaly free the meshes, materials, bones...
  //however do free the dynamic arrays used
  SetLength(FBone, 0);
end;

procedure TBaseSkeleton.AddBone;
begin
  FNumBones := FNumBones + 1;
  SetLength(FBone, FNumBones);
  FBone[FNumBones - 1] := FBoneClass.Create(self);
end;

function TBaseSkeleton.GetBone(Index: integer): TBaseBone;
begin
  Result := FBone[index];
end;

function TBaseSkeleton.GetBoneByName(s: string): TBaseBone;
var
  i: Word;
begin
  Result := nil;
  for i := 0 to High(FBone) do
    if uppercase(FBone[i].Name) = uppercase(s) then
    begin
      Result := FBone[i];
      break;
    end;
end;

procedure TBaseSkeleton.InitBones;
var
  m: integer;
begin
  //init bone structure
  If FNumBones > 0 then
  for m := 0 to FNumBones - 1 do
  begin
    FBone[m].Init;
  end;
end;

procedure TBaseSkeleton.AdvanceAnimation;
begin
  self.AdvanceAnimation(1);
end;

procedure TBaseSkeleton.AdvanceAnimation(time: single);
var
  m: Integer;
begin
  //increase the currentframe
  FCurrentFrame := FCurrentFrame + time; //TODO: do not just add 1 but feed time
  if FCurrentFrame > FNumFrames then FCurrentFrame := 1; //reset when needed

  //set the bones to their new positions
  if FNumBones > 0 then
    for m := 0 to FNumBones - 1 do
    begin
      FBone[m].Animation[0].CurrentFrame := FCurrentFrame;
      FBone[m].AdvanceAnimation;
    end;
end;

end.
