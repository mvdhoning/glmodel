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

                // Determinant of a 4x4 matrix
                function determinant(matrix : array of single): Single;

                procedure Adjoint(var matrix : array of single);

                procedure Scale(var matrix : array of single; Factor: Single);

                procedure Invert(var matrix : array of single);



	private
		//	Matrix data, stored in column-major order
		m_matrix : array [0..15] of single;
                function DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;

end;

   procedure MatrixMultiply(var aresult: array of single; const matrix0: array of single; const matrix1: array of single);

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
{  Multiply Matrices                                               }
{------------------------------------------------------------------}
procedure MatrixMultiply(var aresult: array of single; const matrix0: array of single; const matrix1: array of single);
var
  i, k: integer;
  temp: array [0..15] of single;
begin
	for i := 0 to 15 do
	begin
		temp[i] := 0.0;

		for k := 0 to 3 do
		begin
			//			  		row   column   		   row column
			temp[i] := temp[i]+ matrix0[(i mod 4)+(k*4)] * matrix1[k+((i div 4)*4)];
		end;
	end;

	for i := 0 to 15 do
	begin
		aresult[i] := temp[i];
	end;
end;

function clsMatrix.DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
// internal version for the determinant of a 3x3 matrix
begin
  Result := a1 * (b2 * c3 - b3 * c2) -
            b1 * (a2 * c3 - a3 * c2) +
            c1 * (a2 * b3 - a3 * b2);
end;

function clsMatrix.Determinant(matrix : array of single): Single;

// Determinant of a 4x4 matrix

var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4  : Single;



begin
  a1 := matrix[0];  b1 := matrix[1];  c1 := matrix[2];  d1 := matrix[3];
  a2 := matrix[4];  b2 := matrix[5];  c2 := matrix[6];  d2 := matrix[7];
  a3 := matrix[8];  b3 := matrix[9];  c3 := matrix[10];  d3 := matrix[11];
  a4 := matrix[12];  b4 := matrix[13];  c4 := matrix[14];  d4 := matrix[15];

  Result := a1 * DetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4) -
            b1 * DetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4) +
            c1 * DetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4) -
            d1 * DetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
end;

procedure clsMatrix.Adjoint(var matrix : array of single);

// Adjoint of a 4x4 matrix - used in the computation of the inverse
// of a 4x4 matrix

var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4: Single;


begin
    a1 :=  matrix[0]; b1 :=  matrix[1];
    c1 :=  matrix[2]; d1 :=  matrix[3];
    a2 :=  matrix[4]; b2 :=  matrix[5];
    c2 :=  matrix[6]; d2 :=  matrix[7];
    a3 :=  matrix[8]; b3 :=  matrix[9];
    c3 :=  matrix[10]; d3 :=  matrix[11];
    a4 :=  matrix[12]; b4 :=  matrix[13];
    c4 :=  matrix[14]; d4 :=  matrix[15];

    // row column labeling reversed since we transpose rows & columns
    matrix[0] :=  DetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);
    matrix[4] := -DetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);
    matrix[8] :=  DetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);
    matrix[12] := -DetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);

    matrix[1] := -DetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);
    matrix[5] :=  DetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);
    matrix[9] := -DetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);
    matrix[13] :=  DetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);

    matrix[2] :=  DetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);
    matrix[6] := -DetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);
    matrix[10] :=  DetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);
    matrix[14] := -DetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);

    matrix[3] := -DetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);
    matrix[7] :=  DetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);
    matrix[11] := -DetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);
    matrix[15] :=  DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);
end;

procedure clsMatrix.Scale(var matrix : array of single; Factor: Single);

// multiplies all elements of a 4x4 matrix with a factor

var i: integer;

begin
  for i := 0 to 15 do matrix[i] := matrix[i] * Factor;
end;

procedure clsMatrix.Invert(var matrix : array of single);

// finds the inverse of a 4x4 matrix

var Det: Single;
const   EPSILON  = 1e-100;

begin
  Det := self.Determinant(matrix);
  if Abs(Det) < EPSILON then
    begin
      matrix[0]  := 1;
      matrix[1]  := 0;
      matrix[2]  := 0;
      matrix[3]  := 0;

      matrix[4]  := 0;
      matrix[5]  := 1;
      matrix[6]  := 0;
      matrix[7]  := 0;

      matrix[8]  := 0;
      matrix[9]  := 0;
      matrix[10] := 1;
      matrix[11] := 0;

      matrix[12] := 0;
      matrix[13] := 0;
      matrix[14] := 0;
      matrix[15] := 1;

    end
    else
    begin
      self.Adjoint(matrix);
      self.Scale(matrix, 1 / Det);
    end;
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
