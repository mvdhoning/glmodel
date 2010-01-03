unit ModelX;

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
  TDXModel = class(TBaseModel)
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFileName: string); override;
      procedure SaveToStream(stream: TStream); override;
  end;


//Rewrite TO .x format (yes directx) see sketchup exporter

implementation

uses
  SysUtils, glMath, Mesh, Material;

procedure TDXModel.LoadFromFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, $0000);
  LoadFromStream(stream);
  stream.Free;
end;

procedure TDXModel.LoadFromStream(stream: Tstream);
var
  sl, tsl: TStringList;
  l: Integer;
  line: string;
  strtemp: string;
  acount: LongWord;
  mcount: LongWord;
//  bcount: LongWord;
  Count, loop, floop: LongWord;
  matid: Integer;
//  m: LongWord;
  tempvertex: T3dPoint;
  tempmap: TMap;
begin
  mcount:=0;
  acount:=0;
  floadskeleton:=false;
  sl := TStringList.Create;
  sl.LoadFromStream(stream);


  //check if file realy is a DirectX txt model file.
  if sl.Strings[0] = 'xof 0303txt 0032' then
  begin

    l := 0;
    while l < sl.Count - 1 do
    begin
      line := sl.Strings[l];

      //read in mesh data...
      if (pos('Mesh ', line) = 2) then
      begin
        acount := acount +1;

        FNumMeshes := acount;
        SetLength(FMesh, acount);
        SetLength(FRenderOrder, acount);

        FMesh[acount-1] := FMeshClass.Create(self);
        FMesh[acount-1].Visible := True;
        FRenderOrder[acount-1] := acount-1;

        //read in mesh name and the id of the material for the mesh (only one material?)
        strtemp := copy(line, 6, pos('{',line)-6);
        Fmesh[acount-1].Name := strtemp;

        //read in vertex data
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        Count := StrToInt(line);

        FMesh[acount-1].NumVertex := Count;
        FMesh[acount-1].NumMappings := Count;

        if Count > 0 then
        for loop := 0 to count-1 do
        begin
          l := l + 1;
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.Delimiter :=';';
          tsl.DelimitedText := line;

          tempvertex := FMesh[acount-1].Vertex[loop];

          tempvertex.x := strtofloat(tsl.Strings[0]);
          tempvertex.y := strtofloat(tsl.Strings[1]);
          tempvertex.z := strtofloat(tsl.Strings[2]);

          FMesh[acount-1].Vertex[loop] := tempvertex;

          tsl.Free;
        end;

        //read in the indices (faces)
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        Count := StrToInt(line);

        FMesh[acount-1].NumVertexIndices := count * 3;

        if Count > 0 then
        for loop := 0 to Count - 1 do
        begin
          l := l + 1;
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.Delimiter :=';';
          tsl.DelimitedText := line;

          strtemp :=tsl[1];
          tsl.Free;

          tsl := TStringList.Create;
          tsl.Delimiter :=',';
          tsl.DelimitedText := strtemp;

          for floop := 0 to 2 do
          begin
            FMesh[acount-1].Face[(loop*3) + floop] := StrToInt(tsl.Strings[floop]);
          end;
          tsl.Free;
        end;
      end;

      //read in normals
      if (pos('MeshNormals', line) = 3) then
      begin
        //read in normal data
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        Count := StrToInt(line);

        FMesh[acount-1].NumNormals := Count;

        if Count > 0 then
        for loop := 0 to count-1 do
        begin
          l := l + 1;
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.Delimiter :=';';
          tsl.DelimitedText := line;

          tempvertex := FMesh[acount-1].Normals[loop];

          tempvertex.x := strtofloat(tsl.Strings[0]);
          tempvertex.y := strtofloat(tsl.Strings[1]);
          tempvertex.z := strtofloat(tsl.Strings[2]);

          FMesh[acount-1].Normals[loop] := tempvertex;

          tsl.Free;
        end;

        //read in the normal indices
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        Count := StrToInt(line);

        FMesh[acount-1].NumNormalIndices := count * 3;

        if Count > 0 then
        for loop := 0 to count - 1 do
        begin
          l := l + 1;
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.Delimiter :=';';
          tsl.DelimitedText := line;

          strtemp :=tsl[1];
          tsl.Free;

          tsl := TStringList.Create;
          tsl.Delimiter :=',';
          tsl.DelimitedText := strtemp;

          for floop := 0 to 2 do
          begin
            FMesh[acount-1].Normal[(loop*3) + floop] := StrToInt(tsl.Strings[floop]);
          end;
          tsl.Free;
        end;
      end;

      //read in texture coords data...
      if (pos('MeshTextureCoords', line) = 3) then
      begin
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        Count := StrToInt(line);

        FMesh[acount-1].NumMappings := Count;

        if Count > 0 then
        for loop := 0 to count-1 do
        begin
          l := l + 1;
          //line :=stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
          line := sl.Strings[l];
          tsl := TStringList.Create;
          tsl.Delimiter :=';';
          tsl.DelimitedText := line;

          tempmap := FMesh[acount-1].Mapping[loop];

          tempmap.tu := strtofloat(tsl.Strings[0]);
          tempmap.tv := strtofloat(tsl.Strings[1]);

          FMesh[acount-1].Mapping[loop] := tempmap;
        end;

        //texture coords per vertex so set indeces accordingly
        FMesh[acount-1].NumMappingIndices := FMesh[acount-1].NumVertexIndices;
        for loop:=0 to FMesh[acount-1].NumMappingIndices-1 do
        begin
          FMesh[acount-1].Map[loop] := FMesh[acount-1].Face[loop];
        end;

      end;

      //read in texture coords data...
      if (pos('MeshMaterialList', line) = 3) then
      begin
        //number of materials
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        //Count := StrToInt(line); //warning due to count not used :-)

        //number of indices
        l := l + 1;
        line := stringreplace(sl.Strings[l],';','',[rfReplaceAll]);
        Count := StrToInt(line);

        if Count> 0 then
        for loop:=0 to count-1 do
        begin
          l:=l+1;
          line := stringreplace(sl.Strings[l],',','',[rfReplaceAll]);
          line := stringreplace(line,';','',[rfReplaceAll]);
          matid := StrToInt(line);
          FMesh[acount-1].MatId[loop] := matid{+ 1};

          if loop = 0 then
          begin
            FMesh[acount-1].MatName[0]:=self.GetMaterial(matid).Name;
            FMesh[acount-1].MatID[0]:=matid;
          end;
        end;

      end;

      //read in material data...
      if (pos('Material ', line) = 2) then
      begin
        mcount:=mcount+1;
        setlength(FMaterial, mcount);

        FNumMaterials := mcount;

        FMaterial[mcount-1] := FMaterialClass.Create(self);

        //read material name
        strtemp :='';
        strtemp := copy(line, 10, pos(' {',line)-10);
        FMaterial[mcount-1].Name := strtemp;

        //read ambient color data
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.Delimiter :=';';
        tsl.DelimitedText := line;
        FMaterial[mcount-1].IsDiffuse := False;
        FMaterial[mcount-1].DiffuseRed := StrToFloat(tsl.strings[0]);
        FMaterial[mcount-1].DiffuseGreen := StrToFloat(tsl.strings[1]);
        FMaterial[mcount-1].DiffuseBlue := StrToFloat(tsl.strings[2]);

        FMaterial[mcount-1].Transparency := StrToFloat(tsl.strings[3]);
        if (FMaterial[mcount-1].DiffuseRed<>0) or (FMaterial[mcount-1].DiffuseGreen<>0) or (FMaterial[mcount-1].DiffuseBlue<>0) then FMaterial[mcount-1].IsDiffuse := True;
        tsl.Free;

        //read specular strength ...
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.Delimiter :=';';
        tsl.DelimitedText := line;
        FMaterial[mcount-1].Shininess := StrToFloat(tsl.strings[0]);
        tsl.Free;

        //read specular color data
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.Delimiter :=';';
        tsl.DelimitedText := line;
        FMaterial[mcount-1].IsSpecular := False;
        FMaterial[mcount-1].SpecularRed := StrToFloat(tsl.strings[0]);
        FMaterial[mcount-1].SpecularGreen := StrToFloat(tsl.strings[1]);
        FMaterial[mcount-1].SpecularBlue := StrToFloat(tsl.strings[2]);
        if (FMaterial[mcount-1].SpecularRed<>0) or (FMaterial[mcount-1].SpecularGreen<>0) or (FMaterial[mcount-1].SpecularBlue<>0) then FMaterial[mcount-1].IsSpecular := True;
        tsl.Free;

        //read ambient color data
        l := l + 1;
        line := sl.Strings[l];
        tsl := TStringList.Create;
        tsl.Delimiter :=';';
        tsl.DelimitedText := line;
        FMaterial[mcount-1].IsAmbient := False;
        FMaterial[mcount-1].AmbientRed := StrToFloat(tsl.strings[0]);
        FMaterial[mcount-1].AmbientGreen := StrToFloat(tsl.strings[1]);
        FMaterial[mcount-1].AmbientBlue := StrToFloat(tsl.strings[2]);
        if (FMaterial[mcount-1].AmbientRed<>0) or (FMaterial[mcount-1].AmbientGreen<>0) or (FMaterial[mcount-1].AmbientBlue<>0) then FMaterial[mcount-1].IsAmbient := True;
        tsl.Free;

        //TODO: check if there are textures specified for material
      end;

      //read in texture coords data...
      if (pos('TextureFilename', line) = 4) then
      begin
         //l := l + 1;
         line := stringreplace(sl.Strings[l],'TextureFilename','',[rfReplaceAll]);
         line := stringreplace(line,';','',[rfReplaceAll]);
         line := stringreplace(line,'{','',[rfReplaceAll]);
         line := stringreplace(line,'}','',[rfReplaceAll]);
         line := trim(line);
         line := stringreplace(line,'"','',[rfReplaceAll]);
         FMaterial[mcount-1].FileName := line;
         FMaterial[mcount-1].HasTexturemap := true;
      end;

      l := l + 1;
    end;
  end;
  sl.Free;
end;

procedure TDXModel.SaveToFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, fmCreate);
  SaveToStream(stream);
  stream.Free;
end;

procedure TDXModel.SaveToStream(stream: Tstream);
begin
end;

initialization
RegisterModelFormat('x', 'DirectX model', TDXModel);

finalization
UnRegisterModelClass(TDXModel);

end.
