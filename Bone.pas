unit Bone;

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

uses classes, KeyFrame, glmatrix, glmath;

type
 //bone data
  TBaseBone = class;

  TBaseBoneClass = class of TBaseBone;

  TBaseBone = class(TComponent)
  protected
    FBvhChanneltype: Integer;
    FMatrix: ClsMatrix;
    FInverseMatrix: ClsMatrix;
    FName: string;
    FNumRotateFrames: Integer;
    FNumTranslateFrames: Integer;
    FParent: TBaseBone;
    FParentName: string;
    FRotate: T3DPoint;
    FRotateFrame: array of TKeyFrame;
    FTranslate: T3DPoint;
    FTranslateFrame: array of TKeyFrame;
    FCurrentFrame: single;
    function GetRotateFrame(Index: integer): TKeyFrame;
    procedure SetRotateFrame(Index: integer; Value: TKeyFrame);

    function GetTranslateFrame(Index: integer): TKeyFrame;
    procedure SetTranslateFrame(Index: integer; Value: TKeyFrame);

    procedure SetNumTranslateFrames(Value: Integer);
    procedure SetNumRotateFrames(Value: Integer);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AdvanceAnimation;
    //procedure AdvanceAnimation(time: single);
    procedure Init;
    procedure Render; virtual; abstract;
    property Name: string read FName write FName;
    property ParentName: string read FParentName write FParentName;
    property Parent: TBaseBone read FParent write FParent;
    property Rotate: T3DPoint read FRotate write FRotate;
    property Translate: T3DPoint read FTranslate write FTranslate;
    property CurrentFrame: single read FCurrentFrame write FCurrentFrame;
    property Matrix: ClsMatrix read FMatrix write FMatrix;
    property InverseMatrix: ClsMatrix read FInverseMatrix write FInverseMatrix;

    property NumRotateFrames: integer read FNumRotateFrames write SetNumRotateFrames;
    property NumTranslateFrames: integer read FNumTranslateFrames write SetNumTranslateFrames;
    property TranslateFrame[Index: integer]: TKeyFrame read GetTranslateFrame write SetTranslateFrame;
    property RotateFrame[Index: integer]: TKeyFrame read GetRotateFrame write SetRotateFrame;

  end;

//  TBone = class(TBaseBone)
//  end;


implementation

uses sysutils, Skeleton;

procedure TBaseBone.Assign(Source: TPersistent);
begin
  if Source is TBaseBone then
  begin
    with TBaseBone(Source) do
    begin
      self.FBvhChanneltype := FBvhChanneltype;
      //self.FMatrix := FMatrix;
      self.FName := FName;
      self.FNumRotateFrames := FNumRotateFrames;
      self.FNumTranslateFrames := FNumTranslateFrames;
      self.FParent := FParent;
      self.FParentName := FParentName;
      self.FRotate := FRotate;
      self.FRotateFrame := FRotateFrame;
      self.FTranslate := FTranslate;
      self.FTranslateFrame :=  FTranslateFrame;
      self.FCurrentFrame := FCurrentFrame;
    end;
  end
  else
    inherited;
end;

constructor TBaseBone.Create(AOwner: TComponent);
begin
  inherited Create(AOWner);
  FMatrix := clsMatrix.Create;
  FInverseMatrix := clsMatrix.Create;
end;

destructor TBaseBone.Destroy;
begin

  if FMatrix <> nil then
  begin
    FMatrix.Free();
    FMatrix:=nil;
  end;

   if FInverseMatrix <> nil then
  begin
    FInverseMatrix.Free();
    FInverseMatrix:=nil;
  end;
//  if FParent <> nil then
//  begin
//    FParent.Free();
//    FParent:=nil;
//  end; //dont free parents ...
  SetLength(FTranslateFrame, 0);
  SetLength(FRotateFrame, 0);
  inherited Destroy;
end;

