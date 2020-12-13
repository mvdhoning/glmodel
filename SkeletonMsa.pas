unit SkeletonMsa;

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
 TMsaSkeleton = class(TBaseSkeleton)
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      //TODO: add saving skeleton
  end;

implementation

uses sysutils, glmath, Bone, KeyFrame;

procedure TMsaSkeleton.LoadFromFile(AFilename: string);
var
  stream: TFileStream;
begin
  stream := TFilestream.Create(AFilename, fmOpenRead);
  LoadFromStream(stream);
  stream.Free;
end;

procedure TMsaSkeleton.LoadFromStream(stream: Tstream);
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
  sl := TStringList.Create;
  sl.LoadFromStream(stream);
  l := 0;
  while l < sl.Count - 1 do
  begin
    line := sl.Strings[l];

    //read in frames data...
    if (pos('Frames: ', line) = 1) then
    begin
      FNumFrames := StrToInt(StringReplace(Line, 'Frames: ', '', [rfReplaceAll]));
    end;

    //read in frames data...
    if (pos('Frame: ', line) = 1) then
    begin
      FCurrentFrame := StrToInt(StringReplace(Line, 'Frame: ', '', [rfReplaceAll]));
    end;

    //read in bone data...
    if (pos('Bones: ', line) = 1) then
    begin
      bcount := StrToInt(StringReplace(Line, 'Bones: ', '', [rfReplaceAll]));

      setlength(FBone, bcount);
      FNumBones := bcount;

      if FNumBones > 0 then
      for tcount := 0 to bcount - 1 do
      begin

        FBone[tcount] := FBoneClass.Create(self);

        //read bone name
        l := l + 1;
        line := sl.Strings[l];
        strtemp := line;
        FBone[tcount].Name := StringReplace(strtemp, '"', '', [rfReplaceAll]);

        //read parent bone name
        l := l + 1;
        line := sl.Strings[l];
        strtemp := line;
        FBone[tcount].ParentName := StringReplace(strtemp, '"', '', [rfReplaceAll]);

        //read bone translate and rotate...
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.CommaText := line;

        tempvertex := FBone[tcount].Translate;

        tempvertex.x := StrToFloat(tsl.strings[1]);
        tempvertex.y := StrToFloat(tsl.strings[2]);
        tempvertex.z := StrToFloat(tsl.strings[3]);

        FBone[tcount].Translate := tempvertex;

        tempvertex := FBone[tcount].Rotate;

        tempvertex.x := StrToFloat(tsl.strings[4]);
        tempvertex.y := StrToFloat(tsl.strings[5]);
        tempvertex.z := StrToFloat(tsl.strings[6]);

        FBone[tcount].Rotate := tempvertex;

        tsl.Free;

        //read translate frames for bone
        l := l + 1;
        line := sl.Strings[l];
        Count := StrToInt(line);
        FBone[tcount].NumTranslateFrames := Count;

        for floop := 0 to Count - 1 do
        begin
          l := l + 1;
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.CommaText := line;

          tempkeyframe := FBone[tcount].TranslateFrame[floop];

          tempkeyframe.time := Round(StrToFloat(tsl.strings[0]));
          tempkeyframe.Value.x := StrToFloat(tsl.strings[1]);
          tempkeyframe.Value.y := StrToFloat(tsl.strings[2]);
          tempkeyframe.Value.z := StrToFloat(tsl.strings[3]);

          FBone[tcount].TranslateFrame[floop] := tempkeyframe;

          tsl.Free;
        end;

        //read rotate frames for bone
        l := l + 1;
        line := sl.Strings[l];
        Count := StrToInt(line);
        FBone[tcount].NumRotateFrames := Count;

        for floop := 0 to Count - 1 do
        begin
          l := l + 1;
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.CommaText := line;

          tempkeyframe := FBone[tcount].RotateFrame[floop];

          tempkeyframe.time := Round(StrToFloat(tsl.strings[0]));
          tempkeyframe.Value.x := StrToFloat(tsl.strings[1]);
          tempkeyframe.Value.y := StrToFloat(tsl.strings[2]);
          tempkeyframe.Value.z := StrToFloat(tsl.strings[3]);

          FBone[tcount].RotateFrame[floop] := tempkeyframe;

          tsl.Free;
        end;
      end;
    end;

    l := l + 1;
  end;
  sl.Free;

end;

end.
