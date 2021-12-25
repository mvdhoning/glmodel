unit Animation;

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

uses
  Classes, SysUtils, glmath, keyframe, Transform;

type

TBaseAnimation = class;

TBaseAnimationController = class(TComponent)
protected
  fName: string;
  FCurrentFrame: single;
  FNumFrames: Integer;
  FAnimFps: Single;
  fAnimation: array of TBaseAnimation;
  fNumElements: integer;
  function GetAnimation(Index: integer): TBaseAnimation;
  procedure SetAnimation(Index: integer; Value: TBaseAnimation);
public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
  procedure Assign(Source: TPersistent); override;
  procedure AddElement();
  procedure AdvanceAnimation(time: single);
  property Name: string read FName write FName;
  property CurrentFrame: single read FCurrentFrame write FCurrentFrame;
  property NumFrames: Integer read FNumFrames write FNumFrames;
  property AnimFps: Single read FAnimFps write FAnimFps;
  property Element[Index: integer]: TBaseAnimation read GetAnimation write SetAnimation;
  property NumElements: integer read fNumElements;
end;

TBaseAnimation = class(TComponent)
protected
  fId: integer;
  fName: string;
  FPosition: T3dCoord;
  FRotation: T3dCoord;
  FNumRotateFrames: Integer;
  FRotateFrame: array of TKeyFrame;
  FNumTranslateFrames: Integer;
  FTranslateFrame: array of TKeyFrame;
  FCurrentFrame: single;
  fBoneId: integer;
  fItem: TTransformComponent;
  function GetRotateFrame(Index: integer): TKeyFrame;
  procedure SetRotateFrame(Index: integer; Value: TKeyFrame);
  function GetTranslateFrame(Index: integer): TKeyFrame;
  procedure SetTranslateFrame(Index: integer; Value: TKeyFrame);
  procedure SetNumTranslateFrames(Value: Integer);
  procedure SetNumRotateFrames(Value: Integer);
public
  destructor Destroy; override;
  procedure Assign(Source: TPersistent); override;
  procedure AdvanceAnimation;
  property Id: integer read fId write fId;
  property Name: string read FName write FName;
  property Item: TTransformComponent read fItem write fItem;
  property CurrentFrame: single read FCurrentFrame write FCurrentFrame;
  property Rotation: T3DCoord read FRotation;
  property Position: T3DCoord read FPosition;
  property BoneId: integer read fboneid write fboneid;
  property NumRotateFrames: integer read FNumRotateFrames write SetNumRotateFrames;
  property NumTranslateFrames: integer read FNumTranslateFrames write SetNumTranslateFrames;
  property TranslateFrame[Index: integer]: TKeyFrame read GetTranslateFrame write SetTranslateFrame;
  property RotateFrame[Index: integer]: TKeyFrame read GetRotateFrame write SetRotateFrame;
end;

implementation

constructor TBaseAnimationController.Create(AOwner: TComponent);
begin
  inherited;
  fNumElements:=0;
end;

destructor TBaseAnimationController.Destroy;
begin
  inherited Destroy;
  setlength(fAnimation,0);
end;

procedure TBaseAnimationController.Assign(Source: TPersistent);
var
  i: integer;
begin
  if Source is TBaseAnimationController then
  begin
    with TBaseAnimationController(Source) do
    begin
      self.FCurrentFrame := FCurrentFrame;
      self.FAnimFps:= FAnimFps;
      self.FNumFrames :=FNumFrames;
      self.fNumElements := fNumElements;
      setlength(self.fAnimation,length(FAnimation));
      for I := 0 to length(FAnimation)-1 do
        begin
          self.FAnimation[i] := TBaseAnimation.Create(self);
          self.FAnimation[i].Assign(FAnimation[i]);
        end;
    end;

  end
  else
    inherited;
end;

procedure TBaseAnimationController.AddElement();
begin
  fNumElements:=fNumElements+1;
  setlength(fAnimation,length(fAnimation)+1);
  fanimation[length(fanimation)-1]:= TBaseAnimation.Create(self);
  fanimation[length(fanimation)-1].Name:='Default';
end;

procedure TBaseAnimationController.AdvanceAnimation(time: single);
var
  i: Integer;
begin
  //increase the currentframe
  FCurrentFrame := FCurrentFrame + time;
  if FCurrentFrame > FNumFrames then FCurrentFrame := 1; //reset when needed

  for i:=0 to length(fanimation)-1 do
    begin
      writeln(i);
      Element[i].CurrentFrame := fCurrentFrame;
      Element[i].AdvanceAnimation;
    end;
end;

destructor TBaseAnimation.Destroy;
begin
  inherited Destroy;
  SetLength(self.FTranslateFrame, 0);
  SetLength(self.FRotateFrame, 0);

end;

procedure TBaseAnimation.Assign(Source: TPersistent);
begin
  if Source is TBaseAnimation then
  begin
    with TBaseAnimation(Source) do
    begin
      self.fname:=fname;
      self.FNumRotateFrames := FNumRotateFrames;
      self.FNumTranslateFrames := FNumTranslateFrames;
      self.FRotateFrame := FRotateFrame;
      self.FTranslateFrame :=  FTranslateFrame;
      self.FCurrentFrame := FCurrentFrame;
      self.fBoneId:= fBoneId;
    end;
  end
  else
    inherited;