procedure TBaseBone.AdvanceAnimation;
var
  i: Integer;
  deltaTime: Single;
  fraction: Single;
  Position: array [0..2] of single;
  Rotation: array [0..2] of single;
  m_rel, m_frame: clsMatrix;
  tempm: array [0..15] of single;
  tvec: array [0..2] of single;
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

    Position[0] := FTransLateFrame[i - 1].Value.x + fraction *
      (FTransLateFrame[i].Value.x - FTransLateFrame[i - 1].Value.x);
    Position[1] := FTransLateFrame[i - 1].Value.y + fraction *
      (FTransLateFrame[i].Value.y - FTransLateFrame[i - 1].Value.y);
    Position[2] := FTransLateFrame[i - 1].Value.z + fraction *
      (FTransLateFrame[i].Value.z - FTransLateFrame[i - 1].Value.z);
  end
  else
  begin
    if FNumTranslateFrames>0 then
    begin
      Position[0] := FTransLateFrame[i].Value.x;
      Position[1] := FTransLateFrame[i].Value.y;
      Position[2] := FTransLateFrame[i].Value.z;
    end else
    begin
      Position[0] := 0;
      Position[1] := 0;
      Position[2] := 0;
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

    Rotation[0] := FRotateFrame[i - 1].Value.x + fraction *
      (FRotateFrame[i].Value.x - FRotateFrame[i - 1].Value.x);
    Rotation[1] := FRotateFrame[i - 1].Value.y + fraction *
      (FRotateFrame[i].Value.y - FRotateFrame[i - 1].Value.y);
    Rotation[2] := FRotateFrame[i - 1].Value.z + fraction *
      (FRotateFrame[i].Value.z - FRotateFrame[i - 1].Value.z);
  end
  else
  begin
    if FNumRotateFrames>0 then
    begin
      Rotation[0] := FRotateFrame[i].Value.x;
      Rotation[1] := FRotateFrame[i].Value.y;
      Rotation[2] := FRotateFrame[i].Value.z;
    end
    else
    begin
      Rotation[0] := 0;
      Rotation[1] := 0;
      Rotation[2] := 0;
    end;
  end;

  // Now we know the position and rotation for this animation frame.
  // Let's calculate the transformation matrix (_matrix) for this bone...
  m_rel := clsMatrix.Create;
  m_frame := clsMatrix.Create;

  // Create a transformation matrix from the position and rotation of this
  // joint in the rest position
  tvec[0] := FRotate.x;
  tvec[1] := FRotate.y;
  tvec[2] := FRotate.z;

  m_rel.setRotationRadians(tvec);

  tvec[0] := FTranslate.x;
  tvec[1] := FTranslate.y;
  tvec[2] := FTranslate.z;

  m_rel.setTranslation(tvec);

  // Create a transformation matrix from the position and rotation
  // m_frame: additional transformation for this frame of the animation
  m_frame.setRotationRadians(Rotation);

  m_frame.setTranslation(Position);

  // Add the animation state to the rest position
  m_rel.postMultiply(m_frame);

  if (FParent = nil) then // this is the root node
  begin
    m_rel.getMatrix(tempm);
    FMatrix.setMatrixValues(tempm);  // _matrix := m_rel
  end
  else                  // not the root node
  begin
    // _matrix := parent's _matrix * m_rel (matrix concatenation)
    FParent.FMatrix.getMatrix(tempm);
    FMatrix.setMatrixValues(tempm);
    FMatrix.postMultiply(m_rel);
  end;

  m_frame.Free;
  m_rel.Free;
end;

procedure TBaseBone.Init;
var
  m_rel: clsMatrix;
  tempm: array [0..15] of single;
  tempv: array [0..2] of single;
begin
  //TODO: Rewrite to fill from skeleton
  //init parent bone direct access
  FParent := nil;
  if FParentName > '' then
    FParent := TBaseSkeleton(owner).GetBoneByName(FParentName);


  //calculate the matrix for the bone
  m_rel := clsMatrix.Create;
  m_rel.loadIdentity;
  // Create a transformation matrix from the position and rotation
  tempv[0] := FRotate.x;
  tempv[1] := FRotate.y;
  tempv[2] := FRotate.z;
  m_rel.setRotationRadians(tempv);


  tempv[0] := FTranslate.x;
  tempv[1] := FTranslate.y;
  tempv[2] := FTranslate.z;
  m_rel.setTranslation(tempv);

  // Each bone's final matrix is its relative matrix concatenated onto its
  // parent's final matrix (which in turn is ....)
  if (FParent = nil) then
  begin
    m_rel.getMatrix(tempm);
    FMatrix.setMatrixValues(tempm);
  end
  else
  begin
    FParent.FMatrix.getMatrix(tempm);
    FMatrix.setMatrixValues(tempm);
    FMatrix.postMultiply(m_rel);
  end;

  //calculate inversematrix
  FMatrix.getMatrix(tempm);
  FMatrix.Invert(tempm);
  FInverseMatrix.setMatrixValues(tempm);

  m_rel.Free;

end;

procedure TBaseBone.SetRotateFrame(Index: Integer; Value: TKeyFrame);
begin
  FRotateFrame[Index] := Value;
end;

function TBaseBone.GetRotateFrame(Index: Integer): TKeyFrame;
begin
  result := FRotateFrame[Index];
end;

procedure TBaseBone.SetTranslateFrame(Index: Integer; Value: TKeyFrame);
begin
  FTranslateFrame[Index] := Value;
end;

function TBaseBone.GetTranslateFrame(Index: Integer): TKeyFrame;
begin
  result := FTranslateFrame[Index];
end;

procedure TBaseBone.SetNumTranslateFrames(Value: Integer);
begin
  FNumTranslateFrames := Value;
  setlength(FTranslateFrame, Value);
end;

procedure TBaseBone.SetNumRotateFrames(Value: Integer);
begin
  FNumRotateFrames := Value;
  setlength(FRotateFrame, Value);
end;

end.
