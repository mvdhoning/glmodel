unit ModelMsa;

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

uses classes, Model;

type
  TMsaModel = class(TBaseModel)
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFileName: string); override;
      procedure SaveToStream(stream: TStream); override;
  end;



//DONE: Implement save and load for milkshape asci files
//TODO: Fix saving line 9 is different float vs int?
//NO differenct comes from move to pivot and scaling...
//Extra diff software deinstalleren.
//TODO: reloaded model is too bright?  Wrong is ambient? saveorload

//TODO: implement bones again...

implementation

uses
  SysUtils, glMath, Skeleton, SkeletonMsa, Mesh, Material;

procedure TMsaModel.LoadFromFile(AFileName: string);
var
  stream: TFilestream;
  msask: TMsaSkeleton;
begin
  FPath := ExtractFilePath(AFilename);
  if FTexturePath = '' then FTexturePath:=FPath;
  
  stream := TFilestream.Create(AFilename, $0000);
  LoadFromStream(stream);
  stream.Free;

  //also load skeleton if needed (this means that when loading from stream only
  if floadskeleton then
  begin
    fnumskeletons:=fnumskeletons+1;
    setlength(fskeleton, fnumskeletons);
    fskeleton[fnumskeletons-1]:=FSkeletonClass.Create(self);
    msask := TMsaSkeleton.Create(self);
    msask.BoneClass := fskeleton[fnumskeletons-1].BoneClass;
    msask.LoadFromFile(AFileName);
    fskeleton[fnumskeletons-1].Assign(msask);
    msask.Free;
  end;
end;

procedure TMsaModel.LoadFromStream(stream: Tstream);
var
  sl, tsl: TStringList;
  l: Integer;
  line: string;
  strtemp: string;
  tcount: LongWord;
  acount: LongWord;
  mcount: LongWord;
  bcount: LongWord;
  Count, loop, floop: LongWord;
  matid: Integer;
  m: LongWord;
  tempvertex: T3dPoint;
  tempmap: TMap;
