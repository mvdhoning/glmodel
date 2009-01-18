//------------------------------------------------------------------------
//
// Author      : Maarten "McCLaw" Kronberger
// Email       : sulacomcclaw@hotmail.com
// Website     : http://www.sulaco.co.za
// Date        : 1 April 2003
// Version     : 1.0
// Description : Skeletal Character animation using Keyframe interpolation and 
//               Milkshape 3D ASCII files
//
//------------------------------------------------------------------------
unit glMatrix;

interface

type
  TMatrix=array[0..3,0..3] of single; //some simple matrix
  pdouble = ^double;
  clsMatrix = class
	public
		{	Constructor. }
		constructor create();

		{	Set to identity. }
		procedure loadIdentity();

		{	Set the values of the matrix. }
		procedure setMatrixValues( matrix : array of single);   {procedure setMatrixValues( const float *matrix );}

		{	Post-multiply by another matrix. }
		procedure postMultiply( var matrix : clsMatrix );  {procedure postMultiply( const Matrix& matrix );}

		{	Set the translation of the current matrix. Will erase any previous values. }
		procedure setTranslation( translation : array of single ); {procedure setTranslation( const float *translation );}

		{	Set the inverse translation of the current matrix. Will erase any previous values. }
		procedure setInverseTranslation( translation : array of single);

		{	Make a rotation matrix from Euler angles. The 4th row and column are unmodified. }
		procedure setRotationRadians( angles : array of single );

		{	Make a rotation matrix from Euler angles. The 4th row and column are unmodified. }
		procedure setRotationDegrees( angles : array of single );

		{	Make an inverted rotation matrix from Euler angles. The 4th row and column are unmodified. }
		procedure setInverseRotationRadians( angles : array of single );

		{	Make an inverted rotation matrix from Euler angles. The 4th row and column are unmodified. }
		procedure setInverseRotationDegrees( angles : array of single );

		{	Get the matrix data. }
		procedure getMatrix(var matrix : array of single); { return m_matrix; }

    { Translate Vector }
		procedure translateVect( var pVect : array of single );

		{	Rotate a vector by the inverse of the rotation part of this matrix. }
		procedure rotateVect( var pVect : array of single );

		{	Translate a vector by the inverse of the translation part of this matrix. }
		procedure inverseTranslateVect( var pVect : array of single );

		{	Rotate a vector by the inverse of the rotation part of this matrix. }
		procedure inverseRotateVect( var pVect: array of single );

	private
		//	Matrix data, stored in column-major order
		m_matrix : array [0..15] of single;

end;


implementation

{ clsMatrix }

{------------------------------------------------------------------}
{  Constructor.                                                    }
{------------------------------------------------------------------}
constructor clsMatrix.create;
begin
  loadIdentity();
end;

{------------------------------------------------------------------}
{  Get the matrix data.                                            }
{------------------------------------------------------------------}
procedure clsMatrix.getMatrix(var matrix : array of single);
var i : integer;
begin
  {TODO : this might be dodge, maybe use m_matrix as public}
  for i := 0 to 15 do
   matrix[i] := m_matrix[i];
end;

{---------------------------------------------------------------------}
{  Rotate a vector by the inverse of the rotation part of this matrix.}
{---------------------------------------------------------------------}
procedure clsMatrix.inverseRotateVect(var pVect: array of single);
var vec : array [0..2] of single;
begin
	vec[0] := pVect[0]*m_matrix[0]+pVect[1]*m_matrix[1]+pVect[2]*m_matrix[2];
	vec[1] := pVect[0]*m_matrix[4]+pVect[1]*m_matrix[5]+pVect[2]*m_matrix[6];
	vec[2] := pVect[0]*m_matrix[8]+pVect[1]*m_matrix[9]+pVect[2]*m_matrix[10];

  pVect[0] := vec[0];
  pVect[1] := vec[1];
  pVect[2] := vec[2];
end;

{---------------------------------------------------------------------}
{  Set to identity.                                                   }
{---------------------------------------------------------------------}
procedure clsMatrix.loadIdentity;
begin
 m_matrix[0]  := 1;
 m_matrix[1]  := 0;
 m_matrix[2]  := 0;
 m_matrix[3]  := 0;

 m_matrix[4]  := 0;
 m_matrix[5]  := 1;
 m_matrix[6]  := 0;
 m_matrix[7]  := 0;

 m_matrix[8]  := 0;
 m_matrix[9]  := 0;
 m_matrix[10] := 1;
 m_matrix[11] := 0;

 m_matrix[12] := 0;
 m_matrix[13] := 0;
 m_matrix[14] := 0;
 m_matrix[15] := 1;
