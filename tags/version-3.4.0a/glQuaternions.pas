// =============================================================================
//
//   glQuaternions.pas
//
// =============================================================================
//   Copyright © 2003-2004 by Sascha Willems - http://www.delphigl.de
// =============================================================================
//   --> visit the Delphi OpenGL Community - http://www.delphigl.com <--
// =============================================================================
//   Contents of this file are subject to the Mozilla Public License 1.1 (MPL1.1)
//   which can be obtained here : http://opensource.org/licenses/mozilla1.1.php
//   So only use this file if you fully unterstand that license!!!
// =============================================================================
//   Small unit that contains the most used functions for quaternions
//   Most of what can be found in here is based on the following article :
//    http://www.gamasutra.com/features/19980703/quaternions_01.htm
//   Written by Nick Bobick
// =============================================================================
//   Version 1.0
// =============================================================================

unit glQuaternions;

interface

uses Math;

type
 PQuaternion = ^TQuaternion;
 TQuaternion = record
   w,x,y,z : Single;
  end;

 PMatrix = ^TMatrix;
 TMatrix = array[0..3, 0..3] of Single;

 TVector = record
   x,y,z : Single;
  end;

function Vector(x,y,z : Single) : TVector;

function QuaternionFromRotation(pAxis : TVector; pAngle : Single) : TQuaternion;
function QuaternionRotate(pQ1, pQ2 : TQuaternion) : TQuaternion;
function QuaternionMultiply(pQ1, pQ2 : TQuaternion) : TQuaternion;
function QuaternionConjugate(pQ : TQuaternion) : TQuaternion;
function QuaternionNorm(pQ : TQuaternion) : Single;
function QuaternionNormalize(pQ : TQuaternion) : TQuaternion;
function QuaternionInverse(pQ : TQuaternion) : TQuaternion;
function QuaternionSLerp(pFrom, pTo : TQuaternion; pTime : Single) : TQuaternion;

function RotateVectorByQuaternion(pQ : TQuaternion; pVector : TVector) : TVector;

function QuaternionToMatrix(pQ : TQuaternion) : TMatrix;

implementation

// =============================================================================
// =============================================================================
function Vector(x,y,z : Single) : TVector;
begin
Result.x := x;
Result.y := y;
Result.z := z;
end;

// =============================================================================
// =============================================================================
function QuaternionFromRotation(pAxis : TVector; pAngle : Single) : TQuaternion;
var
 Norm : Single;
begin
Result.w := Cos(pAngle / 2);
Result.x := pAxis.x * Sin(pAngle / 2);
Result.y := pAxis.y * Sin(pAngle / 2);
Result.z := pAxis.z * Sin(pAngle / 2);
Norm := QuaternionNorm(Result);
Result.w := Result.w / Norm;
Result.x := Result.x / Norm;
Result.y := Result.y / Norm;
Result.z := Result.z / Norm;
end;

// =============================================================================
// =============================================================================
function QuaternionRotate(pQ1, pQ2 : TQuaternion) : TQuaternion;
begin
Result.w := pQ1.w + pQ2.w;
Result.x := pQ1.x + pQ2.x;
Result.y := pQ1.y + pQ2.y;
Result.z := pQ1.z + pQ2.z;
end;

// =============================================================================
// =============================================================================
function QuaternionMultiply(pQ1, pQ2 : TQuaternion) : TQuaternion;
var
 A,B,C,D,E,F,G,H : Single;
begin
A := (pQ1.w + pQ1.x)*(pQ2.w + pQ2.x);
B := (pQ1.z - pQ1.y)*(pQ2.y - pQ2.z);
C := (pQ1.w - pQ1.x)*(pQ2.y + pQ2.z);
D := (pQ1.y + pQ1.z)*(pQ2.w - pQ2.x);
E := (pQ1.x + pQ1.z)*(pQ2.x + pQ2.y);
F := (pQ1.x - pQ1.z)*(pQ2.x - pQ2.y);
G := (pQ1.w + pQ1.y)*(pQ2.w - pQ2.z);
H := (pQ1.w - pQ1.y)*(pQ2.w + pQ2.z);

Result.w := B + (-E - F + G + H) /2;
Result.x := A - (E + F + G + H)/2;
Result.y := C + (E - F + G - H)/2;
Result.z := D + (E - F - G + H)/2;
end;

