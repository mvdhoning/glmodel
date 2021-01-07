unit Material;

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


uses classes;

type

  TBaseMaterial = class;

  TBaseMaterialClass = class of TBaseMaterial;

  TBaseMaterial = class(TComponent)
  protected
    FId: Integer;
    FAmbB: Single;
    FAmbG: Single;
    FAmbR: Single;
    FDifB: Single;
    FDifG: Single;
    FDifR: Single;
    FSpcB: Single;
    FSpcG: Single;
    FSpcR: Single;
    FEmiB: Single;
    FEmiG: Single;
    FEmiR: Single;
    FShininess: Single;
    FTransparency: Single;
    FIsAmbient: Boolean;
    FIsDiffuse: Boolean;
    FIsSpecular: Boolean;
    FIsEmissive: Boolean;
    FBumpMapFilename: string;
    FBumpmapstrength: Single;
    FFileName: string;
    FHasBumpmap: Boolean;
    FHasMaterial: Boolean;
    FHasOpacmap: Boolean;
    FHasTexturemap: Boolean;
    FName: string;
    FOpacMapFilename: string;
    FRot: Single;
    FTexId: Integer;
    FTwoSided: Boolean;
    FUoff: Single;
    FUs: Single;
    FVoff: Single;
    FVs: Single;

  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
    property Id: Integer read FId write FId;
    property AmbientBlue: Single read FAmbB write FAmbB;
    property AmbientGreen: Single read FAmbG write FAmbG;
    property AmbientRed: Single read FAmbR write FAmbR;
    property DiffuseBlue: Single read FDifB write FDifB;
    property DiffuseGreen: Single read FDifG write FDifG;
    property DiffuseRed: Single read FDifR write FDifR;
    property SpecularBlue: Single read FSpcB write FSpcB;
    property SpecularGreen: Single read FSpcG write FSpcG;
    property SpecularRed: Single read FSpcR write FSpcR;
    property EmissiveBlue: Single read FEmiB write FEmiB;
    property EmissiveGreen: Single read FEmiG write FEmiG;
    property EmissiveRed: Single read FEmiR write FEmiR;
    property Shininess: Single read FShininess write FShininess;
    property Transparency: Single read FTransparency write FTransparency;
    property IsAmbient: Boolean read FIsAmbient write FIsAmbient;
    property IsDiffuse: Boolean read FIsDiffuse write FIsDiffuse;
    property IsSpecular: Boolean read FIsSpecular write FIsSpecular;
    property IsEmissive: Boolean read FIsEmissive write FIsEmissive;
    property BumpMapFilename: string read FBumpMapFilename write
            FBumpMapFilename;
    property Bumpmapstrength: Single read FBumpmapstrength write
            FBumpmapstrength;
    property HasBumpmap: Boolean read FHasBumpmap write FHasBumpmap;
    property HasMaterial: Boolean read FHasMaterial write FHasMaterial;
    property HasOpacmap: Boolean read FHasOpacmap write FHasOpacmap;
    property HasTexturemap: Boolean read FHasTexturemap write FHasTexturemap;
    property Name: string read FName write FName;
    property FileName: string read FFileName write FFileName;
    property OpacMapFilename: string read FOpacMapFilename write
            FOpacMapFilename;
    property Rotate: Single read FRot write FRot;
    property TexID: Integer read FTexId write FTexID;
    property TextureFilename: string read FFileName write FFileName;
    property TextureID: Integer read FTexId;
    property TwoSided: Boolean read FTwoSided write FTwoSided;
    property Uoff: Single read FUoff write FUoff;
    property Us: Single read FUs write FUs;
    property Voff: Single read FVoff write FVoff;
    property Vs: Single read FVs write FVs;
    procedure Apply; virtual; abstract;
    procedure UpdateTexture; virtual; abstract;
  end;

implementation

uses
  SysUtils;

procedure TBaseMaterial.Assign(Source: TPersistent);
begin
if Source is TBaseMaterial then
  begin
    With TBaseMaterial(source) do
    begin
      self.FAmbB := FAmbB;
      self.FAmbG := FAmbG;
      self.FAmbR := FAmbR;
      self.FBumpMapFilename := FBumpMapFilename;
      self.FBumpmapstrength := FBumpmapstrength;
      self.FDifB := FDifB;
      self.FDifG := FDifG;
      self.FDifR := FDifR;
      self.FFileName := FFileName;
      self.FHasBumpmap := FHasBumpmap;
      self.FHasMaterial := FHasMaterial;
      self.FHasOpacmap := FHasOpacmap;
      self.FHasTexturemap := FHasTexturemap;
      self.FIsAmbient := FIsAmbient;
      self.FIsDiffuse := FIsDiffuse;
      self.FIsSpecular := FIsSpecular;
      self.FName := FName;
      self.FOpacMapFilename := FOpacMapFilename;
      self.FRot := FRot;
      self.FSpcB := FSpcB;
      self.FSpcG := FSpcG;
      self.FSpcR := FSpcR;
      self.FTexId := FTexId;
      self.FTransparency := FTransparency;
      self.FTwoSided := FTwoSided;
      self.FUoff := FUoff;
      self.FUs := FUs;
      self.FVoff := FVoff;
      self.FVs := FVs;
      self.FShininess := FShininess;
    end;
  end
  else
    inherited;
end;

constructor TBaseMaterial.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDifR := 1.0;
  FDifG := 1.0;
  FDifB := 1.0;
  FIsDiffuse := False;
  FAmbR := 0.0;
  FAmbG := 0.0;
  FAmbB := 0.0;
  FIsAmbient := False;
  FSpcR := 0.0;
  FSpcG := 0.0;
  FSpcB := 0.0;
  FIsSpecular := False;
  FShininess:=0.0;
  FHasTextureMap := False;
  FTransparency := 1.0;
end;

end.
