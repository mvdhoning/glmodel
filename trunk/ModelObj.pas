unit ModelObj;

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

//History
//Author  Date        Change
//MvdH    ?           Initial Version Loading of Obj Files
//MvdH    19-01-2009  Added Saving of Obj files

//TODO: error in next model when calculating normals there?

//TODO: Implement Save Load for WaveFront OBJ Files
//http://www.fileformat.info/format/wavefrontobj/
//N:\books\sulaco\wavefront
//http://ozviz.wasp.uwa.edu.au/~pbourke/dataformats/obj/

uses classes, model, glmath;

type
  TObjModel = class(TBaseModel)
    private
      FLastCommand: char;
      FCurrentMatid: integer;

      FVertexRead: integer;
      FNormalRead: integer;
      FMappingRead: integer;

      function GetCoords( S : String) : T3dPoint;
      procedure ReadVertexData(var d: integer; S : String);
      procedure ReadFaceData(var c: integer; ValueS : String);
      procedure ReadMaterialData(MatId: integer; S: String);
      procedure CreateMesh();
    public
      procedure LoadFromFile(AFileName: string); override;
      procedure LoadFromStream(stream: Tstream); override;
      procedure SaveToFile(AFileName: string); override;
      procedure SaveToStream(stream: TStream); override;
  end;

implementation

uses mesh, sysutils;

type
  TFace = packed record
    vertex: array [0..2] of word; //rewrite to xyz
    normal: array [0..2] of word; //rewrite to xyz
  end;

{------------------------------------------------------------------}
{  Gets the X, Y, Z coordinates from a String                      }
{------------------------------------------------------------------}
function TObjModel.GetCoords( S : String) : T3dPoint;
var
  C : T3dPoint;
  tsl: TStringList;

begin
  S :=Trim(Copy(S, 3, Length(S)));

  tsl := TStringList.Create;
  tsl.CommaText := S;

  C.X :=StrToFloat(tsl.Strings[0]);
  C.Y :=StrToFloat(tsl.Strings[1]);
  C.Z :=StrToFloat(tsl.Strings[2]);

  tsl.Free;

  Result :=C;
end;

{-------------------------------------------------------------------}
{  Returns the U, V texture coordinates of a texture from a String  }
{-------------------------------------------------------------------}
function GetTexCoords( S : String) : TMap;
var
  T : TMap;
  tsl: TStringList;

begin
  S :=Trim(Copy(S, 3, Length(S)));

  tsl := TStringList.Create;
  tsl.CommaText := S;

  T.tu :=StrToFloat(tsl.Strings[0]);
  T.tv :=StrToFloat(tsl.Strings[1]);

  tsl.Free;
  Result :=T;
end;

procedure TObjModel.CreateMesh();
begin
  if fnummeshes >0 then
  begin
    FVertexRead:=FVertexRead+FMesh[fnummeshes-1].NumVertex;
    FNormalRead:=FNormalRead+FMesh[fnummeshes-1].NumNormals;
    FMappingRead:=FMappingRead+FMesh[fnummeshes-1].NumMappings;
  end;

  Inc(fnummeshes);
  SetLength(fmesh, fnummeshes+1);
  setlength(FRenderOrder, fnummeshes+1);
  FRenderOrder[fnummeshes - 1] := fnummeshes - 1;
  FMesh[fnummeshes-1] := FMeshClass.Create(self);
  fmesh[fnummeshes-1].Name := 'Mesh-'+IntToStr(fnummeshes);
  fmesh[fnummeshes-1].Visible := true;
end;

procedure TObjModel.ReadMaterialData(MatId: integer; S: String);
var
  C:T3DPoint;
begin
  case UpperCase(S[2])[1] of
    'A' : begin
            C :=GetCoords(S);
            self.Material[MatId].AmbientRed:=C.x;
            self.Material[MatId].AmbientGreen:=C.y;
            self.Material[MatId].AmbientBlue:=C.z;
            self.Material[MatId].IsAmbient := true;
          end;
    'D' : begin
            C :=GetCoords(S);
            self.Material[MatId].DiffuseRed:=C.x;
            self.Material[MatId].DiffuseGreen:=C.y;
            self.Material[MatId].DiffuseBlue:=C.z;
            self.Material[MatId].IsDiffuse:= true;
          end;
    'S' : begin
            if S[1]='K' then
            begin
              C :=GetCoords(S);
              self.Material[MatId].SpecularRed:=C.x;
              self.Material[MatId].SpecularGreen:=C.y;
              self.Material[MatId].SpecularBlue:=C.z;
              self.Material[MatId].IsSpecular:=true;
            end;
            if S[1]='N' then
            begin
              C.x := StrToFloat( Trim(Copy(S, 3, length(S))) );
              self.Material[MatId].Shininess := C.x;
            end;
          end;
    'R' : begin
              C.x := StrToFloat( Trim(Copy(S, 3, length(S))) );
              self.Material[MatId].Transparency := C.x;
          end;
    end;
