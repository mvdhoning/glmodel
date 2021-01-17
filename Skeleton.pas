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

uses classes, Bone, Animation;

type

  TBaseSkeleton = class;

  TBaseSkeletonClass = class of TBaseSkeleton;

  TBaseSkeleton = class(TComponent)
  protected
    FBoneClass : TBaseBoneClass;
    fAnimation: array of TBaseAnimationController;
    FBone: array of TBaseBone;
    FName: string;
    FNumBones: Integer;
    function GetBone(Index: integer): TBaseBone;
    function GetAnimation(Index: integer): TBaseAnimationController;
    procedure SetAnimation(Index: integer; Value: TBaseAnimationController);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property BoneClass: TBaseBoneClass read FBoneClass write FBoneClass;
    procedure AddBone;
    procedure Assign(Source: TPersistent); override;
    procedure InitBones;
    procedure AdvanceAnimation(time: single); overload; virtual;
    function GetBoneByName(s: string): TBaseBone;
    procedure LoadFromFile(Filename: string); virtual; abstract;
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToFile(AFilename: string); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    property Bone[Index: integer]: TBaseBone read GetBone;
    property Name: string read FName write FName;
    property NumBones: Integer read FNumBones;
    property Animation[Index: integer]: TBaseAnimationController read GetAnimation write SetAnimation;
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
      self.FName := FName;
      setlength(self.fAnimation,length(FAnimation));
      for I := 0 to length(FAnimation)-1 do
        begin
          self.FAnimation[i] := TBaseAnimationController.Create(self);
          self.FAnimation[i].Assign(FAnimation[i]);
        end;
    end;
  end
  else
    inherited;
end;

constructor TBaseSkeleton.Create(AOwner: TComponent);
begin
  inherited;
  FBoneClass := TBaseBone; //Make sure a bone class is set
  setlength(fAnimation,1);
  fAnimation[0]:=TBaseAnimationController.Create(self);
  fAnimation[0].Name:='Default';
end;

destructor TBaseSkeleton.Destroy;
begin
  inherited Destroy; //this will automaticaly free the meshes, materials, bones...
  //however do free the dynamic arrays used
  SetLength(FBone, 0);
  setlength(fAnimation,0);
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

procedure TBaseSkeleton.AdvanceAnimation(time: single);
var
  m: Integer;
begin
  //increase the currentframe
  fAnimation[0].AdvanceAnimation(time);

  //set the bones to their new positions
  if FNumBones > 0 then
    for m := 0 to FNumBones - 1 do
    begin
      FBone[m].Animation[0].CurrentFrame := fAnimation[0].CurrentFrame;
      FBone[m].AdvanceAnimation;
    end;
end;

procedure TBaseSkeleton.SetAnimation(Index: Integer; Value: TBaseAnimationController);
begin
  fAnimation[Index] := Value;
end;

function TBaseSkeleton.GetAnimation(Index: Integer): TBaseAnimationController;
begin
  result := fAnimation[Index];
end;

end.
