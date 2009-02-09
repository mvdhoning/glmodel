unit MeshGen;

interface

Uses Mesh, glMath;

type
  TMeshGen = class(TBaseMesh)
  protected
  public
    procedure GenerateCube(width:single; height: single; depth: single);
  end;

implementation

procedure TMeshGen.GenerateCube(width: single; height: single; depth: single);
var
  v1: T3dPoint;
  map: TMap;
  tel: integer;
begin
  self.NumVertex := 8; //number of vertexes
  v1.x := -1.0;
  v1.y := -1.0;
  v1.z := -1.0;
  self.Vertex[0]:=v1;
  v1.x := -1.0;
  v1.y := -1.0;
  v1.z := 1.0;
  self.Vertex[1]:=v1;
  v1.x := -1.0;
  v1.y := 1.0;
  v1.z := -1.0;
  self.Vertex[2]:=v1;
  v1.x := -1.0;
  v1.y := 1.0;
  v1.z := 1.0;
  self.Vertex[3]:=v1;
  v1.x := 1.0;
  v1.y := -1.0;
  v1.z := -1.0;
  self.Vertex[4]:=v1;
  v1.x := 1.0;
  v1.y := -1.0;
  v1.z := 1.0;
  self.Vertex[5]:=v1;
  v1.x := 1.0;
  v1.y := 1.0;
  v1.z := -1.0;
  self.Vertex[6]:=v1;
  v1.x := 1.0;
  v1.y := 1.0;
  v1.z := 1.0;
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
  for tel:=0 to 35 do
  begin
    self.Map[tel]:=0;
  end;

  //make mesh visible
  self.Visible:=true;
end;

end.