end;

{------------------------------------------------------------------}
{  Reads Vertex coords, Normals and Texture coords from a String   }
{------------------------------------------------------------------}
procedure TObjModel.ReadVertexData(var d: integer; S : String);
var C : T3dPoint;
    T : TMap;
begin
  case UpperCase(S[2])[1] of
    ' ' : begin                      // Read the vertex coords
            C :=GetCoords(S);
            FMesh[fnummeshes-1].NumVertex := FMesh[fnummeshes-1].NumVertex+1;
            fmesh[fnummeshes-1].Vertex[FMesh[fnummeshes-1].NumVertex-1] :=C;
            //voor iedere vertex reeds een normal toevoegen.
            //FMesh[fnummeshes-1].NumNormals := FMesh[nummeshes-1].NumNormals+1;
            //FMesh[fnummeshes-1].Normals[FMesh[nummeshes-1].NumNormals-1] :=C;

            //FMesh[fnummeshes-1].MatID[ FMesh[fnummeshes-1].NumVertex-1 ] := 0;
          end;

    'N' : begin                      // Read the vertex normals
            C :=GetCoords(S);

            //C.x := C.x * -1;  //test invert normal
            //C.y := C.y * -1;  //test invert normal
            //C.z := C.z * -1;  //test invert normal

            //Inc(M.Normals);
            //SetLength(M.Normal, M.Normals+1);
            FMesh[nummeshes-1].NumNormals := FMesh[nummeshes-1].NumNormals +1;
            FMesh[nummeshes-1].Normals[FMesh[nummeshes-1].NumNormals-1] :=C;

          end;
    'T' : begin
            // Read the vertex texture coords
            T :=GetTexCoords(S);
            FMesh[fnummeshes-1].NumMappings := FMesh[fnummeshes-1].NumMappings + 1;
            FMesh[fnummeshes-1].Mapping[FMesh[fnummeshes-1].NumMappings-1] := T;

          end;

  end;
end;

{------------------------------------------------------------------}
{  Reads the faces/triangles info for the model                    }
{  Data is stored as "f f f" OR "f/t f/t /ft" OR "f/t/n .. f/t/n"  }
{------------------------------------------------------------------}
procedure TObjModel.ReadFaceData(var c: integer;ValueS : String);
var
  P: Integer;
  tsl: TStringList;
  tsl2: TStringList;
  e: integer;
  S : string;

  i: integer;

  first_t: integer;
  first_tt: integer;
  first_tn: integer;

  prev_t: integer;
  prev_tt: integer;
  prev_tn: integer;

  cur_t: integer;
  cur_tt: integer;
  cur_tn: integer;