begin
  floadskeleton:=false;
  sl := TStringList.Create;
  sl.LoadFromStream(stream);
  l := 0;
  while l < sl.Count - 1 do
  begin
    line := sl.Strings[l];

    //read in mesh data...
    if (pos('Meshes: ', line) = 1) then
    begin
      acount := StrToInt(StringReplace(Line, 'Meshes: ', '', [rfReplaceAll]));

      FNumMeshes := acount;
      SetLength(FMesh, acount);
      SetLength(FRenderOrder, acount);
      for tcount := 0 to acount - 1 do
      begin
        FMesh[tcount] := FMeshClass.Create(self);
        FMesh[tcount].Visible := True;
        FRenderOrder[tcount] := tcount;
          //read in mesh name and the id of the material for the mesh (only one material?)
        l := l + 1;
        line := sl.Strings[l];
        strtemp := copy(line, 0,pos(' ', line) - 1);
        Fmesh[tcount].Name := StringReplace(strtemp, '"', '', [rfReplaceAll]);

        strTemp := StringReplace(line, '"', '', [rfReplaceAll]);
        strTemp := copy(strTemp, pos(' ', strTemp) + 1,length(strTemp));
        matid := StrToInt(copy(strTemp, pos(' ', strTemp) + 1,length(strTemp)));

        if matid = -1 then FMesh[tcount].MatName[0] := ''
        else
          FMesh[tcount].MatName[0] := IntToStr(matid);

        //read in vertex data, texture u and v and the bone applied to the vertex
        l := l + 1;
        line := sl.Strings[l];
        Count := StrToInt(line);

        FMesh[tcount].NumVertex := Count;
        FMesh[tcount].NumMappings := Count;

        if Count > 0 then
          for loop := 0 to count-1 do
          begin
            l := l + 1;
            line := sl.Strings[l];
            tsl := TStringList.Create;
            tsl.CommaText := line;

            tempvertex := FMesh[tcount].Vertex[loop];

            tempvertex.x := strtofloat(tsl.Strings[1]);
            tempvertex.y := strtofloat(tsl.Strings[2]);
            tempvertex.z := strtofloat(tsl.Strings[3]);

            FMesh[tcount].Vertex[loop] := tempvertex;

            tempmap := FMesh[tcount].Mapping[loop];

            tempmap.tu := strtofloat(tsl.Strings[4]);
            tempmap.tv := strtofloat(tsl.Strings[5]);

            //adjust texture coord v? when and when not?
            tempmap.tv := 1.0 - tempmap.tv;

            FMesh[tcount].Mapping[loop]:=tempmap;

            FMesh[tcount].BoneId[loop] := StrToInt(tsl.Strings[6]);

            tsl.Free;
          end;

        //read in the normals
        l := l + 1;
        line := sl.Strings[l];
        Count := StrToInt(line);

        FMesh[tcount].NumNormals := Count;
        FMesh[tcount].NumNormalIndices := Count; //TODO: should be placed elsewhere
                                                 //to support less normal indeces then normals

        if Count > 0 then
          for loop := 0 to count-1 do
          begin
            l := l + 1;
            line := sl.Strings[l];
            tsl := TStringList.Create;
            tsl.CommaText := line;

            tempvertex := FMesh[tcount].Normals[loop];

            tempvertex.x := strtofloat(tsl.Strings[0]);
            tempvertex.y := strtofloat(tsl.Strings[1]);
            tempvertex.z := strtofloat(tsl.Strings[2]);

            FMesh[tcount].Normals[loop] := tempvertex;

            tsl.Free;
          end;

        //read in the indices (faces)
        l := l + 1;
        line := sl.Strings[l];
        Count := StrToInt(line);

        FMesh[tcount].NumNormals := count * 3;
        FMesh[tcount].NumNormalIndices := count * 3; //TODO: support less indices then normals
        FMesh[tcount].NumVertexIndices := count * 3;

        FMesh[tcount].NumVertexIndices := Count * 3;
        FMesh[tcount].NumMappingIndices := Count * 3;

        if Count > 0 then
          for loop := 0 to Count - 1 do
          begin
            l := l + 1;
            line := sl.Strings[l];
            tsl := TStringList.Create;
            tsl.CommaText := line;

            for floop := 1 to 3 do
            begin
              FMesh[tcount].Face[loop * 3 + floop - 1] := StrToInt(tsl.Strings[floop]);
              FMesh[tcount].Normal[loop * 3 + floop - 1] := StrToInt(tsl.Strings[floop + 3]);
              FMesh[tcount].Map[loop * 3 + floop - 1] := StrToInt(tsl.Strings[floop]); //texturemapping as vertexindice
            end;
            tsl.Free;
          end;

        //set matid for every vertex (make compatible with 3ds render)
        if Count > 0 then
        begin
          for loop := 0 to (FMesh[tcount].NumVertexIndices div 3) - 1 do
          begin
            if matid = -1 then matid := 0;
            FMesh[tcount].MatId[loop] := matid{+ 1};
          end;
        end;
      end;
    end;

    //read in material data...
    if (pos('Materials: ', line) = 1) then
    begin
      setlength(FMaterial, 1);
      FMaterial[0] := FMaterialClass.Create(self);

      mcount := StrToInt(StringReplace(Line, 'Materials: ', '', [rfReplaceAll]));
      setlength(FMaterial, mcount + 1);

      FNumMaterials := mcount;

      if FNumMaterials > 0 then
      begin
      for tcount := 0 to mcount - 1 do
      begin
        FMaterial[tcount] := FMaterialClass.Create(self);

        //read material name
        l := l + 1;
        line := sl.Strings[l];
        strtemp := line;
        FMaterial[tcount].Name := StringReplace(strtemp, '"', '', [rfReplaceAll]);

        //read ambient color data
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.CommaText := line;
        FMaterial[tcount].IsAmbient := False;
        FMaterial[tcount].AmbientRed := StrToFloat(tsl.strings[0]);
        FMaterial[tcount].AmbientGreen := StrToFloat(tsl.strings[1]);
        FMaterial[tcount].AmbientBlue := StrToFloat(tsl.strings[2]);
        if (FMaterial[tcount].AmbientRed<>0) or (FMaterial[tcount].AmbientGreen<>0) or (FMaterial[tcount].AmbientBlue<>0) then FMaterial[tcount].IsAmbient := True;
        tsl.Free;

        //read diffuse color data
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.CommaText := line;
        FMaterial[tcount].IsDiffuse := False;
        FMaterial[tcount].DiffuseRed := StrToFloat(tsl.strings[0]);
        FMaterial[tcount].DiffuseGreen := StrToFloat(tsl.strings[1]);
        FMaterial[tcount].DiffuseBlue := StrToFloat(tsl.strings[2]);
        FMaterial[tcount].Transparency := StrToFloat(tsl.strings[3]);
        if (FMaterial[tcount].DiffuseRed<>0) or (FMaterial[tcount].DiffuseGreen<>0) or (FMaterial[tcount].DiffuseBlue<>0) then FMaterial[tcount].IsDiffuse := True;
        tsl.Free;

        //read specular color data
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.CommaText := line;
        FMaterial[tcount].IsSpecular := False;
        FMaterial[tcount].SpecularRed := StrToFloat(tsl.strings[0]);
        FMaterial[tcount].SpecularGreen := StrToFloat(tsl.strings[1]);
        FMaterial[tcount].SpecularBlue := StrToFloat(tsl.strings[2]);
        if (FMaterial[tcount].SpecularRed<>0) or (FMaterial[tcount].SpecularGreen<>0) or (FMaterial[tcount].SpecularBlue<>0) then FMaterial[tcount].IsSpecular := True;
        tsl.Free;

        l := l + 3; //skip emissive, shininess, transperancy (implement later)

        line:=sl.Strings[l];
        FMaterial[tcount].BumpMapStrength := StrToFloat(line);

        l:=l+1;

        //read texture filename
        line := sl.Strings[l];
        strtemp := line;
        FMaterial[tcount].FileName := '';
        FMaterial[tcount].FileName := StringReplace(strtemp, '"', '', [rfReplaceAll]);
        FMaterial[tcount].FileName := StringReplace(Fmaterial[tcount].FileName, '.\', '', [rfReplaceAll]); //fix for wrong texture filenames

        if FMaterial[tcount].Filename <> '' then
          FMaterial[tcount].Hastexturemap := True;
        //skip second texture filename? alpha?
        l := l + 1;
        //read bumpmap filename
        line := sl.Strings[l];
        strtemp := line;
        FMaterial[tcount].BumpMapFileName := '';
        FMaterial[tcount].BumpMapFileName := StringReplace(strtemp, '"', '', [rfReplaceAll]);
        if FMaterial[tcount].BumpMapFileName <> '' then
          FMaterial[tcount].Hasbumpmap := True;
      end;
    end;
    end;

    //read in bone data...
    if (pos('Bones: ', line) = 1) then
    begin
      bcount := StrToInt(StringReplace(Line, 'Bones: ', '', [rfReplaceAll]));
      //if there are bones
      if bcount >= 1 then floadskeleton:=true;
    end;

    l := l + 1;
  end;
  sl.Free;

  //fill matnames into meshes
  If FnumMeshes > 0 then
  for m:= 0 to FNumMeshes -1 do
  begin
    if (FMesh[m].MatName[0] <> '0') AND (FMesh[m].MatName[0] <> '')  then
    begin
      FMesh[m].MatID[0] := StrToInt(FMesh[m].MatName[0]);
      FMesh[m].MatName[0] := FMaterial[StrToInt(FMesh[m].MatName[0])].Name;
    end;
  end;
end;

procedure TMsaModel.SaveToFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, fmCreate);
  SaveToStream(stream);
  stream.Free;
