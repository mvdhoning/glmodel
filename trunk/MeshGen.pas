unit MeshGen;

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

//TODO: implement support for other meshtypes like sphere, donut

interface

Uses Mesh, glMath;

type
  TMeshGen = class(TBaseMesh)
  protected
  public
    procedure GenerateDisc(radius: single; scaletu: single; scaletv: single);
    procedure GenerateCylinder(radius: single; height: single; scaletu: single; scaletv: single);
    procedure GeneratePlane(width: single; depth: single; scaletu: single; scaletv: single);
    procedure GenerateCube(width:single; height: single; depth: single; scaletu: single; scaletv: single);
  end;

implementation

(*

Cylinder:
extend disc look at extrude font in glvg

Sphere:

http://www.codeproject.com/KB/WPF/XamlUVSphere.aspx

using System;
using System.Windows.Media;
using System.Windows.Media.Media3D;
using System.Diagnostics;

namespace Sphere3D
{
    class SphereGeometry3D : RoundMesh3D
    {
        protected override void CalculateGeometry()
        {
            int e;
            double segmentRad = Math.PI / 2 / (n + 1);
            int numberOfSeparators = 4 * n + 4;

            points = new Point3DCollection();
            triangleIndices = new Int32Collection();

            for (e = -n; e <= n; e++)
            {
                double r_e = r * Math.Cos(segmentRad * e);
                double y_e = r * Math.Sin(segmentRad * e);

                for (int s = 0; s <= (numberOfSeparators - 1); s++)
                {
                    double z_s = r_e * Math.Sin(segmentRad * s) * (-1);
                    double x_s = r_e * Math.Cos(segmentRad * s);
                    points.Add(new Point3D(x_s, y_e, z_s));
                }
            }
            points.Add(new Point3D(0, r, 0));
            points.Add(new Point3D(0, -1 * r, 0));

            for (e = 0; e < 2 * n; e++)
            {
                for (int i = 0; i < numberOfSeparators; i++)
                {
                    triangleIndices.Add(e * numberOfSeparators + i);
                    triangleIndices.Add(e * numberOfSeparators + i +
                                        numberOfSeparators);
                    triangleIndices.Add(e * numberOfSeparators + (i + 1) %
                                        numberOfSeparators + numberOfSeparators);

                    triangleIndices.Add(e * numberOfSeparators + (i + 1) %
                                        numberOfSeparators + numberOfSeparators);
                    triangleIndices.Add(e * numberOfSeparators +
                                       (i + 1) % numberOfSeparators);
                    triangleIndices.Add(e * numberOfSeparators + i);
                }
            }

            for (int i = 0; i < numberOfSeparators; i++)
            {
                triangleIndices.Add(e * numberOfSeparators + i);
                triangleIndices.Add(e * numberOfSeparators + (i + 1) %
                                    numberOfSeparators);
                triangleIndices.Add(numberOfSeparators * (2 * n + 1));
            }

            for (int i = 0; i < numberOfSeparators; i++)
            {
                triangleIndices.Add(i);
                triangleIndices.Add((i + 1) % numberOfSeparators);
                triangleIndices.Add(numberOfSeparators * (2 * n + 1) + 1);
            }
        }

        public SphereGeometry3D()
        { }
    }
}

*)


