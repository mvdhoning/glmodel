unit gl3Bone;

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

uses classes, Bone;

type
  Tgl3Bone = class(TBaseBone)
  public
    procedure Render; override;
  end;

implementation

uses DglOpengl, glmath;

procedure Tgl3Bone.Render;
var
  parentvertex, vertex: T3DPoint;

begin

  vertex.x := 0;
  vertex.y := 0;
  vertex.z := 0;
  vertex := MatrixTransform(FMatrix, Vertex);

  if FParent <> nil then
  begin
    parentvertex.x := 0;
    parentvertex.y := 0;
    parentvertex.z := 0;
    parentvertex := MatrixTransform(FParent.Matrix, ParentVertex);
  end;

  if FParent <> nil then
  begin
    //TODO: implement vbo rendering of bone lines and dots
    (*
    glLineWidth(1.0);
    glColor3f(1.0,0,0);
    glBegin(GL_LINES);
    glvertex3fv(@vertex);
    if fparent <> nil then
      glvertex3fv(@parentvertex)
    else
      glvertex3fv(@vertex);
    glend;

    glPointSize(2.0);
    glColor3f(1.0,0,1.0);
    glBegin(GL_POINTS);
    glvertex3fv(@vertex);
    if fparent <> nil then
      glvertex3fv(@parentvertex);
    glend;
    *)
  end;

end;

end.
