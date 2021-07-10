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
#define wind_dir_change_speed 0.005
#define wobble_strength 0.4
#define wobble_speed 1.5
#define gust_strength 0.4

// Utils

#define atlasTileDim 1024.0 // Atlas dimensions in texture tiles
#define tileSizePixels 16.0 // Texture tile size in pixels

#define VERTICES_ATLAS_TEXTURE(u, v, x, y) x >= u/atlasTileDim && x <= (u+16)/atlasTileDim && y >= v/atlasTileDim && y <= (v+16)/atlasTileDim
#define VERTICES_ATLAS_TEXTURE_TOP(u, v, x, y) x >= u/atlasTileDim && x <= (u+16)/atlasTileDim && y >= v/atlasTileDim && y <= (v+1)/atlasTileDim

// Leaves
#define VERTICES_ACACIA_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/acacia_leaves'].u }}, {{ texture_atlas.uvs['block/acacia_leaves'].v }}, x, y)
#define VERTICES_AZALEA_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/azalea_leaves'].u }}, {{ texture_atlas.uvs['block/azalea_leaves'].v }}, x, y)
#define VERTICES_BIRCH_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/birch_leaves'].u }}, {{ texture_atlas.uvs['block/birch_leaves'].v }}, x, y)
#define VERTICES_DARK_OAK_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/dark_oak_leaves'].u }}, {{ texture_atlas.uvs['block/dark_oak_leaves'].v }}, x, y)
#define VERTICES_FLOWERING_AZALEA_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/flowering_azalea_leaves'].u }}, {{ texture_atlas.uvs['block/flowering_azalea_leaves'].v }}, x, y)
#define VERTICES_JUNGLE_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/jungle_leaves'].u }}, {{ texture_atlas.uvs['block/jungle_leaves'].v }}, x, y)
#define VERTICES_OAK_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/oak_leaves'].u }}, {{ texture_atlas.uvs['block/oak_leaves'].v }}, x, y)
#define VERTICES_SPRUCE_LEAVES(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/spruce_leaves'].u }}, {{ texture_atlas.uvs['block/spruce_leaves'].v }}, x, y)

// Grass
#define VERTICES_GRASS(x, y) VERTICES_ATLAS_TEXTURE_TOP({{ texture_atlas.uvs['block/grass'].u }}, {{ texture_atlas.uvs['block/grass'].v }}, x, y)
#define VERTICES_TALL_GRASS_TOP(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/tall_grass_top'].u }}, {{ texture_atlas.uvs['block/tall_grass_top'].v }}, x, y)
#define VERTICES_TALL_GRASS_TOP_TOP(x, y) VERTICES_ATLAS_TEXTURE_TOP({{ texture_atlas.uvs['block/tall_grass_top'].u }}, {{ texture_atlas.uvs['block/tall_grass_top'].v }}, x, y)
#define VERTICES_TALL_GRASS_BOTTOM(x, y) VERTICES_ATLAS_TEXTURE_TOP({{ texture_atlas.uvs['block/tall_grass_bottom'].u }}, {{ texture_atlas.uvs['block/tall_grass_bottom'].v }}, x, y)

// Other
#define VERTICES_AZALEA_SIDE(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/azalea_side'].u }}, {{ texture_atlas.uvs['block/azalea_side'].v }}, x, y)
#define VERTICES_AZALEA_TOP(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/azalea_top'].u }}, {{ texture_atlas.uvs['block/azalea_top'].v }}, x, y)
#define VERTICES_FLOWERING_AZALEA_SIDE(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/flowering_azalea_side'].u }}, {{ texture_atlas.uvs['block/flowering_azalea_side'].v }}, x, y)
#define VERTICES_FLOWERING_AZALEA_TOP(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/flowering_azalea_top'].u }}, {{ texture_atlas.uvs['block/flowering_azalea_top'].v }}, x, y)
#define VERTICES_AZALEA_PLANT_TOP(x, y) VERTICES_ATLAS_TEXTURE_TOP({{ texture_atlas.uvs['block/azalea_plant'].u }}, {{ texture_atlas.uvs['block/azalea_plant'].v }}, x, y)
#define VERTICES_VINE(x, y) VERTICES_ATLAS_TEXTURE({{ texture_atlas.uvs['block/vine'].u }}, {{ texture_atlas.uvs['block/vine'].v }}, x, y)

void main() {
    vec3 position = Position + ChunkOffset;
    float time = GameTime * 1000.0;

    float offset_x = 0.0;
    float offset_z = 0.0;


    // Wind (same for every tree)
    #define wind_oscillation_t (0.8 + sin(time*wind_oscillation_speed))
    #define wind_oscillation_strength_t (2 + sin(time/30)*1.5)
    float wind_strength_t = wind_oscillation_t * wind_oscillation_strength_t * wind_strength;
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

    if(
        VERTICES_ACACIA_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_AZALEA_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_BIRCH_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_DARK_OAK_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_FLOWERING_AZALEA_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_JUNGLE_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_OAK_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_SPRUCE_LEAVES(UV_Texture.x, UV_Texture.y)
        || VERTICES_VINE(UV_Texture.x, UV_Texture.y)
    ) {
        // Leave blocks
        offset_x = wind_x + wobble_x + gust_x;
        offset_z = wind_z + wobble_z + gust_z;
    } else if(VERTICES_TALL_GRASS_TOP_TOP(UV_Texture.x, UV_Texture.y)) {
        // Upper block of 2 tall blocks
        offset_x = wind_x*2 + wobble_x + gust_x*0.7;
        offset_z = wind_z*2 + wobble_z + gust_z*0.7;
    } else if(
        VERTICES_GRASS(UV_Texture.x, UV_Texture.y)
        || VERTICES_TALL_GRASS_BOTTOM(UV_Texture.x, UV_Texture.y)
        || VERTICES_TALL_GRASS_TOP(UV_Texture.x, UV_Texture.y)
        || VERTICES_AZALEA_SIDE(UV_Texture.x, UV_Texture.y)
        || VERTICES_AZALEA_TOP(UV_Texture.x, UV_Texture.y)
        || VERTICES_FLOWERING_AZALEA_SIDE(UV_Texture.x, UV_Texture.y)
        || VERTICES_FLOWERING_AZALEA_TOP(UV_Texture.x, UV_Texture.y)
        || VERTICES_AZALEA_PLANT_TOP(UV_Texture.x, UV_Texture.y)
    ) {
        // 1 tall blocks
        offset_x = wind_x*1.4 + wobble_x + gust_x*0.7;
        offset_z = wind_z*1.4 + wobble_z + gust_z*0.7;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(Position + ChunkOffset + vec3(offset_x / tileSizePixels, 0.0, offset_z / tileSizePixels), 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV_Mipped_Texture);
    texCoord0 = UV_Texture;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
