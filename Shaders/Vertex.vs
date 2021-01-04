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
	if(index >= 0) {
      newVertex = (bonemat[index] * vertex);
      newNormal = (bonemat[index] * vec4(normal, 0.0));
	}
	else {
	  newVertex = vertex;
      newNormal = vec4(normal, 0.0);
	}
	
    fragmentColor = color;
	
	fragmentTexCoord = texCoord;
	
	fragmentNormal = (modelViewMatrix*newNormal).xyz;

	gl_Position = projectionMatrix*modelViewMatrix*newVertex;
}
