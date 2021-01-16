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
  Classes, SysUtils, glmath, keyframe;

type
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
  property CurrentFrame: single read FCurrentFrame write FCurrentFrame;
  property Rotation: T3DCoord read FRotation;
  property Position: T3DCoord read FPosition;
  property NumRotateFrames: integer read FNumRotateFrames write SetNumRotateFrames;
  property NumTranslateFrames: integer read FNumTranslateFrames write SetNumTranslateFrames;
  property TranslateFrame[Index: integer]: TKeyFrame read GetTranslateFrame write SetTranslateFrame;
  property RotateFrame[Index: integer]: TKeyFrame read GetRotateFrame write SetRotateFrame;
end;

implementation

destructor TBaseAnimation.Destroy;
begin
  SetLength(FTranslateFrame, 0);
  SetLength(FRotateFrame, 0);
  inherited Destroy;
end;

procedure TBaseAnimation.Assign(Source: TPersistent);
begin
  if Source is TBaseAnimation then
  begin
    with TBaseAnimation(Source) do
    begin
      self.FNumRotateFrames := FNumRotateFrames;
      self.FNumTranslateFrames := FNumTranslateFrames;
      self.FRotateFrame := FRotateFrame;
      self.FTranslateFrame :=  FTranslateFrame;
      self.FCurrentFrame := FCurrentFrame;
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
      fPosition[0] := FTransLateFrame[i].Value.x;
      fPosition[1] := FTransLateFrame[i].Value.y;
      fPosition[2] := FTransLateFrame[i].Value.z;
    end else
    begin
      fPosition[0] := 0;
      fPosition[1] := 0;
      fPosition[2] := 0;
    end;
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
      fRotation[0] := FRotateFrame[i].Value.x;
      fRotation[1] := FRotateFrame[i].Value.y;
      fRotation[2] := FRotateFrame[i].Value.z;
    end
    else
    begin
      fRotation[0] := 0;
      fRotation[1] := 0;
      fRotation[2] := 0;
    end;
  end;

  // Now we know the position and rotation for this animation frame.

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
  setlength(FTranslateFrame, Value);
end;

procedure TBaseAnimation.SetNumRotateFrames(Value: Integer);
begin
  FNumRotateFrames := Value;
  setlength(FRotateFrame, Value);
end;

end.