// =============================================================================
// =============================================================================
function QuaternionConjugate(pQ : TQuaternion) : TQuaternion;
begin
Result.x := -pQ.x;
Result.y := -pQ.y;
Result.z := -pQ.z;
end;

// =============================================================================
// =============================================================================
function QuaternionNorm(pQ : TQuaternion) : Single;
begin
Result := Sqr(pQ.w) + Sqr(pQ.x) + Sqr(pQ.y) + Sqr(pQ.z);
end;

// =============================================================================
// =============================================================================
function QuaternionNormalize(pQ : TQuaternion) : TQuaternion;
var
 Norm : Single;
begin
Norm     := QuaternionNorm(pQ);
Result.w := pQ.w / Norm;
Result.x := pQ.x / Norm;
Result.y := pQ.y / Norm;
Result.z := pQ.z / Norm;
end;

// =============================================================================
// =============================================================================
function QuaternionInverse(pQ : TQuaternion) : TQuaternion;
begin
Result := QuaternionNormalize(QuaternionConjugate(pQ));
end;

// =============================================================================
// =============================================================================
function QuaternionSLerp(pFrom, pTo : TQuaternion; pTime : Single) : TQuaternion;
var
 To1                                 : array[0..3] of Single;
 Omega, Cosom, Sinom, Scale0, Scale1 : Double;
const
 Delta = 0.001;
begin
// Calculate cosine
Cosom := (pFrom.x * pTo.x) + (pFrom.y * pTo.y) + (pFrom.z * pTo.z) + (pFrom.w * pTo.w);
// Adjust signs (if necessary)
if Cosom < 0 then
 begin
 Cosom  := -Cosom;
 To1[0] := -pTo.x;
 To1[1] := -pTo.y;
 To1[2] := -pTo.z;
 To1[3] := -pTo.w;
 end
else
 begin
 To1[0] := pTo.x;
 To1[1] := pTo.y;
 To1[2] := pTo.z;
 To1[3] := pTo.w;
 end;
// Calculate coefficients
if 1-Cosom > Delta then
 begin
 Omega  := ArcCos(Cosom);
 Sinom  := Sin(Omega);
 Scale0 := Sin((1-pTime) * Omega) / Sinom;
 Scale1 := Sin(pTime * Omega) / Sinom;
 end
else
 begin
 // Both quaternions are really close, so linear interoplation is enough
 Scale0 := 1-pTime;
 Scale1 := pTime;
 end;
// Calculate final values
Result.x := Scale0 * pFrom.x + Scale1 * To1[0];
Result.y := Scale0 * pFrom.y + Scale1 * To1[1];
Result.z := Scale0 * pFrom.z + Scale1 * To1[2];
Result.w := Scale0 * pFrom.w + Scale1 * To1[3];
end;

// =============================================================================
// =============================================================================
function RotateVectorByQuaternion(pQ : TQuaternion; pVector : TVector) : TVector;
var
 tmpA : TQuaternion;
 tmpB : TQuaternion;
begin
tmpA.w   := 0;
tmpA.x   := pVector.x;
tmpA.y   := pVector.y;
tmpA.z   := pVector.z;
tmpA     := QuaternionMultiply(pQ, tmpA);
tmpB     := QuaternionInverse(pQ);
tmpA     := QuaternionMultiply(tmpA, tmpB);
Result.x := tmpA.x;
Result.y := tmpA.y;
Result.z := tmpA.z;
end;

// =============================================================================
// =============================================================================
function QuaternionToMatrix(pQ : TQuaternion) : TMatrix;
begin
with pQ do
 begin
 Result[0,0] := 1 - 2*y*y - 2*z*z;
 Result[1,0] := 2*x*y - 2*w*z;
 Result[2,0] := 2*x*z + 2*w*y;
 Result[3,0] := 0;

 Result[0,1] := 2*x*y + 2*w*z;
 Result[1,1] := 1 - 2*x*x - 2*z*z;
 Result[2,1] := 2*y*z - 2*w*x;
 Result[3,1] := 0;

 Result[0,2] := 2*x*z - 2*w*y;
 Result[1,2] := 2*y*z + 2*w*x;
 Result[2,2] := 1 - 2*x*x - 2*y*y;
 Result[3,2] := 0;

 Result[0,3] := 0;
 Result[1,3] := 0;
 Result[2,3] := 0;
 Result[3,3] := 1;
 end;
end;

end.
