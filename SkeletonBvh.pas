unit SkeletonBvh;

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

uses classes, Skeleton;

type
 TBvhSkeleton = class(TBaseSkeleton)
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFilename: string); override;
      procedure SaveToStream(Stream: TStream); override;
  end;

implementation

uses sysutils, glmath, Bone, KeyFrame;

procedure TBvhSkeleton.LoadFromFile(AFilename: string);
var
  stream: TFileStream;
begin
  stream := TFilestream.Create(AFilename, fmOpenRead);
  LoadFromStream(stream);
  stream.Free;
end;

procedure TBvhSkeleton.SaveToFile(AFilename: string);
var
  stream: TFileStream;
begin
  stream := TFilestream.Create(AFilename, fmOpenRead);
  SaveToStream(stream);
  stream.Free;
end;

procedure TBvhSkeleton.LoadFromStream(stream: Tstream);
var
  sl, tsl: TStringList;
  l: Integer;
  line: string;
  strtemp: string;
  tcount: LongWord;
  bcount: LongWord;
  Count, floop: LongWord;
  tempvertex: T3DPoint;
  tempkeyframe: TKeyFrame;
begin
  //TODO: implement reaading bvh file
end;

procedure TBvhSkeleton.SaveToStream(stream: Tstream);
var
  ms: TStringList;
  bcount,i: integer;
  boneprefix: string;
  nestlevel: integer;
  currentbone: string;
begin
  ms:=TStringList.Create;
  ms.add('HIERARCHY');
  boneprefix:='ROOT';
  nestlevel:=0;

  currentbone:=fBone[0].Name;
  ms.add('ROOT '+currentbone);
  nestlevel:=nestlevel+1;
  ms.add('{');
  ms.add('  OFFSET '+formatfloat('0.000000',fBone[0].Translate.x)+' '+formatfloat('0.000000',fBone[0].Translate.y)+' '+formatfloat('0.000000',fBone[0].Translate.z));
  boneprefix:='    JOINT ';

  for bcount:=1 to fNumBones-1 do
  begin

    if fBone[bcount].parent.Name = currentbone then
    begin
    //write bone name
    ms.add(boneprefix+fBone[bcount].Name);

    nestlevel:=nestlevel+1;
    ms.add('   {');
    //flags and position and rotation
    ms.add('       OFFSET '+formatfloat('0.000000',fBone[bcount].Translate.x)+' '+formatfloat('0.000000',fBone[bcount].Translate.y)+' '+formatfloat('0.000000',fBone[bcount].Translate.z)+' '
           +formatfloat('0.000000',fBone[bcount].Rotate.x)+' '+formatfloat('0.000000',fBone[bcount].Rotate.y)+' '+formatfloat('0.000000',fBone[bcount].Rotate.z)
          );

    ms.add('  }');
    end;
  end;
  ms.add('}');

  ms.SaveToStream(stream);
  ms.Free;
end;

end.