end;

procedure TBaseAnimation.AdvanceAnimation;
var
  i: Integer;
  deltaTime: Single;
  fraction: Single;
begin
  // Position

  // Find appropriate position key frame
  i := 0;
  while ((i < FNumTranslateFrames - 1) and (FTranslateFrame[i].Time <
    FCurrentFrame)) do
    i := i + 1;

  if (i > 0) then
  begin
    // Interpolate between 2 key frames

    // time between the 2 key frames
    deltaTime := FTranslateFrame[i].Time - FTransLateFrame[i - 1].Time;

    // relative position of interpolation point to the keyframes [0..1]
    fraction := (FCurrentFrame - FTransLateFrame[i - 1].Time) / deltaTime;

    fPosition[0] := FTransLateFrame[i - 1].Value.x + fraction *
      (FTransLateFrame[i].Value.x - FTransLateFrame[i - 1].Value.x);
    fPosition[1] := FTransLateFrame[i - 1].Value.y + fraction *
      (FTransLateFrame[i].Value.y - FTransLateFrame[i - 1].Value.y);
    fPosition[2] := FTransLateFrame[i - 1].Value.z + fraction *
      (FTransLateFrame[i].Value.z - FTransLateFrame[i - 1].Value.z);
  end
  else
  begin
    if FNumTranslateFrames>0 then
    begin
      writeln('set translate');
      fPosition[0] := FTransLateFrame[i].Value.x;
      fPosition[1] := FTransLateFrame[i].Value.y;
      fPosition[2] := FTransLateFrame[i].Value.z;
    end else
    begin
      writeln('no translate');
      fPosition[0] := 0;
      fPosition[1] := 0;
      fPosition[2] := 0;
    end;
  end;
  if self.Item<>nil then
  begin
    self.Item.Position:=fPosition;
  end;
  // Rotation

  // Find appropriate rotation key frame
  i := 0;
  while ((i < FNumRotateFrames - 1) and (FRotateFrame[i].Time <
    FCurrentFrame)) do
    i := i + 1;

  if (i > 0) then
  begin
    // Interpolate between 2 key frames

    // time between the 2 key frames
    deltaTime := FRotateFrame[i].Time - FRotateFrame[i - 1].Time;

    // relative position of interpolation point to the keyframes [0..1]
    fraction := (FCurrentFrame - FRotateFrame[i - 1].Time) / deltaTime;

    fRotation[0] := FRotateFrame[i - 1].Value.x + fraction *
      (FRotateFrame[i].Value.x - FRotateFrame[i - 1].Value.x);
    fRotation[1] := FRotateFrame[i - 1].Value.y + fraction *
      (FRotateFrame[i].Value.y - FRotateFrame[i - 1].Value.y);
    fRotation[2] := FRotateFrame[i - 1].Value.z + fraction *
      (FRotateFrame[i].Value.z - FRotateFrame[i - 1].Value.z);
  end
  else
  begin
    if FNumRotateFrames>0 then
    begin
      writeln('set rotate');
      fRotation[0] := FRotateFrame[i].Value.x;
      fRotation[1] := FRotateFrame[i].Value.y;
      fRotation[2] := FRotateFrame[i].Value.z;
    end
    else
    begin
      writeln('no rotate');
      fRotation[0] := 0;
      fRotation[1] := 0;
      fRotation[2] := 0;
    end;
  end;

  if self.Item<>nil then self.Item.Rotation:=fRotation;
  // Now we know the position and rotation for this animation frame.
  if self.Item<>nil then writeln('Has Item '+self.Item.Name + ' id: ' +inttostr(fboneid));
end;

procedure TBaseAnimation.SetRotateFrame(Index: Integer; Value: TKeyFrame);
begin
  FRotateFrame[Index] := Value;
end;

function TBaseAnimation.GetRotateFrame(Index: Integer): TKeyFrame;
begin
  result := FRotateFrame[Index];
end;

procedure TBaseAnimation.SetTranslateFrame(Index: Integer; Value: TKeyFrame);
begin
  FTranslateFrame[Index] := Value;
end;

function TBaseAnimation.GetTranslateFrame(Index: Integer): TKeyFrame;
begin
  result := FTranslateFrame[Index];
end;

procedure TBaseAnimation.SetNumTranslateFrames(Value: Integer);
begin
  FNumTranslateFrames := Value;
  setlength(self.FTranslateFrame, Value);
end;

procedure TBaseAnimation.SetNumRotateFrames(Value: Integer);
begin
  FNumRotateFrames := Value;
  setlength(self.FRotateFrame, Value);
end;

procedure TBaseAnimationController.SetAnimation(Index: Integer; Value: TBaseAnimation);
begin
  fAnimation[Index] := Value;
end;

function TBaseAnimationController.GetAnimation(Index: Integer): TBaseAnimation;
begin
  result := fAnimation[Index];
end;

end.

