unit Render;

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
 * Portions created by the Initial Developer are Copyright (C) 2007
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

uses classes, model;

//TODO: implement render class
//has scene with models etc....
//override for dx and opengl

type TBaseRender = class(TComponent)
  protected
    FModels: array of TBaseModel;
    FNumModels: Integer;
    FName: string;
    function GetModel(Index: integer): TBaseModel;
    procedure SetModel(Index: integer; Value: TBaseModel);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Models[Index: integer]: TBaseModel read GetModel write SetModel;
    property NumModels: Integer read FNumModels;
    property Name: string read fname;
    procedure AddModel(Value: TBaseModel); overload; virtual;
    procedure AddModel; overload; virtual; abstract;
    procedure UpdateTextures;
    procedure AdvanceAnimation;
    procedure Render; overload; virtual; abstract;
    procedure Render(id: integer); overload; virtual; abstract;
    procedure Render(aModel: TBaseModel); overload; virtual; abstract;
    procedure Init; virtual; abstract;
end;

implementation

procedure TBaseRender.AddModel(Value: TBaseModel);
begin
  FNumModels := FNumModels + 1;
  SetLength(FModels, FNumModels);
  SetModel(FNumModels-1, Value);
end;

procedure TBaseRender.AdvanceAnimation;
var
  I: Integer;
begin
 for I := 0 to FNumModels-1 do
  begin
    //advance animation
    if FModels[i].NumSkeletons >= 1 then
    begin
      FModels[i].Skeleton[0].AdvanceAnimation();
      FModels[i].calculatesize; //TODO: does not help as mesh is altered during rendering...
    end;
  end;
end;

constructor TBaseRender.create(AOwner: TComponent);
begin
  inherited;
  FName := 'TBaseRender';
  FNumModels := 0;
end;

destructor TBaseRender.Destroy;
var
  I: Integer;
begin
  for I := 0 to FNumModels-1 do
  begin
    FModels[i].Free;
  end;
  SetLength(FModels,0);
  FModels:=nil;
  inherited;
end;

function TBaseRender.GetModel(Index: integer): TBaseModel;
begin
  Result := FModels[index];
end;

procedure TBaseRender.SetModel(Index: integer; Value: TBaseModel);
begin
  FModels[index] := Value;
end;

procedure TBaseRender.UpdateTextures;
var
  I: Integer;
begin
for I := 0 to FNumModels-1 do
  begin
    FModels[i].UpdateTextures;
  end;
end;

end.
