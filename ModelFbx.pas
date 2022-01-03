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

//compatibility for FPC
{$IFDEF FPC}
  {$MODE Delphi}
  {$H+}
  {$M+}
  {$codepage utf8}
{$ENDIF}

interface

uses classes, Model, Generics.Collections, Generics.Helpers;

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
    fbxkeyvaluestoreB: TStringList;
    fbxkeyvaluestoreD: TStringList;
    fbxkeyvaluestoreA: TStringList;
    fbxindexinfo: TDictionary<integer, boolean>;
    fbxcurrentname: string;
    fbxmesh: boolean;
    fbxbone: boolean;
    fbxtime: boolean;
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
  SysUtils, StrUtils, glMath, Mesh, math, Animation, keyframe;

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
    self.Mesh[self.NumMeshes-1].BoneId[f div 3, 0] := -1;
    f:=f+3;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.AddNormals(value: string);
var
  tsl: TStringList;
  tempvertex: T3dPoint;
  f,i: integer;
begin
  if (pos('}',value)>0) then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {
  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := trim(StringReplace(value, #13#10, '', [rfReplaceAll]));
  if fbxversion<7100 then self.Mesh[self.FNumMeshes-1].NumNormals := tsl.Count div 3; //set number of normals
  if FbxReferenceInformationType=Direct then self.Mesh[self.FNumMeshes-1].NumNormalIndices:= self.Mesh[self.FNumMeshes-1].NumVertexIndices; //set equal to vertex indices;

  //add normal entries
  f:=0;
  i:=0;
  repeat
    tempvertex := self.Mesh[self.NumMeshes-1].Normals[(f div 3)];
    tempvertex.x := strtofloat(tsl[f+0]);
    tempvertex.y := strtofloat(tsl[f+1]);
    tempvertex.z := strtofloat(tsl[f+2]);
    self.Mesh[self.NumMeshes-1].Normals[(f div 3)] := tempvertex;
    f:=f+3;
    i:=i+1;
  until f >= tsl.count;

  //add direct normals (also add remapped indices)
  if FbxReferenceInformationType=Direct then
  begin
    f:=0;
    i:=0;
    repeat
      if fbxindexinfo[f] then
      begin
        self.Mesh[self.NumMeshes-1].Normal[i+0]:=f+0;
        self.Mesh[self.NumMeshes-1].Normal[i+1]:=f+1;
        self.Mesh[self.NumMeshes-1].Normal[i+2]:=f+2;
        i:=i+3;
        f:=f+3;
      end
      else
      begin
        self.Mesh[self.NumMeshes-1].Normal[i+0]:=f+0;
        self.Mesh[self.NumMeshes-1].Normal[i+1]:=f+1;
        self.Mesh[self.NumMeshes-1].Normal[i+2]:=f+2;
        self.Mesh[self.NumMeshes-1].Normal[i+3]:=f+2;
        self.Mesh[self.NumMeshes-1].Normal[i+4]:=f+3;
        self.Mesh[self.NumMeshes-1].Normal[i+5]:=f+0;
        i:=i+6;
        f:=f+4;
      end;
    until i >= self.Mesh[self.FNumMeshes-1].NumNormalIndices-1;
  end;
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
  tsl,tsl2: TStringList;
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

    if fbxindexinfo[f] then
      begin
        self.Mesh[self.NumMeshes-1].Map[i+0]:=strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].Map[i+1]:=strtoint(tsl[f+1]);
        self.Mesh[self.NumMeshes-1].Map[i+2]:=strtoint(tsl[f+2]);
        i:=i+3;
        f:=f+3;
      end
      else
      begin
        self.Mesh[self.NumMeshes-1].Map[i+0]:=strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].Map[i+1]:=strtoint(tsl[f+1]);
        self.Mesh[self.NumMeshes-1].Map[i+2]:=strtoint(tsl[f+2]);
        self.Mesh[self.NumMeshes-1].Map[i+3]:=strtoint(tsl[f+2]);
        self.Mesh[self.NumMeshes-1].Map[i+4]:=strtoint(tsl[f+3]);
        self.Mesh[self.NumMeshes-1].Map[i+5]:=strtoint(tsl[f+0]);
        i:=i+6;
        f:=f+4;
      end;
    //if fbxindicecount = 3 then i:=i+6 else i:=i+3;
    //f:=f+fbxindicecount+1;
  until f >= tsl.count;
  tsl.Free;
end;

procedure TFbxModel.AddNormalIndices(value: string);
var
  tsl: TStringList;
  i, f: integer;
begin
  if (pos('}',value)>0) then value:=trim(copy(value, 0, pos('}', value)-1)); //trim {

  tsl := TStringList.Create;
  tsl.Delimiter:=',';
  tsl.StrictDelimiter := true;
  tsl.DelimitedText := StringReplace(StringReplace(value, #13#10, '', [rfReplaceAll]), ' ', '', [rfReplaceAll]);

  self.Mesh[self.FNumMeshes-1].NumNormalIndices:=self.Mesh[self.FNumMeshes-1].NumVertexIndices; //set equal to vertex indices
  f:=0;
  i:=0;
  repeat
    //if fbxindicecount = 2 then

    if fbxindexinfo[f] then
    begin
      self.Mesh[self.NumMeshes-1].Normal[i+0]:=strtoint(tsl[f+0]);
      self.Mesh[self.NumMeshes-1].Normal[i+1]:=strtoint(tsl[f+1]);
      self.Mesh[self.NumMeshes-1].Normal[i+2]:=strtoint(tsl[f+2]);
      i:=i+3;
      f:=f+3;
    end
    else
    begin
      self.Mesh[self.NumMeshes-1].Normal[i+0]:=strtoint(tsl[f+0]);
      self.Mesh[self.NumMeshes-1].Normal[i+1]:=strtoint(tsl[f+1]);
      self.Mesh[self.NumMeshes-1].Normal[i+2]:=strtoint(tsl[f+2]);
      self.Mesh[self.NumMeshes-1].Normal[i+3]:=strtoint(tsl[f+2]);
      self.Mesh[self.NumMeshes-1].Normal[i+4]:=strtoint(tsl[f+3]);
      self.Mesh[self.NumMeshes-1].Normal[i+5]:=strtoint(tsl[f+0]);
      i:=i+6;
      f:=f+4;
    end;
    //if fbxindicecount = 3 then i:=i+6 else i:=i+3;
    //f:=f+fbxindicecount+1;
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

  (*
  fbxindicecount := 0;
  for i:=0 to 3 do
  begin
    //detect if this is triangles or quad
    //count until first negative number
    if (strtoint(tsl[i]) < 0) then break;
  end;
  fbxindicecount := i;
  *)

  if fbxversion<7100 then fbxnumberofvetexindices := tsl.Count; //set number of vertex indices
  (*
  //also remember to adjust the total number of vertex indices
  if fbxindicecount=3 then fbxnumberofvetexindices:=(fbxnumberofvetexindices div 4)*6;
  self.Mesh[self.FNumMeshes-1].NumVertexIndices:= fbxnumberofvetexindices;
  *)

  //calculate new number of indices needed
  f:=0;
  i:=0;
  repeat
    //self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:=strtoint(tsl[f+0]);
    //self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:=strtoint(tsl[f+1]);
    if (strtoint(tsl[f+2]) < 0) then
    begin //triangle
      //to use the negative number make it positive and subtract 1 from it (xor -1)
      //self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:=strtoint(tsl[f+2]) xor -1;
      fbxindexinfo.add(f,true);
      //fbxindexinfo[f]:=true;
      i:=i+3;
      f:=f+3;
    end
    else
    begin //quad
      //self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:= strtoint(tsl[f+2]);
      //self.Mesh[self.NumMeshes-1].VertexIndices[i+3]:= strtoint(tsl[f+2]);
      //to use the negative number make it positive and subtract 1 from it (xor -1)
      //self.Mesh[self.NumMeshes-1].VertexIndices[i+4]:= strtoint(tsl[f+3]) xor -1;
      //self.Mesh[self.NumMeshes-1].VertexIndices[i+5]:= strtoint(tsl[f+0]);
      fbxindexinfo.add(f,false);
      //fbxindexinfo[f]:=false;
      i:=i+6;
      f:=f+4;
    end;
  until f >= tsl.count;

  fbxnumberofvetexindices := i;
  self.Mesh[self.FNumMeshes-1].NumVertexIndices:= fbxnumberofvetexindices;

  f:=0;
  i:=0;
  repeat
    self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:=strtoint(tsl[f+0]);
    self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:=strtoint(tsl[f+1]);

    //TODO: support polygons of any size and triangulate them ;-) not only triangles or quads
    if (strtoint(tsl[f+2]) < 0) then
    begin //triangle
      //to use the negative number make it positive and subtract 1 from it (xor -1)
      self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:=strtoint(tsl[f+2]) xor -1;
      i:=i+3;
      f:=f+3;
    end
    else
    begin //quad
      self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:= strtoint(tsl[f+2]);
      self.Mesh[self.NumMeshes-1].VertexIndices[i+3]:= strtoint(tsl[f+2]);
      //to use the negative number make it positive and subtract 1 from it (xor -1)
      self.Mesh[self.NumMeshes-1].VertexIndices[i+4]:= strtoint(tsl[f+3]) xor -1;
      self.Mesh[self.NumMeshes-1].VertexIndices[i+5]:= strtoint(tsl[f+0]);
      i:=i+6;
      f:=f+4;
    end;
    (*
    if fbxindicecount = 2 then
      begin
        self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:=strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:=strtoint(tsl[f+1]);
        //to use the negative number make it positive and subtract 1 from it (xor -1)
        self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:=strtoint(tsl[f+2]) xor -1;
      end
      else
      begin
        writeln('NumVertexIndices: '+inttostr(self.Mesh[self.Nummeshes-1].NumVertexIndices));
        writeln('CVI: '+inttostr(i+2));
        writeln('COUNT: '+inttostr(tsl.Count));
        writeln('F: '+inttostr(i+2));
        writeln('value:'+tsl[f+2]);
        //if quads convert to triangles
        self.Mesh[self.NumMeshes-1].VertexIndices[i+0]:= strtoint(tsl[f+0]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+1]:= strtoint(tsl[f+1]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+2]:= strtoint(tsl[f+2]);
        self.Mesh[self.NumMeshes-1].VertexIndices[i+3]:= strtoint(tsl[f+2]);
        //to use the negative number make it positive and subtract 1 from it (xor -1)
        self.Mesh[self.NumMeshes-1].VertexIndices[i+4]:= strtoint(tsl[f+3]) xor -1;
        self.Mesh[self.NumMeshes-1].VertexIndices[i+5]:= strtoint(tsl[f+0]);
      end;
    *)
    //if fbxindicecount = 3 then i:=i+6 else i:=i+3;
    //f:=f+fbxindicecount+1;
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
  writeln('End Load FBX from stream: ');
  writeln(self.fAnimation[0].Name);
  writeln(self.Animation[0].Name);
  stream.Free;

end;

procedure TFbxModel.LoadFromStream(stream: Tstream);
var
  sl: TStringList;
  line: string;
  key,parentkey,parentparentkey: string;
  value: string;
  n,l,i,j,b,k,loop,loop2: integer;
  tsl,tsl2: TStringList;
  tempvertex: T3DPoint;
  //tempm: array [0..15] of single;
  fbxcurrentdeformer{,tempms}: string;
  fbxcurrentannimationcurvenode: string;
  fbxcurrentannimationcurve: string;
  tempkeyframe: TKeyFrame;
  currentelement: integer;
begin

  fbxkeyvaluestoreT:=TStringList.Create;
  fbxkeyvaluestoreM:=TStringList.Create;
  fbxkeyvaluestoreB:=TStringList.Create;
  fbxkeyvaluestoreD:=TStringList.Create;
  fbxkeyvaluestoreA:=TStringList.Create;
  fbxindexinfo:=TDictionary<integer, boolean>.Create;

  self.AddSkeleton; //TODO: make adding skeleton optionsl

  //Add Animation to Model //TODO: reconsider making adding animation optional

  setlength(self.fAnimation,1);
  self.fAnimation[0]:=TBaseAnimationController.Create(self);
  self.fAnimation[0].Name:='Default';

  sl := TStringList.Create;
  sl.LoadFromStream(stream);

  l := 0;
  n := 0;
  currentelement:=0;
  fbxcurrentdeformer:='';
  parentparentkey:='';
  parentkey:='';
  key:='';
  value:='';
  fbxmesh:=false;
  fbxbone:=false;
  while l < sl.Count - 1 do
  begin
    line := sl.Strings[l];
    line := sl.Strings[l];

    //previous key value multiline support
    if (pos(':',line)>0) then
    begin

      if key='AnimationStack' then
      begin
        tsl := TStringList.Create;
        tsl.CommaText := value;

        setlength(self.fAnimation,length(self.fAnimation)+1);
        self.fAnimation[length(self.fAnimation)-1]:=TBaseAnimationController.Create(self);
        self.fAnimation[length(self.fAnimation)-1].Name:=tsl[1];
        writeln(self.fAnimation[0].Name);

        fbxKeyvaluestoreA.Values[tsl[0]+'STACK']:=tsl[1];
        writeln('Added animation stack: '+fbxKeyvaluestoreA.Values[tsl[0]+'STACK']);
        tsl.Free;
      end;

      if key='AnimationLayer' then
      begin
        tsl := TStringList.Create;
        tsl.CommaText := value;
        fbxKeyvaluestoreA.Values[tsl[0]+'LAYER']:=tsl[1];
        writeln('Added animation layer: '+fbxKeyvaluestoreA.Values[tsl[0]+'LAYER']);
        tsl.Free;
      end;

      if key='AnimationCurveNode' then
      begin
        tsl := TStringList.Create;
        tsl.CommaText := value;
        fbxcurrentannimationcurvenode:=tsl[0];
        if tsl[1] = 'AnimCurveNode::T' then
           fbxKeyvaluestoreA.Values[tsl[0]+'TNODE']:=tsl[1];
        if tsl[1] = 'AnimCurveNode::R' then
           fbxKeyvaluestoreA.Values[tsl[0]+'RNODE']:=tsl[1];
        if tsl[1] = 'AnimCurveNode::DeformPercent' then
          fbxcurrentannimationcurvenode:='';
        if tsl[1] = 'AnimCurveNode::S' then
          fbxcurrentannimationcurvenode:='';

        //writeln('Added animation curve node: '+fbxKeyvaluestoreA.Values[tsl[0]+'NODE']);
        tsl.Free;
      end;

      if (fbxcurrentannimationcurvenode<>'') and (key='P') then
      begin
        tsl := TStringList.Create;
        tsl.CommaText := value;
        fbxKeyvaluestoreA.Values[fbxcurrentannimationcurvenode+tsl[0]]:=tsl[4];
        //writeln('Added animation curve node data: '+tsl[0]+' '+fbxKeyvaluestoreA.Values[fbxcurrentannimationcurvenode+tsl[0]]);
        tsl.Free;
      end;

      if key='AnimationCurve' then
      begin
        tsl := TStringList.Create;
        tsl.CommaText := value;
        fbxKeyvaluestoreA.Values[tsl[0]+'CURVE']:=tsl[1];
        fbxcurrentannimationcurve:=tsl[0];

        writeln('Added animation curve: '+fbxKeyvaluestoreA.Values[tsl[0]+'CURVE']);
        tsl.Free;
      end;


      if (fbxcurrentannimationcurve<>'') and (parentkey='KeyTime') and (key='a') then
      begin
        if fbxversion>=7100 then value:=trim(copy(value, 0, pos('}', value)-1));
        //writeln(value);
        fbxKeyvaluestoreA.Values[fbxcurrentannimationcurve+'TIME']:=value;
        //writeln('Added animation curve data: TIME '+fbxKeyvaluestoreA.Values[fbxcurrentannimationcurvenode+'TIME']);
      end;

      if (fbxcurrentannimationcurve<>'') and (parentkey='KeyValueFloat') and (key='a') then
      begin
        if fbxversion>=7100 then value:=trim(copy(value, 0, pos('}', value)-1));
        writeln('fbxcurrentannimationcurvenode: '+ fbxcurrentannimationcurve);
        write(fbxcurrentannimationcurve+'FLOAT: ');
        writeln(value);

        //TODO: count elements in values as that is the number of frames in the animation

        fbxKeyvaluestoreA.Values[fbxcurrentannimationcurve+'FLOAT']:=value;
        //writeln('Added animation curve data: FLOAT '+fbxKeyvaluestoreA.Values[fbxcurrentannimationcurvenode+'TIME']);
      end;

      if key='ReferenceInformationType' then
      begin
        value:=StringReplace(value, '"', '', [rfReplaceAll]);
        case AnsiIndexStr(value, ['Direct','IndexToDirect'] ) of
          0: FbxReferenceInformationType := Direct;
          1: FbxReferenceInformationType := IndexToDirect;
        end;
      end;

      if (key='Vertices') and (fbxversion<7100) then AddVertices(value);
      if (key='PolygonVertexIndex') and (fbxversion<7100) then AddVertexIndices(value);
      if (key='Normals') and (fbxversion<7100) then AddNormals(value);
      if (key='NormalsIndex') and (fbxversion<7100) then AddNormalIndices(value);
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

      if key = 'Deformer' then
        begin
          b:=0;
          if fbxversion>=7100 then b:=1;
          tsl := TStringList.Create;
          tsl.CommaText := value;

          if tsl[b+1]='Skin' then
            begin
              Writeln('Found Skin '+ tsl[0]);
              fbxkeyvaluestoreD.Values['skin'+tsl[0]]:='-1';
            end;

          if tsl[b+1]='Cluster' then
            begin
              Writeln('Found Deformer Cluster '+ tsl[0]);
              fbxkeyvaluestoreD.Values['cluster'+tsl[0]]:='-1';
              fbxcurrentdeformer:=tsl[0];
            end else
              fbxcurrentdeformer:='';
          tsl.free;
        end;

      //if (key = 'Transform') and (parentparentkey = 'Deformer') then
      //  begin
      //    fbxkeyvaluestoreD.Values[fbxcurrentdeformer]:=value;
      //  end;

      if (key = 'Indexes') and (fbxcurrentdeformer<>'') then
        begin
          writeln('Bone indexes for '+fbxcurrentdeformer);
          fbxkeyvaluestoreD.Values['indexes'+fbxcurrentdeformer]:=value;
        end;

      if (key = 'a') and (parentkey='Indexes') and (fbxcurrentdeformer<>'') then
        begin
          writeln('Bone indexes for '+fbxcurrentdeformer);
          fbxkeyvaluestoreD.Values['indexes'+fbxcurrentdeformer]:=value;
        end;

      if (key = 'Weights') and (fbxcurrentdeformer<>'') then
        begin
          writeln('Bone weights for '+fbxcurrentdeformer);
          fbxkeyvaluestoreD.Values['weights'+fbxcurrentdeformer]:=value;
        end;

      if (key = 'a') and  (parentkey = 'Weights') and (fbxcurrentdeformer<>'') then
        begin
          writeln('Bone weights for '+fbxcurrentdeformer);
          fbxkeyvaluestoreD.Values['weights'+fbxcurrentdeformer]:=value;
        end;

      if (fbxbone and ( key='P') and (parentparentkey='Model')) or (fbxbone and ( key='Property') {and (parentparentkey='Model')}) then
        begin
          tsl := TStringList.Create;
          tsl.CommaText := value;
          if fbxversion>=7100 then b:=4 else b:=3;

          if tsl[0]='Lcl Rotation' then
          begin
            tempvertex := self.Skeleton[0].Bone[self.Skeleton[0].numBones-1].Rotate;
            tempvertex.x := degtorad(StrToFloat(tsl.strings[b+0]));
            tempvertex.y := degtorad(StrToFloat(tsl.strings[b+1]));
            tempvertex.z := degtorad(StrToFloat(tsl.strings[b+2]));
            self.Skeleton[0].Bone[self.Skeleton[0].numBones-1].Rotate := tempvertex;
          end;

          if tsl[0]='Lcl Translation' then
          begin
            tempvertex := self.Skeleton[0].Bone[self.Skeleton[0].numBones-1].Translate;
            tempvertex.x := StrToFloat(tsl.strings[b+0]);
            tempvertex.y := StrToFloat(tsl.strings[b+1]);
            tempvertex.z := StrToFloat(tsl.strings[b+2]);
            self.Skeleton[0].Bone[self.Skeleton[0].numBones-1].Translate := tempvertex;
          end;

          b:=0;

          tsl.Free;
        end;

      if (( key='P') and (parentparentkey='Material')) or  (( key='Property') and (parentparentkey='Material')) then
        begin
          b:=3;
          if fbxversion>=7100 then b:=4;
          tsl := TStringList.Create;
          tsl.CommaText := value;
          for i:=0 to tsl.count-1 do
          begin
              case AnsiIndexStr(tsl[0], ['Specular', 'Ambient', 'Diffuse', 'Emissive', 'Shininess', 'Opacity']) of
              0: begin
                              self.Material[self.NumMaterials-1].SpecularRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].SpecularGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].SpecularBlue:=StrToFloat(tsl[b+2]);
                            end;
              1: begin
                              self.Material[self.NumMaterials-1].AmbientRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].AmbientGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].AmbientBlue:=StrToFloat(tsl[b+2]);
                            end;
              2: begin
                              self.Material[self.NumMaterials-1].DiffuseRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].DiffuseGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].DiffuseBlue:=StrToFloat(tsl[b+2]);
                            end;
              3: begin
                              self.Material[self.NumMaterials-1].EmissiveRed:=StrToFloat(tsl[b+0]);
                              self.Material[self.NumMaterials-1].EmissiveGreen:=StrToFloat(tsl[b+1]);
                              self.Material[self.NumMaterials-1].EmissiveBlue:=StrToFloat(tsl[b+2]);
                            end;
              4: begin
                              self.Material[self.NumMaterials-1].Shininess:=StrToFloat(tsl[b+0]);
                           end;
              5: begin
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


          if fbxversion<7100 then
            begin
            end
          else
            begin

              //map subdeformer to deformer
              k:=fbxkeyvaluestoreD.IndexOfName('cluster'+tsl[1]);
              i:=fbxkeyvaluestoreD.IndexOfName('skin'+tsl[2]);
              if (i>0) and (k>0) then
                begin
                  //Writeln('Map subdeformer '+tsl[1]+' to deformer '+tsl[2]);
                  fbxkeyvaluestoreD.Values['cluster'+tsl[1]]:=fbxkeyvaluestoreD.Values['skin'+tsl[2]]; //write mesh id
                end;

              //map deformer to mesh
              k:=fbxkeyvaluestoreD.IndexOfName('skin'+tsl[1]);
              for i:=0 to self.NumMeshes-1 do
              begin
                if self.Mesh[i].Id=strtoint(tsl[2]) then
                  begin
                    //writeln('Found mesh: '+self.Mesh[i].Name+' for deformer '+tsl[1]);
                    fbxkeyvaluestoreD.Values['skin'+tsl[1]]:=inttostr(self.Mesh[i].Id);
                  end;
              end;
            end;


          if fbxversion<7100 then
          begin
            i:=fbxkeyvaluestoreB.IndexOfName(tsl[1]);
            if i>=0 then
            begin
              for j:=0 to self.Skeleton[0].NumBones-1 do
              begin
              if self.Skeleton[0].Bone[j].Name=tsl[1] then
                begin
                  //find deformer
                  k:=fbxkeyvaluestoreD.IndexOfName(tsl[2]);
                  if k>0 then
                  begin
                    tsl2:=TStringList.Create;
                    tsl2.CommaText:=fbxkeyvaluestoreD.Values[tsl[2]];
                    //for loop:=0 to 15 do
                    //  tempm[loop]:=strtofloat(tsl2[loop]);
                    //self.Skeleton[0].Bone[j].Matrix.setMatrixValues(tempm);
                    tsl2.free;
                  end;

                  //find parent bone
                  for k:=0 to self.Skeleton[0].NumBones-1 do
                  begin
                    if self.Skeleton[0].Bone[k].Name=tsl[2] then
                    begin
                      self.Skeleton[0].Bone[j].ParentName:=self.Skeleton[0].Bone[k].Name;
                    end;
                  end;
                end;
              end;
            end;
          end;


          if fbxversion>=7100 then
          begin
            i:=fbxkeyvaluestoreB.IndexOfName(tsl[1]);
            if i>=0 then
            begin
              for j:=0 to self.Skeleton[0].NumBones-1 do
              begin
              if self.Skeleton[0].Bone[j].Id=strtoint(tsl[1]) then
                begin
                  //writeln('Bone name: '+self.Skeleton[0].Bone[j].Name);
                  //find deformer indexes
                  k:=fbxkeyvaluestoreD.IndexOfName('indexes'+tsl[2]);
                  if k>0 then
                  begin
                    //writeln('Indexes Deformer '+tsl[2]);
                    tsl2:=TStringList.Create;
                    trim(copy(fbxkeyvaluestoreD.Values['indexes'+tsl[2]],0,pos('}',fbxkeyvaluestoreD.Values['indexes'+tsl[2]])-1));
                    tsl2.CommaText:=trim(copy(fbxkeyvaluestoreD.Values['indexes'+tsl[2]],0,pos('}',fbxkeyvaluestoreD.Values['indexes'+tsl[2]])-1));
                    //writeln('MeshId: '+fbxkeyvaluestoreD.Values['cluster'+tsl[2]]);
                    if strtoint(fbxkeyvaluestoreD.Values['cluster'+tsl[2]])>0 then
                    begin
                      for loop:=0 to self.NumMeshes-1 do
                      begin
                        if self.Mesh[loop].id=strtoint(fbxkeyvaluestoreD.Values['cluster'+tsl[2]]) then
                        begin
                          //writeln('Apply to mesh: '+self.Mesh[loop].name);
                          for loop2:=0 to tsl2.count-1 do
                          begin
                            self.Mesh[loop].BoneId[strtoint(tsl2[loop2]),0]:=j;
                            self.Mesh[loop].BoneWeight[strtoint(tsl2[loop2]),0]:=1.0;
                          end;
                        end
                      end;
                    end;
                    tsl2.free;
                  end;

                  //Find parent bone
                  for k:=0 to self.Skeleton[0].NumBones-1 do
                  begin
                    if self.Skeleton[0].Bone[k].Id=strtoint(tsl[2]) then
                    begin
                      //writeln('Found parent bone');
                      self.Skeleton[0].Bone[j].ParentName:=self.Skeleton[0].Bone[k].Name;
                    end;
                  end;

                end;
              end;
            end;
          end;

          if fbxversion>=7100 then
          begin
            //map animation layer to stack
            //writeln('Map Animation Start');

            i:=fbxkeyvaluestoreA.IndexOfName(tsl[1]+'LAYER');
            if i>=0 then
            begin
              writeln('Layer');
              writeln(tsl[1]);
              j:=fbxkeyvaluestoreA.IndexOfName(tsl[2]+'STACK');
              if j>=0 then
              begin
                writeln('Stack');
                writeln(tsl[2]);
                writeln(fbxkeyvaluestoreA.ValueFromIndex[j]);
                writeln('Num Anims: '+inttostr(length(self.fAnimation)-1));
                for loop:=0 to length(self.fAnimation)-1 do
                begin
                  writeln('Add Anim: '+inttostr(loop));
                  writeln(self.fAnimation[loop].Name);
                  if self.fAnimation[loop].Name=fbxkeyvaluestoreA.ValueFromIndex[j] then
                  begin
                    fbxkeyvaluestoreA.Values[tsl[1]+'LAYER']:=inttostr(loop);
                    writeln('Found animation: '+self.fAnimation[loop].Name);

                    for loop2:=0 to self.Skeleton[0].NumBones-1 do
                    begin
                      writeln(loop2);
                      self.fAnimation[loop].AddElement();
                    end;

                    writeln('Num Anims: '+inttostr(length(self.fAnimation)-1));
                    writeln(self.fAnimation[0].Name);

                  end;
                end;
              end;
            end;

            //map node to layer (to fanimation);



            i:=fbxkeyvaluestoreA.IndexOfName(tsl[1]+'TNODE');
            if i>=0 then
            begin
              writeln('Map Node to Layer');
              j:=fbxkeyvaluestoreA.IndexOfName(tsl[2]+'LAYER');
              if j>=0 then
              begin
                writeln('TNODE');
                writeln(fbxkeyvaluestoreA.Values[tsl[1]+'TNODE']);
                fbxkeyvaluestoreA.Values[tsl[1]+'TNODE']:=fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'];
                //writeln('animid '+fbxkeyvaluestoreA.Values[tsl[2]+'LAYER']);
                //self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].AddElement();

                if fbxkeyvaluestoreA.Values[tsl[1]+'BNODE'] <> '' then
                begin
                  //writeln('NumElements+'+inttostr(self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].NumElements));
                  writeln('BoneId: '+fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']);
                  //self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].Element[self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].NumElements-1{strtoint(fbxkeyvaluestoreA.Values[tsl[1]+'BNODE'])}].BoneId:=strtoint(fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']);
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].Element[currentelement{strtoint(fbxkeyvaluestoreA.Values[tsl[1]+'BNODE'])}].BoneId:=strtoint(fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']);
                  currentelement:=currentelement+1;
                end;

              end;

              //find bone
              j:=fbxkeyvaluestoreB.IndexOfName(tsl[2]);
              if j>=0 then
              begin
                //writeln('Found Bone: '+fbxkeyvaluestoreB.Values[tsl[2]]);
                for loop:=0 to self.Skeleton[0].NumBones-1 do
                begin
                   if self.Skeleton[0].Bone[loop].Id=strtoint(tsl[2]) then
                    begin
                      //found bone
                      writeln('Found Bone Id: '+inttostr(loop));
                      ///writeln('ID: '+tsl[1]);
                      fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']:=inttostr(loop);

                    end;
                end;

              end;

            end;

            i:=fbxkeyvaluestoreA.IndexOfName(tsl[1]+'RNODE');
            if i>=0 then
            begin

              j:=fbxkeyvaluestoreA.IndexOfName(tsl[2]+'LAYER');
              if j>=0 then
              begin
                //writeln('RNODE: '+fbxkeyvaluestoreA.Values[tsl[1]+'RNODE']);
                fbxkeyvaluestoreA.Values[tsl[1]+'RNODE']:=fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'];
                //self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].AddElement();

                if fbxkeyvaluestoreA.Values[tsl[1]+'BNODE'] <> '' then
                begin
                  //writeln('NumElements+'+inttostr(self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].NumElements));
                  //writeln('BoneId'+fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']);
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'LAYER'])].Element[ strtoint(fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']) ].BoneId:=strtoint(fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']);
                end;

              end;

              //find bone
              j:=fbxkeyvaluestoreB.IndexOfName(tsl[2]);
              if j>=0 then
              begin
                //writeln('Found Bone: '+fbxkeyvaluestoreB.Values[tsl[2]]);
                for loop:=0 to self.Skeleton[0].NumBones-1 do
                begin
                   if self.Skeleton[0].Bone[loop].Id=strtoint(tsl[2]) then
                    begin
                      //found bone
                      //writeln('Found Bone Id: '+inttostr(loop));
                      //writeln('ID: '+tsl[1]);
                      fbxkeyvaluestoreA.Values[tsl[1]+'BNODE']:=inttostr(loop);

                    end;
                end;
              end;
            end;

            //map curve to node

                        //TODO read out id + FLOAT !!!!!

            i:=fbxkeyvaluestoreA.IndexOfName(tsl[1]+'CURVE');
            if i>=0 then
            begin
              //transformation node
              j:=fbxkeyvaluestoreA.IndexOfName(tsl[2]+'TNODE');
              if j>=0 then
              begin
                writeln('curve: '+fbxkeyvaluestoreA.Values[tsl[1]+'CURVE']);
                writeln('ID: '+tsl[2]);
                writeln('Bone/Element Id: '+fbxkeyvaluestoreA.Values[tsl[2]+'BNODE']);
                //writeln([tsl[3]);
                //writeln(fbxkeyvaluestoreA.Values[]); //TODO FLOAT heeft waardes!!!!!

                //is there a corresponding bode node
                if fbxkeyvaluestoreA.Values[tsl[2]+'BNODE']<>'' then
                begin
                  loop:=strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'BNODE']);

                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'TNODE'])].Element[ loop ].BoneId:=loop;
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'TNODE'])].Element[ loop ].Name:=self.Skeleton[0].Bone[loop].Name;
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'TNODE'])].Element[ loop ].NumTranslateFrames:=1; //TODO: use actual number of frames
                  writeln('Element: '+inttostr(loop)+' =  Bone: '+self.Skeleton[0].Bone[loop].Name);

                  writeln('curve: '+TSL[1]);
                  writeln('bone: '+TSL[2]);
                  writeln('axis: '+TSL[3]);
                  writeln('values for '+TSL[1]+'TIME : '+fbxkeyvaluestoreA.Values[TSL[1]+'TIME']);
                  writeln('values for '+TSL[1]+'FLOAT : '+fbxkeyvaluestoreA.Values[TSL[1]+'FLOAT']);

                  tempkeyframe:=self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'TNODE'])].Element[ loop ].TranslateFrame[0];


                  tempkeyframe.time:=0; //TODO: use time from current frame

                  tsl2 := TStringList.Create;
                  tsl2.CommaText := fbxKeyvaluestoreA.Values[tsl[1]+'FLOAT'];
                  writeln(tsl2.Count);

                  if tsl[3] = 'd|X' then tempkeyframe.Value.x:=strtofloat(tsl2[0])-self.Skeleton[0].Bone[loop].Translate.x;
                  if tsl[3] = 'd|Y' then tempkeyframe.Value.y:=strtofloat(tsl2[0])-self.Skeleton[0].Bone[loop].Translate.y;
                  if tsl[3] = 'd|Z' then tempkeyframe.Value.z:=strtofloat(tsl2[0])-self.Skeleton[0].Bone[loop].Translate.z;

                  tsl2.Free;

                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'TNODE'])].Element[ loop ].TranslateFrame[0]:=tempkeyframe;


                end;
              end;

              //Rotation node
              j:=fbxkeyvaluestoreA.IndexOfName(tsl[2]+'RNODE');
              if j>=0 then
              begin
                if fbxkeyvaluestoreA.Values[tsl[2]+'BNODE']<>'' then
                begin
                  loop:=strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'BNODE']);

                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'RNODE'])].Element[ loop ].BoneId:=loop;
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'RNODE'])].Element[ loop ].Name:=self.Skeleton[0].Bone[loop].Name;
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'RNODE'])].Element[ loop ].NumRotateFrames:=1;

                  tempkeyframe:=self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'RNODE'])].Element[ loop ].RotateFrame[0];
                  tempkeyframe.time:=0;
                  tsl2 := TStringList.Create;
                  tsl2.CommaText := fbxKeyvaluestoreA.Values[tsl[1]+'FLOAT'];
                  if tsl[3] = 'd|X' then tempkeyframe.Value.x:=degtorad(strtofloat(tsl2[0]))-self.Skeleton[0].Bone[loop].Rotate.x;
                  if tsl[3] = 'd|Y' then tempkeyframe.Value.y:=degtorad(strtofloat(tsl2[0]))-self.Skeleton[0].Bone[loop].Rotate.y;
                  if tsl[3] = 'd|Z' then tempkeyframe.Value.z:=degtorad(strtofloat(tsl2[0]))-self.Skeleton[0].Bone[loop].Rotate.z;
                  tsl2.Free;
                  self.fAnimation[strtoint(fbxkeyvaluestoreA.Values[tsl[2]+'RNODE'])].Element[ loop ].RotateFrame[0]:=tempkeyframe;

                end;
              end;

            end;

            //TODO: read frame 0 from animationcurve and add that to base values from node?

            //writeln('Map Animation End');
          end;

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
                    for loop := 0 to (self.Mesh[j].NumVertexIndices div 3) - 1 do
                    begin //set matid per indice
                      //self.Mesh[j].MatName[loop]:=self.Material[i].Name;
                      self.Mesh[j].MatId[loop]:=i;
                    end;
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
                        for loop := 0 to (self.Mesh[j].NumVertexIndices div 3) - 1 do
                        begin //set matid per indice
                          //self.Mesh[j].MatName[loop]:=self.Material[i].Name;
                          self.Mesh[j].MatId[loop]:=i;
                        end;
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
              begin
              if tsl[1] = 'Mesh' then
                begin
                  self.AddMesh;
                  //TODO: read meshname from tsl[0]
                  self.Mesh[self.NumMeshes-1].Name:=tsl[0];//'FbxMesh'+inttostr(self.NumMeshes);
                  self.Mesh[self.NumMeshes-1].Visible:=true;
                  fbxindexinfo.Clear;
                  fbxmesh:=true;
                  fbxbone:=false;
                end;

              if (tsl[1] = 'LimbNode') or (tsl[1] = 'Root') {or (tsl[1] = 'Null')} then
              begin
                //Bone found
                fbxkeyvaluestoreB.Values[tsl[0]]:=inttostr(1);
                self.Skeleton[0].AddBone;
                self.Skeleton[0].Bone[self.Skeleton[0].NumBones-1].Name:=tsl[0];
                fbxmesh:=false;
                fbxbone:=true;
              end else
                fbxbone:=false;

              end else
              begin
                //annim node found for <7100 fbx format?
              end;

              tsl.free;

            end;

          (*
          if (key= 'KeyTime') and (fbxversion>=7100) then
          begin
            writeln('KeyTime');
            fbxtime:=true
          end;// else fbxtime:=false;
          *)

          if (key = 'Model') and (fbxversion>=7100) then
          begin
            tsl := TStringList.Create;
            tsl.CommaText := value;

            if tsl[2] = 'Mesh' then
            begin
              fbxkeyvaluestoreM.Values[tsl[0]]:=tsl[1];
            end;

            if (tsl[2] = 'LimbNode') or (tsl[2] = 'Root') then
            begin
              //Bone found
              fbxkeyvaluestoreB.Values[tsl[0]]:=tsl[1];
              self.Skeleton[0].AddBone;
              self.Skeleton[0].Bone[self.Skeleton[0].NumBones-1].Id:=strtoint(tsl[0]);
              self.Skeleton[0].Bone[self.Skeleton[0].NumBones-1].Name:=tsl[1];
              fbxmesh:=false;
              fbxbone:=true;
            end else
              fbxbone:=false;
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
                self.Mesh[self.NumMeshes-1].Name:=tsl[1];
                self.Mesh[self.NumMeshes-1].Id:=strtoint(tsl[0]);
                self.Mesh[self.NumMeshes-1].Visible:=true;
                fbxindexinfo.Clear;
                fbxmesh:=true;
                fbxbone:=false;
              end;
              if tsl[2] = 'Shape' then
              begin
                //TODO: read blend shapes? For now try to ignore them?
                fbxmesh:=false;
              end;
              tsl.free;
            end;

          if (key='Vertices') and ((fbxversion>=7100) and (fbxmesh)) then
            begin
              //set number of vetrices in mesh
              self.Mesh[self.FNumMeshes-1].NumVertex:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
            end;
          if (key='PolygonVertexIndex') and ((fbxversion>=7100 ) and (fbxmesh)) then
            begin
              //set number of vetrex indices in mesh
              fbxnumberofvetexindices:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1)));
            end;
          if (key='Normals') and ((fbxversion>=7100) and (fbxmesh)) then
            begin
              self.Mesh[self.FNumMeshes-1].NumNormals:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 3;
            end;
          if (key='NormalsIndex') and ((fbxversion>=7100) and (fbxmesh)) then
            begin
              //Do nothing
            end;
          if (key='UV') and ((fbxversion>=7100) and (fbxmesh)) then
            begin
              self.Mesh[self.FNumMeshes-1].NumMappings:=strtoint(trim(copy(value,pos('*',value)+1,pos('{',value)-pos('*',value)-1))) div 2;
            end;
          if (key='UVIndex') and ((fbxversion>=7100) and (fbxmesh)) then
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
          if (key='a') and (parentkey='Vertices') then if fbxmesh then AddVertices(value);
          if (key='a') and (parentkey='PolygonVertexIndex') then if fbxmesh then  AddVertexIndices(value);
          if (key='a') and (parentkey='Normals') then if fbxmesh then AddNormals(value);
          if (key='a') and (parentkey='NormalsIndex') then if fbxmesh then
          begin
            AddNormalIndices(value);
            //prevent parsing twice
            key:=parentkey;
            value:='';
          end;
          if (key='a') and (parentkey='UV') then if fbxmesh then AddUVMapping(value);
          if (key='a') and (parentkey='UVIndex') then if fbxmesh then
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
  fbxkeyvaluestoreB.Free;
  fbxkeyvaluestoreD.Free;
  fbxkeyvaluestoreA.Free;
  fbxindexinfo.Free;

  //Skeleton Sanity Check
  if self.Skeleton[0].NumBones = 0 then self.FNumSkeletons:=0
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