begin

  //init
  cur_t  := -2; //-1 does not do the trick ...
  cur_tt := -2;
  cur_tn := -2;
  first_t := cur_t;
  first_tt := cur_tt;
  first_tn := cur_tn;
  prev_t := cur_t;
  prev_tt := cur_tt;
  prev_tn := cur_tn;

  //start loading
  P :=Pos(' ', ValueS);

  tsl := TStringList.Create;
  tsl.CommaText := Trim(Copy(ValueS, P+1, length(ValueS)));

  //can result in more then 3 vertexes for a face e.g. 4 or more
  //for vertex 4 you use:
  //the first vertex
  //the previous one read
  //and the 4th.
  //the same goes for beyond 4.

  i:=0;
  for e:=0 to tsl.Count-1 do
  begin


    S:=tsl[e];

    tsl2 := TStringList.Create;
    //what happens with // meanion vertex and normals but no texture coords
    tsl2.Delimiter := '/';
    tsl2.DelimitedText := S;



    case tsl2.Count of
    1:  begin //vertex indices
          cur_t := StrToInt(tsl2[0])-1-FVertexRead; //vertex indice
          cur_tt := 0;
          cur_tn := 0;
          //cur_tt:= StrToInt(tsl2[0])-1-FVertexRead; //texture coord indice
          //cur_tn := StrToInt(tsl2[0])-1-FVertexRead; //normal indice
        end;
    2:  begin //vertex and texture indices
          cur_t := StrToInt(tsl2[0])-1-FVertexRead;
          cur_tt := StrToInt(tsl2[1])-1-FMappingRead;
          cur_tn := 0;
         // cur_tn := StrToInt(tsl2[0])-1-FVertexRead; //normal indice
        end;
    3:  begin //vertex texture and normal indices
        //texure coord maybe not existant
          cur_t := StrToInt(tsl2[0])-1-FVertexRead;

          if tsl2[1] = '' then
            cur_tt:=0
          else
            cur_tt:= StrToInt(tsl2[1])-1-FMappingRead; //check on nil values?
            
          cur_tn:= StrToInt(tsl2[2])-1-FNormalRead;
        end;
    end;

    if i = 0 then
    begin
      first_t := cur_t;
      first_tt := cur_tt;
      first_tn := cur_tn;
    end;

    //TODO: only add normalindices / mappingindices if needed

    if i>=3 then
    begin
      //reconstruct faces for additional index points on face
      c:=c+1;
      FMesh[fnummeshes-1].NumVertexIndices := c;
      FMesh[fnummeshes-1].Face[c-1] := first_t;
      FMesh[fnummeshes-1].NumNormalIndices := c;
      FMesh[fnummeshes-1].Normal[c-1] := first_tn;
      FMesh[fnummeshes-1].NumMappingIndices := c;
      FMesh[fnummeshes-1].Map[c-1] := first_tt;
      if fcurrentmatid >= 0 then FMesh[fnummeshes-1].MatID[ c div 3 ] := fcurrentmatid;


      c:=c+1;
      FMesh[fnummeshes-1].NumVertexIndices := c;
      FMesh[fnummeshes-1].Face[c-1] := prev_t;
      FMesh[fnummeshes-1].NumNormalIndices := c;
      FMesh[fnummeshes-1].Normal[c-1] := prev_tn;
      FMesh[fnummeshes-1].NumMappingIndices := c;
      FMesh[fnummeshes-1].Map[c-1] := prev_tt;
      if fcurrentmatid >= 0 then FMesh[fnummeshes-1].MatID[ c div 3 ] := fcurrentmatid;
    end;


    c:=c+1;
    FMesh[fnummeshes-1].NumVertexIndices := c;
    FMesh[fnummeshes-1].Face[c-1] := cur_t;

    FMesh[fnummeshes-1].NumNormalIndices := c;
    FMesh[fnummeshes-1].Normal[c-1] := cur_tn;

    FMesh[fnummeshes-1].NumMappingIndices := c;
    FMesh[fnummeshes-1].Map[c-1] := cur_tt;

    if fcurrentmatid >= 0 then FMesh[fnummeshes-1].MatID[ c div 3 ] := fcurrentmatid;

    prev_t := cur_t;
    prev_tt := cur_tt;
    prev_tn := cur_tn;

    i:=i+1;

    tsl2.Free;

  end;
  tsl.Free;

end;

procedure TObjModel.LoadFromFile(AFileName: string);
var
  stream: TFilestream;
begin
  FPath := ExtractFilePath(AFilename);
  if FTexturePath = '' then FTexturePath:=FPath;
  stream := TFilestream.Create(AFilename, $0000);
  LoadFromStream(stream);
  stream.Free;
end;

procedure TObjModel.LoadFromStream(stream: Tstream);
var
  sl: TStringList;
  msl: TStringList;
  l, ml: integer;
  line: string;
  line2: string;
  c: integer;
  matcount: integer;
  MatStream: TFileStream;
  loopcount: integer;
  loopadd: integer;

begin

matcount:=0;
fcurrentmatid:=-1;