end;

{---------------------------------------------------------------------}
{  Post-multiply by another matrix.                                   }
{---------------------------------------------------------------------}
procedure clsMatrix.postMultiply(var matrix: clsMatrix);
var newMatrix : array [0..15] of single;
begin

	newMatrix[0] := m_matrix[0]*matrix.m_matrix[0] + m_matrix[4]*matrix.m_matrix[1] + m_matrix[8]*matrix.m_matrix[2];
	newMatrix[1] := m_matrix[1]*matrix.m_matrix[0] + m_matrix[5]*matrix.m_matrix[1] + m_matrix[9]*matrix.m_matrix[2];
	newMatrix[2] := m_matrix[2]*matrix.m_matrix[0] + m_matrix[6]*matrix.m_matrix[1] + m_matrix[10]*matrix.m_matrix[2];
	newMatrix[3] := 0;

	newMatrix[4] := m_matrix[0]*matrix.m_matrix[4] + m_matrix[4]*matrix.m_matrix[5] + m_matrix[8]*matrix.m_matrix[6];
	newMatrix[5] := m_matrix[1]*matrix.m_matrix[4] + m_matrix[5]*matrix.m_matrix[5] + m_matrix[9]*matrix.m_matrix[6];
	newMatrix[6] := m_matrix[2]*matrix.m_matrix[4] + m_matrix[6]*matrix.m_matrix[5] + m_matrix[10]*matrix.m_matrix[6];
	newMatrix[7] := 0;

	newMatrix[8] := m_matrix[0]*matrix.m_matrix[8] + m_matrix[4]*matrix.m_matrix[9] + m_matrix[8]*matrix.m_matrix[10];
	newMatrix[9] := m_matrix[1]*matrix.m_matrix[8] + m_matrix[5]*matrix.m_matrix[9] + m_matrix[9]*matrix.m_matrix[10];
	newMatrix[10] := m_matrix[2]*matrix.m_matrix[8] + m_matrix[6]*matrix.m_matrix[9] + m_matrix[10]*matrix.m_matrix[10];
	newMatrix[11] := 0;

	newMatrix[12] := m_matrix[0]*matrix.m_matrix[12] + m_matrix[4]*matrix.m_matrix[13] + m_matrix[8]*matrix.m_matrix[14] + m_matrix[12];
	newMatrix[13] := m_matrix[1]*matrix.m_matrix[12] + m_matrix[5]*matrix.m_matrix[13] + m_matrix[9]*matrix.m_matrix[14] + m_matrix[13];
	newMatrix[14] := m_matrix[2]*matrix.m_matrix[12] + m_matrix[6]*matrix.m_matrix[13] + m_matrix[10]*matrix.m_matrix[14] + m_matrix[14];
	newMatrix[15] := 1;

	setMatrixValues( newMatrix );
end;

{---------------------------------------------------------------------}
{  Rotate a vector by the inverse of the rotation part of this matrix.}
{---------------------------------------------------------------------}
procedure clsMatrix.rotateVect(var pVect : array of single);
var vec : array [0..2] of single;
begin

  vec[0] := pVect[0]*m_matrix[0]+pVect[1]*m_matrix[4]+pVect[2]*m_matrix[8];
	vec[1] := pVect[0]*m_matrix[1]+pVect[1]*m_matrix[5]+pVect[2]*m_matrix[9];
	vec[2] := pVect[0]*m_matrix[2]+pVect[1]*m_matrix[6]+pVect[2]*m_matrix[10];

  pVect[0] := vec[0];
  pVect[1] := vec[1];
  pVect[2] := vec[2];

end;

{---------------------------------------------------------------------}
{  Make an inverted rotation matrix from Euler angles.                }
{  The 4th row and column are unmodified.                             }
{---------------------------------------------------------------------}
procedure clsMatrix.setInverseRotationDegrees(angles : array of single);
var vec : array [0..2] of single;
begin

	vec[0] := angles[0]*180.0/PI ;
	vec[1] := angles[1]*180.0/PI ;
	vec[2] := angles[2]*180.0/PI ;
	setInverseRotationRadians( vec );
end;

