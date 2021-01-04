unit gl3skeleton;

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
 *
 *)

interface

uses classes, Skeleton, gl3bone, DglOpenGL;

type
  Tgl3Skeleton = class(TBaseSkeleton)
  public
    constructor Create(AOwner: TComponent); override;
    procedure AdvanceAnimation(time: single); overload; override;
  end;

implementation

uses glMath, gl3Render, model;

constructor TGL3Skeleton.Create(AOwner: TComponent);
begin
  inherited;
  FBoneClass := TGL3Bone;
end;

procedure Tgl3Skeleton.AdvanceAnimation(time: single);
var
  i: integer;
  bonematrix: glMatrix;
  ibonematrix: glMatrix;
  tempm: glMatrix;
  bonemat: packed array[0..49] of glMatrix;
begin
  inherited;

  for i:=0 to fNumBones-1 do
  begin
    fBone[i].Matrix.getMatrix(bonematrix);
    fBone[i].InverseMatrix.getMatrix(ibonematrix);
    multMatrix(tempm,bonematrix,ibonematrix);
    bonemat[i]:=tempm;
  end;
  glUniformMatrix4fv(Tgl3Render(TBaseModel(Owner).Owner).BoneMatLocation, 50, false, @bonemat[0]);

end;

end.
