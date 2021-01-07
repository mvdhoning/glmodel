unit gl3Material;

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

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses classes, material, dglopengl, glBitmap;

type
  Tgl3Material= class(TBaseMaterial)
  private
    FTexture: TglBitmap2D;
  public
    destructor Destroy; override;
    procedure Apply; override;
    procedure UpdateTexture; override;
  end;

implementation

uses
  SysUtils, Model;

destructor Tgl3Material.Destroy;
begin
  if HasTexturemap = True then gldeletetextures(1, @TexId); //lets clean up afterwards...
  if HasTexturemap = True then ftexture.Free;
  inherited Destroy;
end;

procedure Tgl3Material.Apply;
begin
  inherited;

  if (FHastexturemap = True) AND (ftexture<>nil) then
  begin
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, ftexture.ID);

    //glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT);
    //glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

  end;

  //Two Sided Materials
  if FTwoSided then
    glDisable(GL_CULL_FACE)
  else
    glEnable(GL_CULL_FACE);

end;

procedure Tgl3Material.Updatetexture;
var
  hastexture: GLuint;
begin
  //create texture and load from file...
  if FHasTexturemap then
  begin
    FTexture:=TglBitmap2D.Create;
    //haal pad uit scene weg, moet anders nl dmv pad uit scene doorgeven aan materiaal
    if TBaseModel(self.owner).TexturePath <> '' then
      if fileexists(TBaseModel(self.owner).TexturePath + Trim(ExtractFileName(fileName))) then
        FTexture.LoadFromFile(TBaseModel(self.owner).TexturePath + Trim(ExtractFileName(FileName)))
    else
      if fileexists(fileName) then
        FTexture.LoadFromFile(FFileName);
  end;

  //now finish up the texture and load it to openl (videocard)
  if fHasTextureMap = true then
  begin
      FTexture.FlipVert; //why does it need to be flipped...
      FTexture.SetWrap(GL_REPEAT, GL_REPEAT, GL_REPEAT); //always repeat textures...? Renamed
      FTexture.MipMap:=mmMipmap; //is this kind of in available in 3ds file? Renamed
      FTexture.GenTexture(false);
      hastexture:=FTexture.Target;
      FTexId := hastexture;
  end;

end;

end.