{---------------------------------------------------------------------}
{  Make an inverted rotation matrix from Euler angles.                }
{  The 4th row and column are unmodified.                             }
{---------------------------------------------------------------------}
procedure clsMatrix.setInverseRotationRadians(angles : array of single);
var cr , sr , cp , sp , cy , sy , srsp , crsp : single;
begin

  cr := cos( angles[0] );
	sr := sin( angles[0] );
	cp := cos( angles[1] );
	sp := sin( angles[1] );
	cy := cos( angles[2] );
	sy := sin( angles[2] );

	m_matrix[0] := cp*cy ;
	m_matrix[4] := cp*sy ;
	m_matrix[8] := -sp ;

	srsp := sr*sp;
	crsp := cr*sp;

	m_matrix[1] := srsp*cy-cr*sy ;
	m_matrix[5] := srsp*sy+cr*cy ;
	m_matrix[9] := sr*cp ;

	m_matrix[2] := crsp*cy+sr*sy ;
	m_matrix[6] := crsp*sy-sr*cy ;
	m_matrix[10] := cr*cp ;
end;

{---------------------------------------------------------------------}
{  Set the inverse translation of the current matrix.                 }
{  Will erase any previous values.                                    }
{---------------------------------------------------------------------}
procedure clsMatrix.setInverseTranslation(translation : array of single);
begin
  m_matrix[12] := -translation[0];
	m_matrix[13] := -translation[1];
	m_matrix[14] := -translation[2];
end;

{---------------------------------------------------------------------}
{  Set the values of the matrix.                                      }
{---------------------------------------------------------------------}
procedure clsMatrix.setMatrixValues(matrix : array of single);
var i : integer;
begin
  for i := 0 to 15 do
    m_matrix[i] := matrix[i];

end;

{---------------------------------------------------------------------}
{  Make a rotation matrix from Euler angles.                          }
{  The 4th row and column are unmodified.                             }
{---------------------------------------------------------------------}
procedure clsMatrix.setRotationDegrees(angles : array of single);
var vec : array [0..2] of single;
begin
	vec[0] := angles[0]*180.0/PI ;
	vec[1] := angles[1]*180.0/PI ;
	vec[2] := angles[2]*180.0/PI ;
	setRotationRadians( vec );
end;

{---------------------------------------------------------------------}
{  Make a rotation matrix from Euler angles.                          }
{  The 4th row and column are unmodified.                             }
{---------------------------------------------------------------------}
procedure clsMatrix.setRotationRadians(angles : array of single);
var cr , sr , cp , sp , cy , sy , srsp , crsp : single;
begin

  cr := cos( angles[0] );
	sr := sin( angles[0] );
	cp := cos( angles[1] );
	sp := sin( angles[1] );
	cy := cos( angles[2] );
	sy := sin( angles[2] );

	m_matrix[0] := cp*cy ;
	m_matrix[1] := cp*sy ;
	m_matrix[2] := -sp ;

  if m_matrix[2] = -0 then
    m_matrix[2] := 0;

	srsp := sr*sp;
	crsp := cr*sp;

	m_matrix[4] := srsp*cy-cr*sy ;
	m_matrix[5] := srsp*sy+cr*cy ;
	m_matrix[6] := sr*cp ;

	m_matrix[8] := crsp*cy+sr*sy ;
	m_matrix[9] := crsp*sy-sr*cy ;
	m_matrix[10] := cr*cp ;
end;

{---------------------------------------------------------------------}
{  Set the translation of the current matrix.                         }
{  Will erase any previous values.                                    }
{---------------------------------------------------------------------}
procedure clsMatrix.setTranslation(translation : array of single);
begin
  m_matrix[12] := translation[0];
  m_matrix[13] := translation[1];
  m_matrix[14] := translation[2];
end;

{---------------------------------------------------------------------}
{  Translate Vector                                                   }
{---------------------------------------------------------------------}
procedure clsMatrix.translateVect(var pVect : array of single);
begin
  pVect[0] := pVect[0]+m_matrix[12];
  pVect[1] := pVect[1]+m_matrix[13];
  pVect[2] := pVect[2]+m_matrix[14];
end;

{---------------------------------------------------------------------}
{  Translate a vector by the inverse                                  }
{  of the translation part of this matrix.                            }
{---------------------------------------------------------------------}
procedure clsMatrix.inverseTranslateVect(var pVect : array of single);
begin

  pVect[0] := pVect[0]-m_matrix[12];
	pVect[1] := pVect[1]-m_matrix[13];
	pVect[2] := pVect[2]-m_matrix[14];
end;

end.