end;

procedure TMsaModel.SaveToStream(stream: Tstream);
var
  ms: TStringList;
  saveloop: Integer;
  subsaveloop: Integer;
  tempstring: string;
begin
  //this saves meshes and materials to a milkshape ascii file
  ms:=TStringList.Create;

  ms.Add('// MilkShape 3D ASCII');
  ms.Add('');
  ms.Add('Frames: 0');
  ms.Add('Frame: 0');
  ms.Add('');

  //save mesh data
  ms.Add('Meshes: '+IntToStr(FNumMeshes));

  for saveloop:=0 to FNumMeshes-1 do
  begin
    tempstring:=StringReplace(fmesh[saveloop].name, ' ', '_', [rfReplaceAll]);

    if fmesh[saveloop].NumMaterials > 0 then
       ms.Add('"'+tempstring+'"'+' 0'+' '+inttostr(fmesh[saveloop].matid[0]))
    else
       ms.Add('"'+tempstring+'"'+' 0'+' 0');

    //save vertexes
    ms.Add(inttostr(fmesh[saveloop].numvertex));

    for subsaveloop:=0 to fmesh[saveloop].numvertex -1 do
    begin
      if fmesh[saveloop].NumBones > 0 then
      ms.Add('0'+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].x)+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].y)+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].z)+' '+floattostr(fmesh[saveloop].Mapping[subsaveloop].tu)+' '+floattostr(1.0-fmesh[saveloop].Mapping[subsaveloop].tv)+' '+inttostr(fmesh[saveloop].boneid[subsaveloop]))
      else
      ms.Add('0'+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].x)+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].y)+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].z)+' '+floattostr(fmesh[saveloop].Mapping[subsaveloop].tu)+' '+floattostr(1.0-fmesh[saveloop].Mapping[subsaveloop].tv)+' -1');
    end;
    //save normals
    ms.Add(inttostr(fmesh[saveloop].NumNormals));
    if fmesh[saveloop].NumNormals > 0 then
    begin
      for subsaveloop:=0 to fmesh[saveloop].numvertex -1 do //should i use seperate Fnumnormals??
      begin

        ms.Add(floattostr( fmesh[saveloop].Normals[subsaveloop].x )+' '+floattostr(fmesh[saveloop].Normals[subsaveloop].y)+' '+floattostr(fmesh[saveloop].Normals[subsaveloop].z));

      end;
    end;

    //save faces (indices)
    ms.Add(inttostr(fmesh[saveloop].numvertexindices div 3));
    for subsaveloop:=0 to (fmesh[saveloop].numvertexindices div 3) -1 do
    begin
      if fmesh[saveloop].NumNormals > 0 then
      begin
      ms.Add('0 '
        +IntToStr(fmesh[saveloop].Face[subsaveloop*3])+' '+IntToStr(fmesh[saveloop].Face[subsaveloop*3+1])+' '+IntToStr(fmesh[saveloop].Face[subsaveloop*3+2])+' '
         +IntToStr(fmesh[saveloop].normal[subsaveloop*3])+' '+IntToStr(fmesh[saveloop].normal[subsaveloop*3+1])+' '+IntToStr(fmesh[saveloop].normal[subsaveloop*3+2])
        +' 1');
      end
      else
      begin
        ms.Add('0 '
        +IntToStr(fmesh[saveloop].Face[subsaveloop*3])+' '+IntToStr(fmesh[saveloop].Face[subsaveloop*3+1])+' '+IntToStr(fmesh[saveloop].Face[subsaveloop*3+2])+' '
         +'0 0 0'
        +' 1');
      end;


    end;
  end;

  ms.Add('');
  //save material data
  ms.Add('Materials: '+IntToStr(FNumMaterials));
  for saveloop:=0 to FNumMaterials-1 do
  begin
    ms.Add('"'+FMaterial[saveloop].name+'"');
    ms.Add(FloatToStr(FMaterial[saveloop].AmbientRed)+' '+FloatToStr(FMaterial[saveloop].AmbientGreen)+' '+FloatToStr(FMaterial[saveloop].AmbientBlue)+' 1.0');
    ms.Add(FloatToStr(FMaterial[saveloop].DiffuseRed)+' '+FloatToStr(FMaterial[saveloop].DiffuseGreen)+' '+FloatToStr(FMaterial[saveloop].DiffuseBlue)+' '+FloatToStr(FMaterial[saveloop].Transparency));
    ms.Add(FloatToStr(FMaterial[saveloop].SpecularRed)+' '+FloatToStr(FMaterial[saveloop].SpecularGreen)+' '+FloatToStr(FMaterial[saveloop].SpecularBlue)+' 1.0');
    ms.Add('0.0 0.0 0.0 1.0');
    ms.Add('0.0');
    ms.Add(FloatToStr(FMaterial[saveloop].bumpmapstrength));
    ms.Add('"'+FMaterial[saveloop].filename+'"');
    ms.Add('"'+FMaterial[saveloop].bumpmapfilename+'"');
  end;

  //fake save bones
  ms.Add('');
  ms.Add('Bones: 0');
  ms.Add('');
  ms.Add('');

  ms.SaveToStream(stream);
  ms.Free;
end;

initialization
RegisterModelFormat('txt', 'Milkshape 3D ascii model', TMsaModel);

finalization
UnRegisterModelClass(TMsaModel);

end.