procedure TMeshGen.GenerateCylinder(radius: single; height: single; scaletu: single; scaletv: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
  i : integer;
  r: single;
  h: single;
  slices: integer;
begin

  h:=height/2;
  r:=radius/2;
  slices:=35; //was 8

  self.NumVertex := (slices*2)+2;
  self.NumVertexIndices := self.NumVertex*3;

  self.NumVertexIndices := self.NumVertexIndices + ((slices*2) * 3);

  v1.x:=0;
  v1.y:=0;
  v1.z:=0;

  //  first points is center

  //bottom
  //vertexes
  for i := 0 to slices-1 do
  begin
   v1.x := r * System.Sin(2 * i * PI / slices);
   v1.y := r * System.Cos(2 * i * PI / slices);
   v1.z := -1.0 * h;
    self.Vertex[(i*2)]:=v1;

   v1.x := r * System.Sin(2 * i * PI / slices);
   v1.y := r * System.Cos(2 * i * PI / slices);
   v1.z := 1.0 * h;
    self.Vertex[(i*2)+1]:=v1;

  end;

  v1.x := 0;
  v1.y := 0;
  v1.z := -1.0 * h;
  self.Vertex[slices*2]:=v1;

    v1.x := 0;
  v1.y := 0;
  v1.z := 1.0 * h;
  self.Vertex[(slices*2)+1]:=v1;

  //indices
  for i := 0 to slices-1 do
  begin

  // Triangles along length of cylinder
   self.FVertexIndices[(i*12)+0]:= 2 * i + 0;
   self.FVertexIndices[(i*12)+1]:=2 * i + 1;
   self.FVertexIndices[(i*12)+2]:=(2 * i + 2) mod (2 * Slices);

   self.FVertexIndices[(i*12)+3]:=(2 * i + 2) mod (2 * Slices);
   self.FVertexIndices[(i*12)+4]:=2 * i + 1;
   self.FVertexIndices[(i*12)+5]:=(2 * i + 3) mod (2 * Slices);

   self.FVertexIndices[(i*12)+6]:=2 * slices;
   self.FVertexIndices[(i*12)+7]:=2 * i + 0;
   self.FVertexIndices[(i*12)+8]:=(2 * i + 2) mod (2 * slices);

   self.FVertexIndices[(i*12)+9]:=2 * Slices + 1;
   self.FVertexIndices[(i*12)+10]:=(2 * i + 3) mod (2 * Slices);
   self.FVertexIndices[(i*12)+11]:=2 * i + 1;

  end;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=((slices*2)+2)+(slices*2); //for each face indices div 3
  self.NumNormalIndices:=(((slices*2)+2)*3)+((slices*2) *3);
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=1;
  self.NumMappingIndices:=(((slices*2)+2)*3)+((slices*2) *3);
  map.tu:=0;
  map.tv:=0;
  self.Mapping[0]:=map;
  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;

end;

procedure TMeshGen.GenerateDisc(radius: single; scaletu: single; scaletv: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;

  n: integer;
  r: single;
  divider: integer;
  alpha: double;
  numberOfSeparators: integer;
begin
  //TODO: fix sice and center
  r:=radius/2;
  n:=1; //number of segments;
  numberOfSeparators := (4 * n) +4;

  self.NumVertex := numberOfSeparators+1;
  self.NumVertexIndices := (numberOfSeparators+1)*3;

  v1.x:=0;
  v1.y:=0;
  v1.z:=0;

  for divider := 0 to numberOfSeparators do
  begin
    alpha := PI / 2 / (n + 1) * divider;
    v1.x:=1.0 * r *System.Cos(alpha);
    v1.y:=0.0;
    v1.z:=-1 * r * System.Sin(alpha);
    self.Vertex[divider]:=v1;

    self.FVertexIndices[(divider*3)+0]:=0;
    self.FVertexIndices[(divider*3)+1]:=divider+1;
    if divider = numberofseparators-1 then
      self.FVertexIndices[(divider*3)+2]:=1
    else
      self.FVertexIndices[(divider*3)+2]:=divider+2;
  end;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=numberOfSeparators+1; //for each face indices div 3
  self.NumNormalIndices:=(numberOfSeparators+1)*3;
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=1;
  self.NumMappingIndices:=(numberOfSeparators+1)*3;
  map.tu:=0;
  map.tv:=0;
  self.Mapping[0]:=map;
  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;

end;

procedure TMeshGen.GeneratePlane(width: single; depth: single; scaletu: single; scaletv: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
  cwidth: single;
  cdepth: single;
begin
  cwidth:=width / 2;
  cdepth:=depth / 2;

  self.NumVertex := 4; //number of vertexes

  v1.x := -1.0 * cwidth;
  v1.y := 0.0;
  v1.z := -1.0 * cdepth;
  self.Vertex[0]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := 0.0;
  v1.z := 1.0  * cdepth;
  self.Vertex[1]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 0.0;
  v1.z := -1.0 * cdepth;
  self.Vertex[2]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 0.0;
  v1.z := 1.0  * cdepth;
  self.Vertex[3]:=v1;

  self.NumVertexIndices := 6; //number of vertex indices

  self.Face[0]:=0;
  self.Face[1]:=1;
  self.Face[2]:=2;

  self.Face[3]:=2;
  self.Face[4]:=1;
  self.Face[5]:=3;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=2; //for each face indices div 3
  self.NumNormalIndices:=6;
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=1;
  self.NumMappingIndices:=6;
  map.tu:=0;
  map.tv:=0;
  self.Mapping[0]:=map;
  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;
end;

procedure TMeshGen.GenerateCube(width: single; height: single; depth: single; scaletu: single; scaletv: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
  cwidth: single;
  cheight: single;
  cdepth: single;
begin
  cwidth:=width / 2;
  cheight:=width / 2;
  cdepth:=depth / 2;

  self.NumVertex := 8; //number of vertexes
  v1.x := -1.0 * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[0]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[1]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[2]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[3]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[4]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[5]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[6]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[7]:=v1;

  self.NumVertexIndices := 36; //number of vertex indices
  self.Face[0]:=0;
  self.Face[1]:=2;
  self.Face[2]:=4;

  self.Face[3]:=4;
  self.Face[4]:=2;
  self.Face[5]:=6;

  self.Face[6]:=0;
  self.Face[7]:=4;
  self.Face[8]:=1;

  self.Face[9]:=1;
  self.Face[10]:=4;
  self.Face[11]:=5;

  self.Face[12]:=0;
  self.Face[13]:=1;
  self.Face[14]:=2;

  self.Face[15]:=2;
  self.Face[16]:=1;
  self.Face[17]:=3;

  self.Face[18]:=4;
  self.Face[19]:=6;
  self.Face[20]:=5;

  self.Face[21]:=5;
  self.Face[22]:=6;
  self.Face[23]:=7;

  self.Face[24]:=2;
  self.Face[25]:=3;
  self.Face[26]:=6;

  self.Face[27]:=6;
  self.Face[28]:=3;
  self.Face[29]:=7;

  self.Face[30]:=1;
  self.Face[31]:=5;
  self.Face[32]:=3;

  self.Face[33]:=3;
  self.Face[34]:=5;
  self.Face[35]:=7;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=12; //for each face indices div 3
  self.NumNormalIndices:=36;
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=8;
  self.NumMappingIndices:=36;
  for tel:=0 to self.NumMappings-1 do
  begin
  map.tu:=self.Vertex[tel].x*scaletu;
  map.tv:=self.Vertex[tel].y*scaletv;
  self.Mapping[tel]:=map;
  end;

  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=self.Face[tel];
  end;

  //make mesh visible
  self.Visible:=true;
end;

end.
