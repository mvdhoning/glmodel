unit gl3Render;

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
 * Portions created by the Initial Developer are Copyright (C) 2007
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

{$IFDEF FPC}
  {$MODE Delphi}
  {$H+}
  {$M+}
  {$codepage utf8}
  {$IFNDEF WINDOWS}
    {$LINKLIB c}
  {$ENDIF}
{$ENDIF}  
 
interface

uses classes, sysutils, model, render, dglopengl, gl3mesh, glmodel, glmaterial, glskeleton, glvbo;

type Tgl3Render = class(TBaseRender)
  protected
    fvbo: TglVbo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure AddModel(Value: TBaseModel); overload; override;
    procedure AddModel; overload; override;
    procedure Render; override;
    procedure Init; override;
    property VBO: TglVbo read fvbo write fvbo;
end;

implementation

constructor Tgl3Render.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fvbo:=TglVbo.Create;
end;

destructor Tgl3Render.Destroy();
begin
  FreeAndNil(fvbo);
  inherited Destroy;
end;

procedure Tgl3Render.AddModel(Value: TBaseModel);
begin
  inherited;

  Models[FNumModels-1].MeshClass := TGL3Mesh;
  Models[FNumModels-1].MaterialClass := TGLMaterial;
  Models[FNumModels-1].SkeletonClass := TGLSkeleton;
end;

procedure Tgl3Render.AddModel;
begin
  AddModel(TGlModel.Create(self));
end;

procedure Tgl3Render.Init;
var
  I,J: Integer;
  test: TVBOVertex;
begin
  writeln('gl3render init');
  for I := 0 to FNumModels-1 do
  begin
    writeln(i);
    //FModels[i].Init;
    writeln('model name: '+fModels[i].Name);
    writeln(TGL3Mesh(FModels[i].Mesh[0]).drawStyle);
    fvbo.AddMesh(TGL3Mesh(FModels[i].Mesh[0]).drawStyle);
    for j:=0 to FModels[i].Mesh[0].NumVertexIndices-1 do
    begin
      //TODO: move to mesh
      test.Position:=FModels[i].Mesh[0].Vertex[FModels[i].Mesh[0].VertexIndices[j]];
      test.Normal:=FModels[i].Mesh[0].Normals[FModels[i].Mesh[0].Normal[j]];
      test.Color.red:=FModels[i].material[FModels[i].Mesh[0].matid[j div 3]].DiffuseRed;
      test.Color.green:=FModels[i].material[FModels[i].Mesh[0].matid[j div 3]].DiffuseGreen;
      test.Color.blue:=FModels[i].material[FModels[i].Mesh[0].matid[j div 3]].DiffuseBlue;
      test.Color.alpha:=0.0;
      fvbo.AddVertex(test);
    end;
    //TODO: remember models
  end;
  fvbo.init();
end;

procedure Tgl3Render.Render;
var
  I: Integer;
begin
  fvbo.render;
  (*
  for I := 0 to FNumModels-1 do
  begin
    //TODO: reimplement glpushmatrix();
    FModels[i].Render;
    //TODO: reimplement glpopmatrix();
  end;
  *)

  //TODO: make a single vbo here with all static objects and one with all animated object
  (*
  GL.VertexPointer(3, VertexPointerType.Double, 0, lineloop1offset); //starting from the beginning of the array
GL.DrawArrays(BeginMode.LineLoop, lineloop1offset , lineloop1VertexNum  );
GL.DrawArrays(BeginMode.LineLoop, lineloop2offset , lineloop2VertexNum );
GL.DrawArrays(BeginMode.LineLoop, lineloop3offset , lineloop3VertexNum );

or
DrawElement with offset?
  *)

  //experiment with one cube in vbo and render that multiple times at diffent positions

  //uniforms beter zo doen
  //https://www.khronos.org/opengl/wiki/Uniform_Buffer_Object
  //https://learnopengl.com/Advanced-OpenGL/Advanced-GLSL

  //also render gui via this?
  //read this
end;

end.
