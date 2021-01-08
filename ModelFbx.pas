unit ModelFbx;

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

  TFbxReferenceInformationType = (Direct, IndexToDirect);

  { TFbxModel }

  TFbxModel = class(TBaseModel)
  private
    fbxversion: integer;
    fbxnumberofvetexindices: integer;
    fbxindicecount: integer;
    fbxReferenceInformationType: TFbxReferenceInformationType;
    fbxkeyvaluestoreT: TStringList;
    fbxkeyvaluestoreM: TStringList;
    fbxcurrentname: string;
    procedure AddNormalIndices(value: string);
    procedure AddNormals(value: string);
    procedure AddUVMapping(value: string);
    procedure AddUVMappingIndices(value: string);
    procedure AddVertexIndices(value: string);
    procedure AddVertices(value: string);
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFileName: string); override;
      procedure SaveToStream(stream: TStream); override;
  end;

implementation

uses
  SysUtils, glMath, Mesh;

procedure TFbxModel.AddVertices(value: string);
var
  tsl: TStringList;
  tempvertex: T3dPoint;
  f: integer;
begin
  if fbxversion>=7100 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll]);
  if fbxversion<7100 then self.Mesh[self.FNumMeshes-1].NumVertex := tsl.Count div 3; //set number of vertexes
  f:=0;
  repeat
    tempvertex := self.Mesh[self.NumMeshes-1].Vertex[(f div 3)];
    tempvertex.x := strtofloat(tsl[f+0]);
    tempvertex.y := strtofloat(tsl[f+1]);
    tempvertex.z := strtofloat(tsl[f+2]);
    self.Mesh[self.NumMeshes-1].Vertex[(f div 3)] := tempvertex;
    f:=f+3;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.AddNormals(value: string);
var
  tsl: TStringList;
  tempvertex: T3dPoint;
  f: integer;
begin
  value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(value, #13#10, '', [rfReplaceAll]);
  if fbxversion<7100 then self.Mesh[self.FNumMeshes-1].NumNormals := tsl.Count div 3; //set number of normals
  if FbxReferenceInformationType=Direct then self.Mesh[self.FNumMeshes-1].NumNormalIndices:= self.Mesh[self.FNumMeshes-1].NumVertexIndices; //set equal to vertex indices;
  f:=0;
  repeat
    if FbxReferenceInformationType=Direct then self.Mesh[self.NumMeshes-1].Normal[f div 3]:=f div 3; //make indices as they are not supplied
    tempvertex := self.Mesh[self.NumMeshes-1].Normals[(f div 3)];
    tempvertex.x := strtofloat(tsl[f+0]);
    tempvertex.y := strtofloat(tsl[f+1]);
    tempvertex.z := strtofloat(tsl[f+2]);
    self.Mesh[self.NumMeshes-1].Normals[(f div 3)] := tempvertex;
    f:=f+3;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.AddUVMapping(value: string);
var
  tsl: TStringList;
  f: integer;
  tempmap: TMap;
begin
  if fbxversion>=7100 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll]);
  if fbxversion<7100 then self.Mesh[self.FNumMeshes-1].NumMappings := tsl.Count div 2; //set number of uv mappings
  f:=0;
  repeat
    tempmap := self.Mesh[self.NumMeshes-1].Mapping[f div 2];
    tempmap.tu := strtofloat(tsl[f+0]);
    tempmap.tv := strtofloat(tsl[f+1]);
    self.Mesh[self.NumMeshes-1].Mapping[f div 2]:=tempmap;
    f:=f+2;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.AddUVMappingIndices(value: string);
var
  tsl: TStringList;
  f: integer;
  i: integer;
