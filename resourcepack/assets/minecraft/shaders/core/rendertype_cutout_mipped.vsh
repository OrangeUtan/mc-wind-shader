#version 150

#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV_Texture;
in ivec2 UV_Mipped_Texture;
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

#define atlasTileDim 64 // Atlas dimensions in texture tiles
#define tileSizePixels 16.0 // Texture tile size in pixels
float tileSizeAtlas = 1.0 / atlasTileDim; // Texture tile size relative to atlas size

#define IS_ATLAS_TEXTURE(row, column, uvx, uvy) uvx >= row*tileSizeAtlas && uvx <= (row+1)*tileSizeAtlas && uvy >= column*tileSizeAtlas && uvy <= (column+1)*tileSizeAtlas

#define IS_ACACIA_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(10, 6, uvx, uvy)
#define IS_AZALEA_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(12, 0, uvx, uvy)
#define IS_BIRCH_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(16, 2, uvx, uvy)
#define IS_DARK_OAK_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(18, 8, uvx, uvy)
#define IS_FLOWERING_AZALEA_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(23, 13, uvx, uvy)
#define IS_JUNGLE_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(28, 7, uvx, uvy)
#define IS_OAK_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(21, 17, uvx, uvy)
#define IS_SPRUCE_LEAVES(uvx, uvy) IS_ATLAS_TEXTURE(25, 23, uvx, uvy)

void main() {
    vec3 position = Position + ChunkOffset;
    float time = GameTime * 1000.0;

    float offset_x = 0.0;
    float offset_z = 0.0;

    if(
        IS_ACACIA_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_AZALEA_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_BIRCH_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_DARK_OAK_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_FLOWERING_AZALEA_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_JUNGLE_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_OAK_LEAVES(UV_Texture.x, UV_Texture.y)
        || IS_SPRUCE_LEAVES(UV_Texture.x, UV_Texture.y)
    ) {
        // Wind (same for every tree)
        float wind_strength = (0.8 + sin(time)) * (2 + sin(time/30)*1.5);
        #define wind_dir_change_speed 0.005
        #define wind_dir_x cos(time * wind_dir_change_speed)
        #define wind_dir_z sin(time * wind_dir_change_speed)
        float wind_x = wind_strength * wind_dir_x;
        float wind_z = wind_strength * wind_dir_z;

        // Wobble
        #define wobble_strength 0.4
        #define wobble_speed 2
        float wobble_x = wobble_strength * cos(position.x + time*wobble_speed);
        float wobble_z = wobble_strength * sin(position.z + time*wobble_speed);

        // Gust
        float gust_strength = max(0,sin(position.x/80 + time/5)*25-24) * 0.8;
        float gust_x = sin(position.x*3 + time*30)/4 * gust_strength;
        float gust_z = cos(position.z*3 + time*30)/4 * gust_strength;

        // Offsets
        offset_x = wind_x + wobble_x + gust_x;
        offset_z = wind_z + wobble_z + gust_z;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(Position + ChunkOffset + vec3(offset_x / tileSizePixels, 0.0, offset_z / tileSizePixels), 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV_Mipped_Texture);
    texCoord0 = UV_Texture;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
