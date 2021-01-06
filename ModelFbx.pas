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
  TFbxModel = class(TBaseModel)
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFileName: string); override;
      procedure SaveToStream(stream: TStream); override;
  end;

implementation

uses
  SysUtils, glMath, Mesh;

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
  n,i,f,l: integer;
  tsl: TStringList;
  tempvertex: T3dPoint;
  tempmap: TMap;
  fbxnumberofvetexindices: integer;
  fbxindicecount: integer;
begin
  sl := TStringList.Create;
  sl.LoadFromStream(stream);

  l := 0;
  n := 0;
  parentkey:='';
  key:='';
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
      if (pos(':',line)>0) then
        begin
          parentkey:= key;
          key:=trim(copy(line,0,pos(':',line)-1));
          value:=trim(copy(line,pos(':',line)+1,length(line)-1));
          //writeln('key   ('+inttostr(n)+') : '+key);

          //do actions on key here
          if key = 'Geometry' then
            begin
              //add a mesh to the model
              self.AddMesh;
              self.Mesh[self.NumMeshes-1].Name:='FbxMesh'+inttostr(self.NumMeshes);
              self.Mesh[self.NumMeshes-1].Visible:=true;
              writeln('Add Mesh');
            end;
          if key='Vertices' then
            begin
              //set number of vetrices in mesh
              self.Mesh[self.FNumMeshes-1].NumVertex:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
              self.Mesh[self.FNumMeshes-1].NumMappings:=self.Mesh[self.FNumMeshes-1].NumVertex;
              writeln('Number of Vertices: '+inttostr(self.Mesh[self.NumMeshes-1].NumVertex));
            end;
          if key='PolygonVertexIndex' then
            begin
              //set number of vetrex indices in mesh
              fbxnumberofvetexindices:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1)));
              writeln('Number of Vertex Indices: '+inttostr(fbxnumberofvetexindices));
            end;
          if key='Normals' then
            begin
              self.Mesh[self.FNumMeshes-1].NumNormals:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1)));
              writeln('Number of Normals: '+inttostr(self.Mesh[self.NumMeshes-1].NumNormals));
            end;
          if key='NormalsIndex' then
            begin
              //Do nothing
            end;
          if key='UV' then
            begin
              self.Mesh[self.FNumMeshes-1].NumMappings:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1)));
              writeln('Number of UV Mappings: '+inttostr(self.Mesh[self.NumMeshes-1].NumMappings));
            end;
          if key='UVIndex' then
            begin
              //Do nothing
            end;
          (*
          if (pos('{',value)>0) then
            begin
              n:=n+1;
              if (pos(',',value)>0) then
                begin
                  value:='comma delimted string followed by subnode';
                end else
                begin
                  value:='subnode';
                end;
            end;
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
          if (key='a') and (parentkey='Vertices') then
                begin
                  writeln('Add Vertices');
                  value:=trim(copy(value,0,pos('}',value)-1)); //trim {
                  tsl := TStringList.Create;
                  tsl.Delimiter:=',';
                  tsl.StrictDelimiter := true;
                  tsl.DelimitedText := StringReplace(value,#13#10,'',[rfReplaceAll]);
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
          if (key='a') and (parentkey='PolygonVertexIndex') then
                begin
                  writeln('Add vertex indices');
                  value:=trim(copy(value,0,pos('}',value)-1)); //trim {
                  tsl := TStringList.Create;
                  tsl.CommaText := value;
                  writeln(tsl.Count);

                  fbxindicecount := 0;
                  for i:=0 to 3 do
                  begin
                    //detect if this is triangles or quad
                    //count until first negative number
                    if (strtoint(tsl[i]) < 0) then break;
                  end;
                  fbxindicecount := i;

                  if fbxindicecount=3 then writeln('quads') else writeln('triangles');

                  //also remember to adjes to total number of vertex indices
                  if fbxindicecount=3 then fbxnumberofvetexindices:=(fbxnumberofvetexindices div 4)*6;
                  self.Mesh[self.FNumMeshes-1].NumVertexIndices:=fbxnumberofvetexindices;
                  writeln('Adjusted number of vertex indices: '+inttostr(fbxnumberofvetexindices));

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
                        self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:=strtoint(tsl[f+0]);
                        self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:=strtoint(tsl[f+1]);
                        self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:=strtoint(tsl[f+2]);
                        self.Mesh[self.NumMeshes-1].VertexIndices[i+3]:=strtoint(tsl[f+2]);
                        //to use the negative number make it positive and subtract 1 from it (xor -1)
                        self.Mesh[self.NumMeshes-1].VertexIndices[i+4]:=strtoint(tsl[f+3]) xor -1;
                        self.Mesh[self.NumMeshes-1].VertexIndices[i+5]:=strtoint(tsl[f+0]);
                      end;
                    if fbxindicecount = 3 then i:=i+6 else i:=i+3;
                    f:=f+fbxindicecount+1;
                  until f >= tsl.count;
                  tsl.Free;
                end;
          if (key='a') and (parentkey='Normals') then
                begin
                  writeln('Add Normals');
                  value:=trim(copy(value,0,pos('}',value)-1)); //trim {
                  tsl := TStringList.Create;
                  tsl.Delimiter:=',';
                  tsl.StrictDelimiter := true;
                  tsl.DelimitedText := StringReplace(value,#13#10,'',[rfReplaceAll]);
                  f:=0;
                  repeat
                    tempvertex := self.Mesh[self.NumMeshes-1].Normals[(f div 3)];
                    tempvertex.x := strtofloat(tsl[f+0]);
                    tempvertex.y := strtofloat(tsl[f+1]);
                    tempvertex.z := strtofloat(tsl[f+2]);
                    self.Mesh[self.NumMeshes-1].Normals[(f div 3)] := tempvertex;
                    f:=f+3;
                  until f >= tsl.count;
                  tsl.Free;
                end;
          if (key='a') and (parentkey='NormalsIndex') then
                begin
                  writeln('Add Normal Indices');
                  value:=trim(copy(value,0,pos('}',value)-1)); //trim {
                  tsl := TStringList.Create;
                  tsl.Delimiter:=',';
                  tsl.StrictDelimiter := true;
                  tsl.DelimitedText := StringReplace(value,#13#10,'',[rfReplaceAll]);
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
          if (key='a') and (parentkey='UV') then
                begin
                  writeln('Add UV mappings');
                  value:=trim(copy(value,0,pos('}',value)-1)); //trim {
                  tsl := TStringList.Create;
                  tsl.Delimiter:=',';
                  tsl.StrictDelimiter := true;
                  tsl.DelimitedText := StringReplace(value,#13#10,'',[rfReplaceAll]);
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
          if (key='a') and (parentkey='UVIndex') then
                begin
                  writeln('Add UV mapping Indices');
                  value:=trim(copy(value,0,pos('}',value)-1)); //trim {
                  tsl := TStringList.Create;
                  tsl.Delimiter:=',';
                  tsl.StrictDelimiter := true;
                  tsl.DelimitedText := StringReplace(value,#13#10,'',[rfReplaceAll]);
                  self.Mesh[self.FNumMeshes-1].NumMappingIndices:=self.Mesh[self.FNumMeshes-1].NumVertexIndices; //set equal to vertex indices
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