begin
  value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll]);
  self.Mesh[self.NumMeshes-1].NumMappingIndices:=self.Mesh[self.NumMeshes-1].NumVertexIndices; //set equal to vertex indices
  f:=0;
  i:=0;
  repeat

    if fbxindicecount = 2 then
      begin
        self.Mesh[self.NumMeshes-1].Map[i+0]:=strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].Map[i+1]:=strtoint(tsl[f+1]);
        self.Mesh[self.NumMeshes-1].Map[i+2]:=strtoint(tsl[f+2]);
      end
      else
      begin
        self.Mesh[self.NumMeshes-1].Map[i+0]:=strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].Map[i+1]:=strtoint(tsl[f+1]);
        self.Mesh[self.NumMeshes-1].Map[i+2]:=strtoint(tsl[f+2]);
        self.Mesh[self.NumMeshes-1].Map[i+3]:=strtoint(tsl[f+2]);
        self.Mesh[self.NumMeshes-1].Map[i+4]:=strtoint(tsl[f+3]);
        self.Mesh[self.NumMeshes-1].Map[i+5]:=strtoint(tsl[f+0]);
      end;
    if fbxindicecount = 3 then i:=i+6 else i:=i+3;
    f:=f+fbxindicecount+1;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.AddNormalIndices(value: string);
var
  tsl: TStringList;
  i, f: integer;
