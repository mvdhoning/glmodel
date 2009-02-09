unit MeshGen;

interface

Uses Mesh, glMath;

type
  TMeshGen = class(TBaseMesh)
  protected
  public
    procedure GenerateDisc(radius: single);
    procedure GeneratePlane(width: single; depth: single);
    procedure GenerateCube(width:single; height: single; depth: single);
  end;

implementation

procedure TMeshGen.GenerateDisc(radius: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
  
  n: integer;
  divider: integer;
  alpha: double;
  numberOfSeparators: integer;
begin
  n:=1; //number of segments;
  numberOfSeparators := (4 * n) +4;

  self.NumVertex := numberOfSeparators+1;
  self.NumVertexIndices := (numberOfSeparators+1)*3;

  v1.x:=0;
  v1.y:=0;
  v1.z:=0;

  for divider := 0 to numberOfSeparators do
  begin
    alpha := PI / 2 / (n + 1) * divider;
    v1.x:=radius*System.Cos(alpha);
    v1.y:=0.0;
    v1.z:=-1 * radius * System.Sin(alpha);
    self.Vertex[divider]:=v1;

    self.FVertexIndices[(divider*3)+0]:=0;
    self.FVertexIndices[(divider*3)+1]:=divider+1;
    if divider = numberofseparators-1 then
      self.FVertexIndices[(divider*3)+2]:=1
    else
      self.FVertexIndices[(divider*3)+2]:=divider+2;
  end;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=numberOfSeparators+1; //for each face indices div 3
  self.NumNormalIndices:=(numberOfSeparators+1)*3;
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=1;
  self.NumMappingIndices:=(numberOfSeparators+1)*3;
  map.tu:=0;
  map.tv:=0;
  self.Mapping[0]:=map;
  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;

end;

procedure TMeshGen.GeneratePlane(width: single; depth: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
  cwidth: single;
  cdepth: single;
begin
  cwidth:=width / 2;
  cdepth:=depth / 2;

  self.NumVertex := 4; //number of vertexes

  v1.x := -1.0 * cwidth;
  v1.y := 0.0;
  v1.z := -1.0 * cdepth;
  self.Vertex[0]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := 0.0;
  v1.z := 1.0  * cdepth;
  self.Vertex[1]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 0.0;
  v1.z := -1.0 * cdepth;
  self.Vertex[2]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 0.0;
  v1.z := 1.0  * cdepth;
  self.Vertex[3]:=v1;

  self.NumVertexIndices := 6; //number of vertex indices

  self.Face[0]:=0;
  self.Face[1]:=1;
  self.Face[2]:=2;

  self.Face[3]:=2;
  self.Face[4]:=1;
  self.Face[5]:=3;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=2; //for each face indices div 3
  self.NumNormalIndices:=6;
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=1;
  self.NumMappingIndices:=6;
  map.tu:=0;
  map.tv:=0;
  self.Mapping[0]:=map;
  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;
end;

procedure TMeshGen.GenerateCube(width: single; height: single; depth: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
  cwidth: single;
  cheight: single;
  cdepth: single;
begin
  cwidth:=width / 2;
  cheight:=width / 2;
  cdepth:=depth / 2;

  self.NumVertex := 8; //number of vertexes
  v1.x := -1.0 * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[0]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[1]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[2]:=v1;
  v1.x := -1.0 * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[3]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[4]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := -1.0 * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[5]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := -1.0 * cdepth;
  self.Vertex[6]:=v1;
  v1.x := 1.0  * cwidth;
  v1.y := 1.0  * cheight;
  v1.z := 1.0  * cdepth;
  self.Vertex[7]:=v1;

  self.NumVertexIndices := 36; //number of vertex indices
  self.Face[0]:=0;
  self.Face[1]:=2;
  self.Face[2]:=4;

  self.Face[3]:=4;
  self.Face[4]:=2;
  self.Face[5]:=6;

  self.Face[6]:=0;
  self.Face[7]:=4;
  self.Face[8]:=1;

  self.Face[9]:=1;
  self.Face[10]:=4;
  self.Face[11]:=5;

  self.Face[12]:=0;
  self.Face[13]:=1;
  self.Face[14]:=2;

  self.Face[15]:=2;
  self.Face[16]:=1;
  self.Face[17]:=3;

  self.Face[18]:=4;
  self.Face[19]:=6;
  self.Face[20]:=5;

  self.Face[21]:=5;
  self.Face[22]:=6;
  self.Face[23]:=7;

  self.Face[24]:=2;
  self.Face[25]:=3;
  self.Face[26]:=6;

  self.Face[27]:=6;
  self.Face[28]:=3;
  self.Face[29]:=7;

  self.Face[30]:=1;
  self.Face[31]:=5;
  self.Face[32]:=3;

  self.Face[33]:=3;
  self.Face[34]:=5;
  self.Face[35]:=7;

  //apply dummy material
  self.MatName[0]:='';
  self.MatID[0]:=0;

  //add calculated normals ...
  self.NumNormals:=12; //for each face indices div 3
  self.NumNormalIndices:=36;
  self.CalculateNormals;

  //add fake texture coords
  self.NumMappings:=1;
  self.NumMappingIndices:=36;
  map.tu:=0;
  map.tv:=0;
  self.Mapping[0]:=map;
  for tel:=0 to self.NumMappingIndices-1 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;
end;

end.
