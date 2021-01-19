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

uses classes, glmatrix, glmath;

type

  TBaseBone = class;

  TBaseBoneClass = class of TBaseBone;

  TBaseBone = class(TComponent)
  protected
    Fid: integer;
    FRotate: T3DPoint;
    FTranslate: T3DPoint;
    FPosition: T3dCoord;
    FRotation: T3dCoord;
    FMatrix: ClsMatrix;
    FInverseMatrix: ClsMatrix;
    FName: string;
    FParent: TBaseBone;
    FParentName: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Init;
    procedure Update;
    procedure Render; virtual; abstract;
    property Id: integer read fId write fId;
    property Name: string read FName write FName;
    property ParentName: string read FParentName write FParentName;
    property Parent: TBaseBone read FParent write FParent;
    property Rotate: T3DPoint read FRotate write FRotate;
    property Translate: T3DPoint read FTranslate write FTranslate;
    property Rotation: T3DCoord read FRotation write FRotation;
    property Position: T3DCoord read FPosition write FPosition;
    property Matrix: ClsMatrix read FMatrix write FMatrix;
    property InverseMatrix: ClsMatrix read FInverseMatrix write FInverseMatrix;
  end;

implementation

uses sysutils, Skeleton;

procedure TBaseBone.Assign(Source: TPersistent);
begin
  if Source is TBaseBone then
  begin
    with TBaseBone(Source) do
    begin
      self.FName := FName;
      self.FParent := FParent;
      self.FParentName := FParentName;
      self.FRotate := FRotate;
      self.FTranslate := FTranslate;
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

  inherited Destroy;
end;

procedure TBaseBone.Update;
var
  m_rel, m_frame: clsMatrix;
  tempm: array [0..15] of single;
  tvec: array [0..2] of single;
begin

  // Now we know the position and rotation for this animation frame.

  // Let's calculate the transformation matrix (_matrix) for this bone...
  m_rel := clsMatrix.Create;
  m_frame := clsMatrix.Create;

  // Create a transformation matrix from the position and rotation of this
  // joint in the rest position
  tvec[0] := Rotate.x;
  tvec[1] := Rotate.y;
  tvec[2] := Rotate.z;

  m_rel.setRotationRadians(tvec);

  tvec[0] := Translate.x;
  tvec[1] := Translate.y;
  tvec[2] := Translate.z;

  m_rel.setTranslation(tvec);

  // Create a transformation matrix from the position and rotation
  // m_frame: additional transformation for this frame of the animation
  m_frame.setRotationRadians(fRotation);

  m_frame.setTranslation(fPosition);

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

  //init parent bone direct access
  FParent := nil;
  if FParentName > '' then
    FParent := TBaseSkeleton(owner).GetBoneByName(FParentName);

  //calculate the matrix for the bone
  m_rel := clsMatrix.Create;
  m_rel.loadIdentity;

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

end.