begin
  if fbxversion>=7100 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(value, #13#10, '', [rfReplaceAll]);
  self.Mesh[self.FNumMeshes-1].NumNormalIndices:=self.Mesh[self.FNumMeshes-1].NumVertexIndices; //set equal to vertex indices
  f:=0;
  i:=0;
  repeat
    if fbxindicecount = 2 then
    begin
      self.Mesh[self.NumMeshes-1].Normal[i+0]:=strtoint(tsl[f+0]);
      self.Mesh[self.NumMeshes-1].Normal[i+1]:=strtoint(tsl[f+1]);
      self.Mesh[self.NumMeshes-1].Normal[i+2]:=strtoint(tsl[f+2]);
    end
    else
    begin
      self.Mesh[self.NumMeshes-1].Normal[i+0]:=strtoint(tsl[f+0]);
      self.Mesh[self.NumMeshes-1].Normal[i+1]:=strtoint(tsl[f+1]);
      self.Mesh[self.NumMeshes-1].Normal[i+2]:=strtoint(tsl[f+2]);
      self.Mesh[self.NumMeshes-1].Normal[i+3]:=strtoint(tsl[f+2]);
      self.Mesh[self.NumMeshes-1].Normal[i+4]:=strtoint(tsl[f+3]);
      self.Mesh[self.NumMeshes-1].Normal[i+5]:=strtoint(tsl[f+0]);
    end;
    if fbxindicecount = 3 then i:=i+6 else i:=i+3;
    f:=f+fbxindicecount+1;
    until f >= tsl.count;
    tsl.Free;
end;

procedure TFbxModel.AddVertexIndices(value: string);
var
  tsl: TStringList;
  i, f: integer;
begin
  if fbxversion>=7100 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.CommaText := value;
  fbxindicecount := 0;
  for i:=0 to 3 do
  begin
    //detect if this is triangles or quad
    //count until first negative number
    if (strtoint(tsl[i]) < 0) then break;
  end;
  fbxindicecount := i;
  if fbxversion<7100 then fbxnumberofvetexindices := tsl.Count; //set number of vertex indices
  //also remember to adjes to total number of vertex indices
  if fbxindicecount=3 then fbxnumberofvetexindices:=(fbxnumberofvetexindices div 4)*6;
  self.Mesh[self.FNumMeshes-1].NumVertexIndices:= fbxnumberofvetexindices;
  f:=0;
  i:=0;
  repeat
    if fbxindicecount = 2 then
      begin
        self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:=strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:=strtoint(tsl[f+1]);
        //to use the negative number make it positive and subtract 1 from it (xor -1)
        self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:=strtoint(tsl[f+2]) xor -1;
      end
      else
      begin
        //if quads convert to triangles
        self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:= strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:= strtoint(tsl[f+1]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:= strtoint(tsl[f+2]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+3]:= strtoint(tsl[f+2]);
        //to use the negative number make it positive and subtract 1 from it (xor -1)
        self.Mesh[self.NumMeshes-1].VertexIndices[i+4]:= strtoint(tsl[f+3]) xor -1;
        self.Mesh[self.NumMeshes-1].VertexIndices[i+5]:= strtoint(tsl[f+0]);
      end;
    if fbxindicecount = 3 then i:=i+6 else i:=i+3;
    f:=f+fbxindicecount+1;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.LoadFromFile(AFileName: string);
var
  stream: TFilestream;
begin
  FPath := ExtractFilePath(AFilename);
  if FTexturePath = '' then FTexturePath:=FPath;

  stream := TFilestream.Create(AFilename, $0000);
  LoadFromStream(stream);
  stream.Free;

end;

procedure TFbxModel.LoadFromStream(stream: Tstream);
var
  sl: TStringList;
  line: string;
  key,parentkey,parentparentkey: string;
  value: string;
  n,l,i,j,b,k: integer;
  tsl: TStringList;
begin

  fbxkeyvaluestoreT:=TStringList.Create;
  fbxkeyvaluestoreM:=TStringList.Create;

  sl := TStringList.Create;
  sl.LoadFromStream(stream);

  l := 0;
  n := 0;
  parentparentkey:='';
  parentkey:='';
  key:='';
  value:='';
  while l < sl.Count - 1 do
  begin
    line := sl.Strings[l];

    (*
    if (pos(';', line) = 1) then
    begin
      writeln('Found Comment: '+line);
    end;
    *)

      line := sl.Strings[l];

      //previous key value multiline support
      if (pos(':',line)>0) then
      begin
        if (key='Vertices') and (fbxversion<7100) then AddVertices(value);
        if (key='PolygonVertexIndex') and (fbxversion<7100) then AddVertexIndices(value);
        if (key='Normals') and (fbxversion<7100) then AddNormals(value);
        if (key='UV') and (parentkey = 'LayerElementUV') and (fbxversion<7100) then AddUVMapping(value);
        if (key='UVIndex') and (parentkey = 'LayerElementUV') and (fbxversion<7100) then AddUVMappingIndices(value);

        if key='Material' then
        begin
          b:=0;
          if fbxversion>=7100 then b:=1;
          tsl := TStringList.Create;
          tsl.CommaText := value;
          self.AddMaterial;
          self.Material[self.NumMaterials-1].Name:=tsl[b];
          if fbxversion>=7100 then self.Material[self.NumMaterials-1].Id:=strtoint(tsl[0]);
          tsl.free;
        end;

        if (( key='P') and (parentparentkey='Material')) or  (( key='Property') and (parentparentkey='Material')) then
        begin
          b:=3;
          if fbxversion>=7100 then b:=4;
          tsl := TStringList.Create;
          tsl.CommaText := value;
          for i:=0 to tsl.count-1 do
          begin
              case tsl[0] of
              'Specular': begin
                              self.Material[self.NumMaterials-1].SpecularRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].SpecularGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].SpecularBlue:=StrToFloat(tsl[b+2]);
                            end;
              'Ambient': begin
                              self.Material[self.NumMaterials-1].AmbientRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].AmbientGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].AmbientBlue:=StrToFloat(tsl[b+2]);
                            end;
              'Diffuse': begin
                              self.Material[self.NumMaterials-1].DiffuseRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].DiffuseGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].DiffuseBlue:=StrToFloat(tsl[b+2]);
                            end;
              'Emissive': begin
                              self.Material[self.NumMaterials-1].EmissiveRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].EmissiveGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].EmissiveBlue:=StrToFloat(tsl[b+2]);
                            end;
              'Shininess': begin
                              self.Material[self.NumMaterials-1].Shininess:=StrToFloat(tsl[b+0]);
                           end;
              'Opacity': begin
                              self.Material[self.NumMaterials-1].Transparency:=StrToFloat(tsl[b+0]);
                           end;
              end;
          end;
          tsl.free;
        end;

        if key='Texture' then
        begin
          tsl := TStringList.Create;
          tsl.CommaText := value;
          //store texture name soomewhaere
          fbxcurrentname:=tsl[0];
          tsl.free;
        end;

        if ((key='FileName') and (parentparentkey='Texture')) then
        begin
          //TODO: should not use parentparentkey here?
          tsl := TStringList.Create;
          tsl.CommaText := value;
          //store texture name soomewhaere
          fbxkeyvaluestoreT.Values[fbxcurrentname]:=tsl[0];
          tsl.free;
        end;

        if (key='Connect') or ((key='C') and( fbxversion>=7100)) then
        begin
          tsl := TStringList.Create;
          tsl.CommaText := value;


          if fbxversion>=7100 then
          begin
            //map mesh(geometry) to model
            for i:=0 to self.NumMeshes-1 do
            begin
              if self.Mesh[i].Id=strtoint(tsl[1]) then
              begin
                j:=fbxkeyvaluestoreM.IndexOfName(tsl[2]);
                  if j>=0 then
                  begin
                    fbxkeyvaluestoreM.values[tsl[2]]:=inttostr(self.Mesh[i].id);
                  end;
              end;
            end;
          end;

          if fbxversion<7100 then
          begin
            //Map Material to the Correct Mesh
            for i:=0 to self.NumMaterials-1 do
            begin
              if self.Material[i].Name=tsl[1] then
              begin
                for j:=0 to self.NumMeshes-1 do
                begin
                  if self.Mesh[j].Name=tsl[2] then
                  begin
                    self.Mesh[j].MatName[0]:=self.Material[i].Name;
                    self.Mesh[j].MatId[0]:=i;
                  end;
                end;
              end;
            end;
          end else
          begin
            //Map Material to the Correct Mesh
            for i:=0 to self.NumMaterials-1 do
            begin
              if self.Material[i].Id=strtoint(tsl[1]) then
              begin
                  k:=fbxkeyvaluestoreM.IndexOfName(tsl[2]);
                  if k>=0 then
                  begin
                    for j:=0 to self.NumMeshes-1 do
                    begin
                      if self.Mesh[j].Id=strtoint(fbxkeyvaluestoreM.values[tsl[2]]) then
                      begin
                        self.Mesh[j].MatName[0]:=self.Material[i].Name;
                        self.Mesh[j].MatId[0]:=i;
                      end;
                    end;
                  end;
              end;
            end;
          end;

          if fbxversion<7100 then
          begin
            //Map Texture to Material
            i:=fbxkeyvaluestoreT.IndexOfName(tsl[1]);
          if i>=0 then
          begin
            for j:=0 to self.NumMeshes-1 do
            begin
              if self.Mesh[j].Name=tsl[2] then
              begin
                if self.Material[self.Mesh[j].MatID[0]].TextureFilename='' then
                  self.Material[self.Mesh[j].MatID[0]].TextureFilename:=fbxkeyvaluestoreT.values[tsl[1]]
                else
                  self.Material[self.Mesh[j].MatID[0]].BumpMapFilename:=fbxkeyvaluestoreT.values[tsl[1]]; //gets overwritten if more then 2 textures supplied in fbx file per mesh

                if self.FMaterial[self.Mesh[j].MatID[0]].Filename <> '' then self.Material[self.Mesh[j].MatID[0]].Hastexturemap := True;
              end;
            end;
          end;

          end else
          begin

            //Map Texture to Material
            i:=fbxkeyvaluestoreT.IndexOfName(tsl[1]);
            if i>=0 then
            begin
              for j:=0 to self.NumMaterials-1 do
              begin
              if self.Material[j].Id=strtoint(tsl[2]) then
                begin
                  if self.Material[j].TextureFilename='' then
                    self.Material[j].TextureFilename:=fbxkeyvaluestoreT.values[tsl[1]]
                  else
                    self.Material[j].BumpMapFilename:=fbxkeyvaluestoreT.values[tsl[1]]; //gets overwritten if more then 2 textures supplied in fbx file per mesh

                  if self.FMaterial[j].Filename <> '' then self.Material[j].Hastexturemap := True;
                end;
              end;
            end;
          end;

          tsl.free;
        end;

      end;

      if (pos(':',line)>0) then
        begin
          //parentkey:= key;
          key:=trim(copy(line,0,pos(':',line)-1));
          value:=trim(copy(line,pos(':',line)+1,length(line)-1));
          //writeln('key   ('+inttostr(n)+') : '+key);
          //do actions on key here
          if key = 'FBXVersion' then
            begin
              fbxversion:= strtoint(value);
            end;

          if (key = 'Model') and (fbxversion<7100) then
            begin
              //add a mesh to the model
              value:=trim(copy(value,0,pos('{',value)-1)); //trim {
              tsl := TStringList.Create;
              tsl.CommaText := value;
              if tsl.count>1 then //TODO model as key is to generic!! also look at parent key if possible
              if tsl[1] = 'Mesh' then
                begin
                  self.AddMesh;
                  //TODO: read meshname from tsl[0]
                  self.Mesh[self.NumMeshes-1].Name:=tsl[0];//'FbxMesh'+inttostr(self.NumMeshes);
                  self.Mesh[self.NumMeshes-1].Visible:=true;
               end;
              tsl.free;

            end;
          if (key = 'Model') and (fbxversion>=7100) then
          begin
            tsl := TStringList.Create;
            tsl.CommaText := value;
            fbxkeyvaluestoreM.Values[tsl[0]]:=tsl[1];
            tsl.free;
          end;
          if (key = 'Geometry') and (fbxversion>=7100) then
            begin
              //TODO: is the best place?
              //add a mesh to the model
              value:=trim(copy(value,0,pos('{',value)-1)); //trim {
              tsl := TStringList.Create;
              tsl.CommaText := value;
              if tsl[2] = 'Mesh' then
              begin
                self.AddMesh;
                self.Mesh[self.NumMeshes-1].Name:=tsl[1];//'FbxMesh'+inttostr(self.NumMeshes);
                self.Mesh[self.NumMeshes-1].Id:=strtoint(tsl[0]);
                self.Mesh[self.NumMeshes-1].Visible:=true;
              end;
              tsl.free;
            end;

          if key='ReferenceInformationType' then
          begin
            case value of
            'Direct': FbxReferenceInformationType := Direct;
            'IndexToDirect': FbxReferenceInformationType := IndexToDirect;
            end;
          end;
          if (key='Vertices') and (fbxversion>=7100) then
            begin
              //set number of vetrices in mesh
              self.Mesh[self.FNumMeshes-1].NumVertex:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
            end;
          if (key='PolygonVertexIndex') and (fbxversion>=7100) then
            begin
              //set number of vetrex indices in mesh
              fbxnumberofvetexindices:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1)));
            end;
          if (key='Normals') and (fbxversion>=7100) then
            begin
              self.Mesh[self.FNumMeshes-1].NumNormals:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
            end;
          if (key='NormalsIndex') and (fbxversion>=7100) then
            begin
              //Do nothing
            end;
          if (key='UV') and (fbxversion>=7100) then
            begin
              self.Mesh[self.FNumMeshes-1].NumMappings:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 2;
            end;
          if (key='UVIndex') and (fbxversion>=7100) then
            begin
              //Do nothing
            end;


          if (pos('{',value)>0) then
            begin
              n:=n+1;
              parentparentkey:=parentkey;
              parentkey:=key;
              (*
              if (pos(',',value)>0) then
                begin
                  value:='comma delimted string followed by subnode';
                end else
                begin
                  value:='subnode';
                end;
              *)
            end;
          (*
          if (pos(',',value)>0) then
            begin

            end;
          *)
        end else
        begin
          //also read remainder of value
          value:=value+line;
        end;



      if (pos('}',line)>0) then
        begin
          n:=n-1;

          //do actions on value here
          if (key='a') and (parentkey='Vertices') then AddVertices(value);
          if (key='a') and (parentkey='PolygonVertexIndex') then AddVertexIndices(value);
          if (key='a') and (parentkey='Normals') then AddNormals(value);
          if (key='a') and (parentkey='NormalsIndex') then
          begin
            AddNormalIndices(value);
            //prevent parsing twice
            key:=parentkey;
            value:='';
          end;
          if (key='a') and (parentkey='UV') then AddUVMapping(value);
          if (key='a') and (parentkey='UVIndex') then
          begin
            AddUVMappingIndices(value);
            //prevent parsing twice
            key:=parentkey;
            value:='';
          end;

        end;
      l:=l+1;

  end;

  sl.Free;
  fbxkeyvaluestoreM.Free;
  fbxkeyvaluestoreT.Free;
end;

procedure TFbxModel.SaveToFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, fmCreate);
  SaveToStream(stream);
  stream.Free;
end;

procedure TFbxModel.SaveToStream(stream: Tstream);
begin
  //TODO implement
end;

initialization
RegisterModelFormat('fbx', 'Autodesk FilmBox', TFbxModel);

finalization
UnRegisterModelClass(TFbxModel);

end.

