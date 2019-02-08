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
 * The Original Code is the gl3ds math unit.
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

//TODO:
//Rename funtions

unit glmath;

interface

uses dglopengl, glmatrix;

const
  DEGTORAD=3.1412/180;
  RADTODEG=180/3.1412;

type
  //generic opengl color record (should not be here)
  TGLColor=packed record
    red,green,blue,alpha: GLclampf;
  end;

  T3dpoint     = packed record
    x, y, z        :Single;
  end;

  T4DPoint = packed record
    x, y, z, w : single;
  end;

  TPlaneEq = record
    a, b, c, d: Single;                      //ax + by + cz + d = 0
  end;

var
   hastexture: TGLuint;

function Normalize(v: T3dPoint): T3dPoint;
function CrossProduct(V1, V2: T3dPoint): T3dPoint;
function CalcNormalVector(const Point1,Point2,Point3:T3DPoint):T3DPoint;
function MatrixTransform(matrix: clsMatrix; vertex: T3DPoint): T3DPoint;
function VectorSubtract(V1, V2: T3dPoint): T3dPoint; register;
function VectorAdd(V1, V2: T3dPoint): T3dPoint; register;
function VectorMul(V: T3DPoint; S: single): T3dPoint; register;
function VectorDiv(V: T3DPoint; S: single): T3dPoint; register;
function VectorTransform3f(V: T3DPoint; M: TMatrix): T3dPoint;
function VectorTransform4f(V: T4DPoint; M: TMatrix): T4dPoint;
function CreateT3DPoint(x,y,z: Single): T3dPoint;
function CreateT4DPoint(x,y,z,w: Single): T4dPoint;

implementation

function CreateT3DPoint(x,y,z: Single): T3dPoint;
begin
  result.x:=x;
  result.y:=y;
  result.z:=z;
end;

function CreateT4DPoint(x,y,z,w: Single): T4dPoint;
begin
  result.x:=x;
  result.y:=y;
  result.z:=z;
  result.w:=w;
end;

//Normalizes a vector
function Normalize(v: T3dPoint): T3dPoint;
var
 L:single;
begin
L:=sqrt(sqr (v.x) + sqr(v.y) + sqr(v.z));
  If L>0 then
    begin
      result.x:=v.x/L;
      result.y:=v.y/L;
      result.z:=v.z/L;
    end;
end;

// returns the difference of two vectors
function VectorSubtract(V1, V2: T3dPoint): T3dPoint; register;
begin
  Result.x := V1.x - V2.x;
  Result.y := V1.y - V2.y;
  Result.z := V1.z - V2.z;
end;

// returns the addition of two vectors
function VectorAdd(V1, V2: T3dPoint): T3dPoint; register;
begin
  Result.x := V1.x + V2.x;
  Result.y := V1.y + V2.y;
  Result.z := V1.z + V2.z;
end;

// returns the multiplication of a vector with an single
function VectorMul(V: T3DPoint; S: single): T3dPoint; register;
begin
  Result.x := V.x * S;
  Result.y := V.y * S;
  Result.z := V.z * S;
end;

// returns the multiplication of a vector with an single
function VectorDiv(V: T3DPoint; S: single): T3dPoint; register;
begin
  Result.x := V.x / S;
  Result.y := V.y / S;
  Result.z := V.z / S;
end;

// returns the cross product of two vectors
function CrossProduct(V1, V2: T3dPoint): T3dPoint;
begin
  result.x:=v1.y*v2.z - v2.y*v1.z;
  result.y:=v1.z*v2.x - v2.z*v1.x;
  result.z:=v1.x*v2.y - v2.x*v1.y;
end;

// transforms an affine vector by multiplying it with a (homogeneous) matrix
function  VectorTransform3f(V: T3DPoint; M: TMatrix): T3dPoint;
var
  TV: T3dPoint;
begin
  TV.x := V.x * M[0, 0] + V.y * M[1, 0] + V.z * M[2, 0] + M[3, 0];
  TV.y := V.x * M[0, 1] + V.y * M[1, 1] + V.z * M[2, 1] + M[3, 1];
  TV.z := V.x * M[1, 2] + V.y * M[1, 2] + V.z * M[2, 2] + M[3, 2];
  Result := TV;
end;

// transforms an affine vector by multiplying it with a (homogeneous) matrix
function  VectorTransform4f(V: T4DPoint; M: TMatrix): T4dPoint;
var
  TV: T4dPoint;
begin
  TV.x := V.x * M[0, 0] + V.y * M[1, 0] + V.z * M[2, 0] + V.w * M[3, 0];
  TV.y := V.x * M[0, 1] + V.y * M[1, 1] + V.z * M[2, 1] + V.w * M[3, 1];
  TV.z := V.x * M[1, 2] + V.y * M[1, 2] + V.z * M[2, 2] + V.w * M[3, 2];
  TV.w := V.x * M[1, 3] + V.y * M[1, 3] + V.z * M[2, 3] + V.w * M[3, 3];
  Result := TV;
end;

function MatrixTransform(matrix: clsMatrix; vertex: T3DPoint): T3DPoint;
var
   tempmatrix : array [0..15] of single;

begin
  matrix.getMatrix(tempmatrix);
  result.x := vertex.x*tempmatrix[0]+vertex.y*tempmatrix[4]+vertex.z*tempmatrix[8]+tempmatrix[12];
  result.y := vertex.x*tempmatrix[1]+vertex.y*tempmatrix[5]+vertex.z*tempmatrix[9]+tempmatrix[13];
  result.z := vertex.x*tempmatrix[2]+vertex.y*tempmatrix[6]+vertex.z*tempmatrix[10]+tempmatrix[14];
end;

function CalcNormalVector(const Point1,Point2,Point3:T3DPoint):T3DPoint;
var
  temppoint1, temppoint2: t3dpoint;
  temp: t3dpoint;
begin
temppoint1:=vectorsubtract(point2,point1);
temppoint2:=vectorsubtract(point3,point1);
temp:=crossproduct(temppoint1,temppoint2);
result:=normalize(temp);
end;

end.
