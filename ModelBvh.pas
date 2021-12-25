unit ModelBvh;

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

uses classes, Model;

type
  TBvhModel = class(TBaseModel)
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFileName: string); override;
      procedure SaveToStream(stream: TStream); override;
  end;

implementation

uses
  SysUtils, glMath, SkeletonBvh, Bone;

procedure TBvhModel.LoadFromFile(AFileName: string);
var
  stream: TFilestream;
  msask: TBvhSkeleton;
begin
  FPath := ExtractFilePath(AFilename);
  if FTexturePath = '' then FTexturePath:=FPath;

  //fake read meshes etc
  //stream := TFilestream.Create(AFilename, $0000);
  //LoadFromStream(stream);
  //stream.Free;

  //load skeleton inof
  if floadskeleton then
  begin
    fnumskeletons:=fnumskeletons+1;
    setlength(fskeleton, fnumskeletons);
    fskeleton[fnumskeletons-1]:=FSkeletonClass.Create(self);
    fskeleton[fnumskeletons-1].BoneClass := TBaseBone;
    msask := TBvhSkeleton.Create(self);
    msask.BoneClass := fskeleton[fnumskeletons-1].BoneClass;
    msask.LoadFromFile(AFileName);
    fskeleton[fnumskeletons-1].Assign(msask);
    msask.Free;
  end;
end;

procedure TBvhModel.LoadFromStream(stream: Tstream);
begin
  floadskeleton:=true;
end;

procedure TBvhModel.SaveToFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, fmCreate);
  SaveToStream(stream);
  stream.Free;
end;

procedure TBvhModel.SaveToStream(stream: Tstream);
var
  msask: TBvhSkeleton;
begin
  //write the first skeleton (only one skeleton supported)
  if (self.NumSkeletons>=1) then
  begin
    msask := TBvhSkeleton.Create(self);
    msask.BoneClass := fskeleton[0].BoneClass;
    msask.Assign(fskeleton[0]);
    msask.SaveToStream(stream);
    msask.Free;
  end;
end;

initialization
RegisterModelFormat('bvh', 'The Biovision Hierarchy', TBvhModel);

finalization
UnRegisterModelClass(TBvhModel);

end.

