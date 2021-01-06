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

  { TFbxModel }

  TFbxModel = class(TBaseModel)
  private
    fbxversion: integer;
    fbxnumberofvetexindices: integer;
    fbxindicecount: integer;
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

  writeln('Add Vertices');
  if fbxversion>=7300 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  //writeln('*'+StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll])+'*');
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll]);
  //writeln(tsl.count);
  if fbxversion=6100 then self.Mesh[self.FNumMeshes-1].NumVertex := tsl.Count div 3; //set number of vertexes
  writeln('Number of Vertices: '+inttostr(self.Mesh[self.NumMeshes-1].NumVertex));
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
  writeln('Add Normals');
  value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(value, #13#10, '', [rfReplaceAll]);
  if fbxversion=6100 then self.Mesh[self.FNumMeshes-1].NumNormals := tsl.Count div 3; //set number of normals
  if fbxversion=6100 then self.Mesh[self.FNumMeshes-1].NumNormalIndices:= self.Mesh[self.FNumMeshes-1].NumVertexIndices; //set equal to vertex indices;
  f:=0;
  repeat
    if fbxversion=6100 then self.Mesh[self.NumMeshes-1].Normal[f div 3]:=f div 3;
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
  writeln('Add UV mappings');
  if fbxversion>=7300 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll]);
  if fbxversion=6100 then self.Mesh[self.FNumMeshes-1].NumMappings := tsl.Count div 2; //set number of uv mappings
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
  writeln('Add UV mapping Indices');
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
  writeln('Add Normal Indices');
  if fbxversion>=7300 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
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
  writeln('Add vertex indices');
  if fbxversion>=7300 then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
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

  if fbxindicecount=3 then writeln('quads') else writeln('triangles');

  if fbxversion=6100 then fbxnumberofvetexindices := tsl.Count; //set number of vertex indices
  //also remember to adjes to total number of vertex indices
  if fbxindicecount=3 then fbxnumberofvetexindices:=(fbxnumberofvetexindices div 4)*6;
  self.Mesh[self.FNumMeshes-1].NumVertexIndices:= fbxnumberofvetexindices;
  writeln('Adjusted number of vertex indices: '+inttostr(fbxnumberofvetexindices));
  writeln('Number of Vertex Indices: '+inttostr(fbxnumberofvetexindices));

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
  key,parentkey: string;
  value: string;
  n,l: integer;
  tsl: TStringList;
begin
  sl := TStringList.Create;
  sl.LoadFromStream(stream);

  l := 0;
  n := 0;
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
        if (key='Vertices') and (fbxversion=6100) then AddVertices(value);
        if (key='PolygonVertexIndex') and (fbxversion=6100) then AddVertexIndices(value);
        if (key='Normals') and (fbxversion=6100) then AddNormals(value);
        if (key='UV') and (parentkey = 'LayerElementUV') and (fbxversion=6100) then AddUVMapping(value);
        //if (key='UVIndex') and (parentkey = 'LayerElementUV') and (fbxversion=6100) then AddUVMappingIndices(value);
      end;

      if (pos(':',line)>0) then
        begin
          //parentkey:= key;
          key:=trim(copy(line,0,pos(':',line)-1));
          value:=trim(copy(line,pos(':',line)+1,length(line)-1));
          //writeln('key   ('+inttostr(n)+') : '+key);
          //writeln(value);
          //do actions on key here
          if key = 'FBXVersion' then
            begin
              writeln(value);
              fbxversion:= strtoint(value);
            end;
          if key = 'Model' then
            begin
              //add a mesh to the model
              value:=trim(copy(value,0,pos('{',value)-1)); //trim {
              tsl := TStringList.Create;
              tsl.CommaText := value;
              //for i:=0 to tsl.count-1 do
              //begin
              //  writeln(tsl[i]);
              //end;
              if tsl.count>1 then //TODO model as key is to generic!! also look at parent key if possible
              if tsl[1] = 'Mesh' then
                begin
                  self.AddMesh;
                  //TODO: read meshname from tsl[0]
                  self.Mesh[self.NumMeshes-1].Name:=tsl[0];//'FbxMesh'+inttostr(self.NumMeshes);
                  self.Mesh[self.NumMeshes-1].Visible:=true;
                  writeln('Add Mesh '+ tsl[0]);
               end;
              tsl.free;

            end;
          if key = 'Geometry' then
            begin
              //TODO: is the best place?
              //add a mesh to the model
              value:=trim(copy(value,0,pos('{',value)-1)); //trim {
              tsl := TStringList.Create;
              tsl.CommaText := value;
              if tsl[2] = 'Mesh' then
              begin
                self.AddMesh;
                writeln(value);
                self.Mesh[self.NumMeshes-1].Name:=tsl[1];//'FbxMesh'+inttostr(self.NumMeshes);
                self.Mesh[self.NumMeshes-1].Visible:=true;
                writeln('Add Mesh' + tsl[1] +' ('+ tsl[0]+')');
              end;
              tsl.free;
            end;
          //writeln('FBXVERSION: '+inttostr(fbxversion));

          (*
          if ((key='Vertices') and (fbxversion=6100)) then
          begin
            writeln('vertices 6100');
            writeln(value);
          end;

          if ((key='PolygonVertexIndex') and (fbxversion=6100)) then
          begin
            writeln('PolygonVertexIndex 6100');
            writeln(value);
          end;
          *)
          if key='ReferenceInformationType' then
          begin
            writeln(key + ': '+ value);
            //todo: use this to determine if data is indexed or not (do not use fbxfileformat for this !!!)
            //Direct: no indices supplied
            //IndexToDerict: inidces are supplied
          end;
          if (key='Vertices') and (fbxversion>=7300) then
            begin
              //set number of vetrices in mesh
              self.Mesh[self.FNumMeshes-1].NumVertex:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
              //self.Mesh[self.FNumMeshes-1].NumMappings:=self.Mesh[self.FNumMeshes-1].NumVertex;
              writeln('Number of Vertices: '+inttostr(self.Mesh[self.NumMeshes-1].NumVertex));
            end;
          if (key='PolygonVertexIndex') and (fbxversion>=7300) then
            begin
              //set number of vetrex indices in mesh
              fbxnumberofvetexindices:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1)));
              writeln('Number of Vertex Indices: '+inttostr(fbxnumberofvetexindices));
            end;
          if (key='Normals') and (fbxversion>=7300) then
            begin
              self.Mesh[self.FNumMeshes-1].NumNormals:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
              writeln('Number of Normals: '+inttostr(self.Mesh[self.NumMeshes-1].NumNormals));
            end;
          if (key='NormalsIndex') and (fbxversion>=7300) then
            begin
              //Do nothing
            end;
          if (key='UV') and (fbxversion>=7300) then
            begin
              self.Mesh[self.FNumMeshes-1].NumMappings:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 2;
              writeln('Number of UV Mappings: '+inttostr(self.Mesh[self.NumMeshes-1].NumMappings));
            end;
          if (key='UVIndex') and (fbxversion>=7300) then
            begin
              //Do nothing
            end;

          if (pos('{',value)>0) then
            begin
              n:=n+1;
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
          //does this belong here?
          if (key='UVIndex') and (parentkey = 'LayerElementUV') and (fbxversion=6100) then AddUVMappingIndices(value);
        end;
      l:=l+1;

  end;

  sl.Free;
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