//TODO: temporary solution until material is implemented...
self.AddMaterial();
//self.Material[0].Name:='Dummy';
self.Material[0].AmbientBlue:=1.0;
self.Material[0].DiffuseBlue:=1.0;
self.Material[0].SpecularBlue:=1.0;
self.Material[0].IsAmbient:=true;
self.Material[0].IsDiffuse:=true;


  FLastCommand:='F';

  FVertexRead:=0;
  FNormalRead:=0;
  FMappingRead:=0;

  sl := TStringList.Create;
  sl.LoadFromStream(stream);

  l := 0;
    c:=0;


  loopcount:=sl.Count;
  while l < loopcount do
  begin
    line := Trim(sl.Strings[l]);

    if (line <> '') AND (line[1] <> '#') then
      begin
        //line :=Uppercase(line);
        case UpperCase(line[1])[1] of
          'M' : begin
                  if line[2] <> 'a' then
                  begin
                  //Could be reference to mtllib;
                  line2 :=Trim(Copy(line, Pos('mtllib',line)+7, length(line)));
                  //load the material lib with name in line2
                  //e.g. determine loading way because if stream being file or virtualfile
                  MatStream := TFileStream.Create(self.FPath+line2,fmopenread);

                  msl:=TStringList.Create;
                  msl.LoadFromStream(MatStream);
                  MatStream.Free;
                  loopadd:=0;
                  for ml:=0 to msl.Count-1 do
                  begin
                    sl.Insert(l+1+loopadd, msl[ml]);
                    loopadd:=loopadd+1;
                    //sl.Add(msl[ml]); //merge with current sl stringlist
                  end;
                  msl.Free;

                  //how do i tell loop that more lines have been added?
                  loopcount:=sl.count;

                  FLastCommand:='F';
                  end
                  else
                  begin
                    //Load texture name
                    line2 :=Trim(Copy(line, Pos('map_Kd',line)+6, length(line)));
                    self.Material[matcount-1].TextureFilename:=line2;
                    self.Material[matcount-1].HasTexturemap:=true;
                  end;
                end;
          'U' : begin
                  //Could be reference to usemtl
                  line2 :=Trim(Copy(line, Pos('usemtl',line)+7, length(line)));
                  //set the current material to name in line2
                  fcurrentmatid := self.GetMaterialIdByName(line2);
                  if fcurrentmatid <> -1 then
                  begin
                    //FMesh[fnummeshes-1].MatID[0]:= fcurrentmatid;
                    FMesh[fnummeshes-1].MatName[0] := line2; //IntToStr(matid);
                  end;
                  FLastCommand:='U';
                end;
          'N' : begin
                  //Could be reference to newmtl
                  if line[2] <> 's' then
                  begin
                  line2 :=Trim(Copy(line, Pos('newmtl',line)+7, length(line)));

                  if matcount >= 1 then //for the first time overwrite dummy
                    self.AddMaterial();
                  self.Material[matcount].Name:=line2;

                  matcount:=matcount+1;
                 end
                 else
                 begin
                    //read specular strenght
                    ReadMaterialData(matcount-1,line);
                 end;

                end;
          'K' : begin
                  //read material line
                  ReadMaterialData(matcount-1,line);
                end;
          'T' : begin
                  //read material line
                  ReadMaterialData(matcount-1,line);
                end;
          'G' : begin
                  line2 :=Trim(Copy(line, 2, length(line)));
                  if fnummeshes>0 then //TODO: sometimes the G elemen apears before the V element?
                    fmesh[fnummeshes-1].Name :=line2;
                  FLastCommand:='G';
                end;
          'V' : begin
                  if (FLastCommand = 'F') or (FLastCommand = 'G') then
                  begin
                    self.CreateMesh();
                    c:=0;
                  end;
                  ReadVertexData(c, line);  // Read Vertex Date (coord, normal, texture)
                  FLastCommand:='V';
                end;
          'F' : begin
                  ReadFaceData(c,line);    // Read faces
                  FLastCommand:='F';
                end;
        end;
      end;

      l:=l+1;

  end;

  fmesh[fnummeshes-1].Visible := true;

  sl.Free;

  CalculateSize;

end;

procedure TObjModel.SaveToFile(AFileName: string);
var
  stream: TFilestream;
begin
  stream := TFilestream.Create(AFilename, fmCreate);
  SaveToStream(stream);
  stream.Free;
end;

procedure TObjModel.SaveToStream(stream: Tstream);
var
  ms: TStringList;
  saveloop: Integer;
  subsaveloop: Integer;
  tempstring: string;
  MatStream: TFileStream;
  mas: TStringList;
