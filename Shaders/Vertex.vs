#version 130

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

uniform mat4 bonemat[50];

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
    int index;

	index=int(boneindex.x);
    newVertex = (bonemat[index] * vertex) * 1.0;
    newNormal = (bonemat[index] * vec4(normal, 0.0))* 1.0;
	
    fragmentColor = color;
	
	fragmentTexCoord = texCoord;
	
	fragmentNormal = (modelViewMatrix*newNormal).xyz;

	gl_Position = projectionMatrix*modelViewMatrix*vec4(newVertex.xyz, 1.0);
}
