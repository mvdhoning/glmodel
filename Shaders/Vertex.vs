#version 130

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

uniform mat4 bonemat[50];

uniform float useBones;

in vec4 vertex;
in vec3 normal;
in vec3 color;
in vec2 texCoord;
in vec4 boneindex;
in vec4 boneweight;

out vec3 fragmentColor;
out vec3 fragmentNormal;
out vec2 fragmentTexCoord;

void main(void)
{
    vec4 newVertex;
    vec4 newNormal;
    
	if (useBones>0.0) {
		if (int(boneindex.x) >=0)  {
		  newVertex = ((bonemat[int(boneindex.x)] * vertex) * boneweight.x)+((bonemat[int(boneindex.y)] * vertex) * boneweight.y)+((bonemat[int(boneindex.z)] * vertex) * boneweight.z)+((bonemat[int(boneindex.w)] * vertex) * boneweight.w);
		  newNormal = ((bonemat[int(boneindex.x)] * vec4(normal, 0.0)) * boneweight.x)+((bonemat[int(boneindex.y)] * vec4(normal, 0.0)) * boneweight.y)+((bonemat[int(boneindex.z)] * vec4(normal, 0.0)) * boneweight.z)+((bonemat[int(boneindex.w)] * vec4(normal, 0.0)) * boneweight.w);
		}	
		else
		{
		  newVertex = vertex;
		  newNormal = vec4(normal, 0.0);
		}
	} 
	else 
	{
	  newVertex = vertex;
	  newNormal = vec4(normal, 0.0);
	}
    fragmentColor = color;
	
	fragmentTexCoord = texCoord;
	
	//fragmentNormal = vec3(boneindex.x, boneindex.y, boneindex.z) / (3 - 1.) * 2. - 1.; //debug bone indices
	fragmentNormal = (modelViewMatrix*newNormal).xyz;

	gl_Position = projectionMatrix*modelViewMatrix*vec4(newVertex.xyz, 1.0);
}