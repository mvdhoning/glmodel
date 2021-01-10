unit glMaterial;

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

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses classes, material, dglopengl, glmath, glBitmap;

type
  TglMaterial= class(TBaseMaterial)
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

destructor TglMaterial.Destroy;
begin
  if HasTexturemap = True then gldeletetextures(1, @TexId); //lets clean up afterwards...
  if HasTexturemap = True then ftexture.Free;
  inherited Destroy;
end;

procedure TglMaterial.Apply;
var
  ambient, diffuse, specular, emissive: TGLCOLOR;
  power: Single;
begin
  inherited;

  diffuse.r := FDifR;
  diffuse.g := FDifG;
  diffuse.b := FDifB;
  diffuse.a := FTransparency;

    //if no ambient color data then also set diffuse for ambient
  if FIsAmbient then
  begin
    ambient.r := FAmbR;
    ambient.g := FAmbG;
    ambient.b := FAmbB;
    ambient.a := 1.0;
  end
  else
  begin
    ambient.r := FDifR/2;
    ambient.g := FDifG/2;
    ambient.b := FDifB/2;
    ambient.a := 1.0;
  end;

  specular.r := FSpcR;
  specular.g := FSpcG;
  specular.b := FSpcB;
  specular.a := 1.0;

  with emissive do
  begin
    r := 0.0;
    g := 0.0;
    b := 0.0;
    a := 1.0;
  end;
  power := FShininess;


  glMaterialfv(GL_FRONT, gl_ambient, @ambient);
  glMaterialfv(GL_FRONT, gl_diffuse, @diffuse);
  glMaterialfv(GL_FRONT, gl_specular, @specular);
  glMaterialfv(GL_FRONT, gl_shininess, @power);
  glMaterialfv(GL_FRONT, gl_emission, @emissive);


  if (FHastexturemap = True) AND (ftexture<>nil) then
  begin
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, ftexture.ID);

    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  {Texture does NOT blend with object background}

    //glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT);
    //glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

    //the following it not efficient... (maybe i should have a var containing the states)
    glDisable(GL_ALPHA_TEST);
    if FHasOpacMap then
      begin
       glEnable(GL_ALPHA_TEST);
       glActiveTexture(GL_TEXTURE1);
       glenable(GL_TEXTURE_2D);
       ftexture.Bind;
      end;



    if FHasBumpMap then
    begin
        //TODO: only change blendfunc when needed?
      If FTransParency = 1.0 then
        glBlendFunc(GL_SRC_ALPHA, GL_ZERO) //only fake bumpmapping
      else
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); //fake bumpmapping with transparency


      // RGB
      glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_COMBINE);

      glTexEnvf(GL_TEXTURE_ENV,GL_COMBINE_RGB,GL_MODULATE);
      glTexEnvf(GL_TEXTURE_ENV,GL_SOURCE0_RGB,GL_TEXTURE);
      glTexEnvf(GL_TEXTURE_ENV,GL_OPERAND0_RGB,GL_SRC_COLOR);
      glTexEnvf(GL_TEXTURE_ENV,GL_SOURCE1_RGB,GL_PREVIOUS);
      glTexEnvf(GL_TEXTURE_ENV,GL_OPERAND1_RGB,GL_SRC_COLOR);

      // alpha
      glTexEnvf(GL_TEXTURE_ENV,GL_COMBINE_ALPHA,GL_REPLACE);
      glTexEnvf(GL_TEXTURE_ENV,GL_SOURCE0_ALPHA,GL_TEXTURE{0});
      glTexEnvf(GL_TEXTURE_ENV,GL_OPERAND0_ALPHA,GL_SRC_ALPHA);
    end;

  end;

  if FHasBumpmap = True then
  begin
    glActiveTexture(GL_TEXTURE1);
    glenable(GL_TEXTURE_2D);
    ftexture.Bind;

      // RGB
    glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_COMBINE);
    glTexEnvf(GL_TEXTURE_ENV,GL_COMBINE_RGB,GL_REPLACE);
    glTexEnvf(GL_TEXTURE_ENV,GL_SOURCE0_RGB,GL_PREVIOUS);
    glTexEnvf(GL_TEXTURE_ENV,GL_OPERAND0_RGB,GL_SRC_COLOR);

      // alpha
    glTexEnvf(GL_TEXTURE_ENV,GL_COMBINE_ALPHA,GL_ADD_SIGNED);
    glTexEnvf(GL_TEXTURE_ENV,GL_SOURCE0_ALPHA,GL_TEXTURE);
    glTexEnvf(GL_TEXTURE_ENV,GL_OPERAND0_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    glTexEnvf(GL_TEXTURE_ENV,GL_SOURCE1_ALPHA,GL_PREVIOUS);
    glTexEnvf(GL_TEXTURE_ENV,GL_OPERAND1_ALPHA,GL_SRC_ALPHA);

  end;

  //Two Sided Materials
  if FTwoSided then
    glDisable(GL_CULL_FACE)
  else
    glEnable(GL_CULL_FACE);

end;

procedure EmptyFunc(Sender : TglBitmap; const Position, Size: TglBitmapPixelPosition;
  const Source: TglBitmapPixelData; Dest: TglBitmapPixelData; const Data: Pointer);
begin
    Dest.Red  := 255;
    Dest.Green := 255;
    Dest.Blue  := 255;
end;


procedure TglMaterial.Updatetexture;
var
  hastexture: GLuint;
  x, y: Integer;
  pos: TglBitmapPixelPosition;
begin
  //create texture and load from file...
  if FHasTexturemap then
  begin
    FTexture:=TglBitmap2D.Create;
    //haal pad uit scene weg, moet anders nl dmv pad uit scene doorgeven aan materiaal
    if TBaseModel(self.owner).TexturePath <> '' then
      if fileexists(TBaseModel(self.owner).TexturePath + ExtractFileName(fileName)) then
        FTexture.LoadFromFile(TBaseModel(self.owner).TexturePath + ExtractFileName(FFileName))
    else
      if fileexists(fileName) then
        FTexture.LoadFromFile(FFileName);
  end;

  //load the opacmap into the alpha channel when needed
  if FHasOpacmap then
  begin
    //create a texture if there is no texture...
    if Ftexture = nil then
    begin
      FTexture:=TglBitmap2D.Create;
      //First load opacmap to determine size
      if self.owner <> nil then
        Ftexture.LoadFromFile(TBaseModel(self.owner).TexturePath + FOpacMapFileName)
      else
        Ftexture.LoadFromFile(FOpacMapFileName);
      x:=Ftexture.Width;
      y:=Ftexture.Height;
      //Create empty white texture with size
      pos.X := x;
      pos.Y := y;
      FTexture.LoadFromFunc(pos, @EmptyFunc, ifRGBA8, nil);
      FHasTextureMap:=True;
    end;
    //now realy load in the alpha channel
    if self.owner <> nil then
      Ftexture.AddAlphaFromFile(TBaseModel(self.owner).TexturePath + FOpacMapFileName)
    else
      Ftexture.AddAlphaFromFile(lowercase(FOpacMapFileName));

    ftransparency:=1.0; //otherwise no effect visible?
    Ftexture.Invert(false,true); //to make it appear like in cinema4d

  end;

  //load the bumpmap into the alpha channel when needed
  if FHasBumpmap then
  begin
    //create a texture if there is no texture...
    if Ftexture = nil then
    begin
      FTexture:=TglBitmap2D.Create;
      //First load bumpmap to determine size
      if self.owner <> nil then
        Ftexture.LoadFromFile(lowercase(TBaseModel(self.owner).TexturePath + FBumpMapFileName))
      else
        Ftexture.LoadFromFile(FBumpMapFileName);
      x:=Ftexture.Width;
      y:=Ftexture.Height;
      //Create empty white texture with size
      pos.X := x;
      pos.Y := y;
      FTexture.LoadFromFunc(pos, @EmptyFunc, ifRGBA8, nil);
      FHasTextureMap:=True;
    end;
    //now realy load in the alpha channel
    if self.owner <> nil then
      Ftexture.AddAlphaFromFile(lowercase(TBaseModel(self.owner).TexturePath + FBumpMapFileName))
    else
      Ftexture.AddAlphaFromFile(lowercase(FBumpMapFileName));
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