begin

  //save material data
  mas := TStringList.Create();
  mas.Add('#Materials: '+IntToStr(FNumMaterials));
  mas.Add('');
  for saveloop:=0 to FNumMaterials-1 do
  begin
    mas.Add('newmtl '+FMaterial[saveloop].name);
    mas.Add('Ka '+FloatToStr(FMaterial[saveloop].AmbientRed)+' '+FloatToStr(FMaterial[saveloop].AmbientGreen)+' '+FloatToStr(FMaterial[saveloop].AmbientBlue)+' 1.0');
    mas.Add('Kd '+FloatToStr(FMaterial[saveloop].DiffuseRed)+' '+FloatToStr(FMaterial[saveloop].DiffuseGreen)+' '+FloatToStr(FMaterial[saveloop].DiffuseBlue)+' '+FloatToStr(FMaterial[saveloop].Transparency));
    mas.Add('Tr '+FLoatToStr(FMaterial[saveloop].Transparency ) );
    mas.Add('Ks '+FloatToStr(FMaterial[saveloop].SpecularRed)+' '+FloatToStr(FMaterial[saveloop].SpecularGreen)+' '+FloatToStr(FMaterial[saveloop].SpecularBlue)+' 1.0');
    mas.Add('Ns '+FLoatToStr(FMaterial[saveloop].Shininess ) );
    if FMaterial[saveloop].FileName <> '' then
      mas.Add('mapKd '+FMaterial[saveloop].filename);
  end;
  mas.Add('');

  MatStream := TFileStream.Create('test.mtl',fmcreate);
  mas.SaveToStream(MatStream);
  MatStream.Free;
  mas.Free;

  //this saves meshes to a wavefront obj file
  ms:=TStringList.Create;

  ms.Add('# WaveFront Obj File');
  ms.Add('mtllib test.mtl'); //TODO: should be dynamic

  //save mesh data
  ms.Add('#Meshes: '+IntToStr(FNumMeshes));

  for saveloop:=0 to FNumMeshes-1 do
  begin
    tempstring:=StringReplace(fmesh[saveloop].name, ' ', '_', [rfReplaceAll]);



    //save vertexes
    ms.Add('#NumVertex: '+inttostr(fmesh[saveloop].numvertex));
    for subsaveloop:=0 to fmesh[saveloop].numvertex -1 do
    begin
      ms.Add('v'+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].x)+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].y)+' '+floattostr(fmesh[saveloop].Vertex[subsaveloop].z));
    end;

    //save vertex uv coords
    ms.Add('#NumUV: '+inttostr(fmesh[saveloop].NumMappings));
    for subsaveloop:=0 to fmesh[saveloop].NumMappings -1 do
    begin
      ms.Add('vt'+' '+floattostr(fmesh[saveloop].Mapping[subsaveloop].tu)+' '+floattostr(fmesh[saveloop].Mapping[subsaveloop].tv)+' 0');
    end;

    //save normals
    ms.Add('#NumNormals: '+inttostr(fmesh[saveloop].NumNormals));
    if fmesh[saveloop].NumNormals > 0 then
    begin
      for subsaveloop:=0 to fmesh[saveloop].NumNormals -1 do
      begin
        ms.Add('vn'+' '+floattostr( fmesh[saveloop].Normals[subsaveloop].x )+' '+floattostr(fmesh[saveloop].Normals[subsaveloop].y)+' '+floattostr(fmesh[saveloop].Normals[subsaveloop].z));
      end;
    end;

    //save material
    if fmesh[saveloop].NumMaterials > 0 then
       ms.Add('usemtl '+fmesh[saveloop].MatName[0] );

    //save faces (indices)
    ms.Add('#NumFaces: '+inttostr(fmesh[saveloop].numvertexindices div 3));
    for subsaveloop:=0 to (fmesh[saveloop].numvertexindices div 3) -1 do
    begin
      begin
        ms.Add('f '
              +IntToStr(fmesh[saveloop].Face[subsaveloop*3]+1)+'/'
              +IntToStr(fmesh[saveloop].Map[subsaveloop*3]+1)+'/'
              +IntToStr(fmesh[saveloop].Normal[subsaveloop*3]+1)
              +' '
              +IntToStr(fmesh[saveloop].Face[subsaveloop*3+1]+1)+'/'
              +IntToStr(fmesh[saveloop].Map[subsaveloop*3+1]+1)+'/'
              +IntToStr(fmesh[saveloop].Normal[subsaveloop*3+1]+1)
              +' '
              +IntToStr(fmesh[saveloop].Face[subsaveloop*3+2]+1)+'/'
              +IntToStr(fmesh[saveloop].Map[subsaveloop*3+2]+1)+'/'
              +IntToStr(fmesh[saveloop].Normal[subsaveloop*3+2]+1)
              );
      end;
    end;
  end;

  ms.SaveToStream(stream);
  ms.Free;
end;

initialization
RegisterModelFormat('obj', 'Alias Wavefront Obj Model', TObjModel);

finalization
UnRegisterModelClass(TObjModel);

end.
