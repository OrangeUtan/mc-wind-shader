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

// Settings
#define wind_strength 0.5
#define wind_oscillation_speed 0.8
#define wobble_strength 0.4
#define wobble_speed 1.5
#define gust_strength 0.4

// Utils

#define atlasTileDim 1024.0 // Atlas dimensions in texture tiles
#define tileSizePixels 16.0 // Texture tile size in pixels

#define IS_ATLAS_TEXTURE(u, v, x, y) x >= u/atlasTileDim && x <= (u+16)/atlasTileDim && y >= v/atlasTileDim && y <= (v+16)/atlasTileDim

#define IS_ACACIA_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/acacia_leaves'].u }}, {{ texture_atlas.uvs['block/acacia_leaves'].v }}, x, y)
#define IS_AZALEA_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/azalea_leaves'].u }}, {{ texture_atlas.uvs['block/azalea_leaves'].v }}, x, y)
#define IS_BIRCH_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/birch_leaves'].u }}, {{ texture_atlas.uvs['block/birch_leaves'].v }}, x, y)
#define IS_DARK_OAK_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/dark_oak_leaves'].u }}, {{ texture_atlas.uvs['block/dark_oak_leaves'].v }}, x, y)
#define IS_FLOWERING_AZALEA_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/flowering_azalea_leaves'].u }}, {{ texture_atlas.uvs['block/flowering_azalea_leaves'].v }}, x, y)
#define IS_JUNGLE_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/jungle_leaves'].u }}, {{ texture_atlas.uvs['block/jungle_leaves'].v }}, x, y)
#define IS_OAK_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/oak_leaves'].u }}, {{ texture_atlas.uvs['block/oak_leaves'].v }}, x, y)
#define IS_SPRUCE_LEAVES(x, y) IS_ATLAS_TEXTURE({{ texture_atlas.uvs['block/spruce_leaves'].u }}, {{ texture_atlas.uvs['block/spruce_leaves'].v }}, x, y)

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
        #define wind_oscillation_t (0.8 + sin(time*wind_oscillation_speed))
        #define wind_oscillation_strength_t (2 + sin(time/30)*1.5)
        float wind_strength_t = wind_oscillation_t * wind_oscillation_strength_t * wind_strength;
        #define wind_dir_change_speed 0.005
        #define wind_dir_x cos(time * wind_dir_change_speed)
        #define wind_dir_z sin(time * wind_dir_change_speed)
        float wind_x = wind_strength_t * wind_dir_x;
        float wind_z = wind_strength_t * wind_dir_z;

        // Wobble
        float wobble_x = wobble_strength * cos(position.x + time*wobble_speed);
        float wobble_z = wobble_strength * sin(position.z + time*wobble_speed);

        // Gust
        float gust_strength_t = max(0,sin(position.x/80 + time/5)*25-24) * gust_strength;
        float gust_x = sin(position.x*3 + time*30)/4 * gust_strength_t;
        float gust_z = cos(position.z*3 + time*30)/4 * gust_strength_t;

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
