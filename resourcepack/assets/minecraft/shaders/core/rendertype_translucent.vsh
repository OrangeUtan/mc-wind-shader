#version 150

#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV_Texture;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform float GameTime;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

#define atlasTileDim 1024.0 // Atlas dimensions in texture tiles
#define tileSizePixels 16.0 // Texture tile size in pixels

#define VERTICES_ATLAS_TEXTURE(u, v, x, y) x >= u/atlasTileDim && x <= (u+16)/atlasTileDim && y >= v/atlasTileDim && y <= (v+16)/atlasTileDim

#define VERTICES_WATER_STILL(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/water_still'].u }}, {{ texture_atlas.uvs['block/water_still'].v }}, x, y)

void main() {
    vec3 position = Position + ChunkOffset;
    float time = GameTime * 1000.0;

    float offset_y = 0.0;
    if(VERTICES_WATER_STILL(UV_Texture.x, UV_Texture.y)) {
        offset_y = (sin(time + position.x) + cos(time + position.z)) * 0.05 - 0.05;
        offset_y += (sin(time*9 + position.x*4) + cos(time*9 + position.z*4)) * 0.008 - 0.008;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(Position + ChunkOffset + vec3(0.0, offset_y, 0.0), 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV_Texture;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
