unit glBone;

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

uses classes, Bone;

type
  TglBone = class(TBaseBone)
  public
    procedure Render; override;
  end;

implementation

uses DglOpengl, glmath;

procedure TglBone.Render;
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

  //TODO: reimplement
  (*
  glPointSize(10.0);
  glBegin(GL_POINTS);
  glColor3f(255,0,0);
  glvertex3fv(@vertex);
  glend;

  if FParent <> nil then
  begin
    glBegin(GL_LINES);
    glColor3f(0,255,0);
    glvertex3fv(@vertex);
    glvertex3fv(@parentvertex);
    glend;

    glPointSize(10.0);
    glBegin(GL_POINTS);
    glColor3f(255,0,0);
    glvertex3fv(@parentvertex);
    glend;
  end;
  *)

end;

end.
