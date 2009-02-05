unit FileFormats3d;

interface

uses classes, model;

type

TModelFormat = record
  ModelClass: TBaseModelClass;
  Extension: string;
  Description: string;
end;

TModelFormatList = class
  protected
    FModelFormats: array of TModelFormat;
    FNumModelFormats: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Ext, Desc: string; AClass: TBaseModelClass);
    function FindExt(Ext: string): TBaseModelClass;
    procedure Remove(AClass: TBaseModelClass);
end;

implementation

{ TModelFormatList }

procedure TModelFormatList.Add(const Ext, Desc: string;
  AClass: TBaseModelClass);
begin
  FNumModelFormats := FNumModelFormats+1;
  SetLength(FModelFormats, FNumModelFormats);
  FModelFormats[FNumModelFormats-1].Extension := Ext;
  FModelFormats[FNumModelFormats-1].Description := Desc;
  FModelFormats[FNumModelFormats-1].ModelClass := AClass;
end;

constructor TModelFormatList.Create;
begin
  FNumModelFormats:=0;
end;

destructor TModelFormatList.Destroy;
begin
  FNumModelFormats:=0;
  SetLength(FModelFormats, FNumModelFormats);
  inherited;
end;

function TModelFormatList.FindExt(Ext: string): TBaseModelClass;
var
  i: integer;
begin
  result := nil;
  for i := 0 to FNumModelFormats - 1 do
  begin
    if FModelFormats[i].Extension = Ext then
    begin
      result := FModelFormats[i].ModelClass;
      exit;
    end;
  end;
end;

procedure TModelFormatList.Remove(AClass: TBaseModelClass);
var
  i: integer;
begin
  for i := FNumModelFormats - 1 downto 0 do
  begin
    if FModelFormats[i].ModelClass = AClass then
    begin
      FModelFormats[i].Extension := '';
      FModelFormats[i].Description := '';
      FModelFormats[i].ModelClass := nil;
      exit;
    end;
  end;
  //Now this does not realy remove the entry...
end;

end.
