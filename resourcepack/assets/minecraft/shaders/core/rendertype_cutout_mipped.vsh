#version 150

in vec3 Position;
in vec4 Color;
in vec2 UV0;
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

#define atlas_size 1024.0
#define texture_size 16.0
#define IS_TEXTURE(tx, ty, uvx, uvy) uvx >= tx/atlas_size && uvx <= tx/atlas_size + texture_size/atlas_size && uvy >= ty/atlas_size && uvy <= ty/atlas_size + texture_size/atlas_size
#define IS_TEXTURE_H(tx, ty, height, uvx, uvy) uvx >= tx/atlas_size && uvx <= tx/atlas_size + texture_size/atlas_size && uvy >= ty/atlas_size && uvy <= ty/atlas_size + height/atlas_size
#define IS_TEXTURE_W(tx, ty, width, uvx, uvy) uvx >= tx/atlas_size && uvx <= tx/atlas_size + width/atlas_size && uvy >= ty/atlas_size && uvy <= ty/atlas_size + texture_size/atlas_size

#define IS_OAK(uvx, uvy) IS_TEXTURE_H(144.0, 72.0, 216.0, uvx, uvy)
#define IS_DARK_OAK(uvx, uvy) IS_TEXTURE(288.0, 64.0, uvx, uvy)
#define IS_SPRUCE(uvx, uvy) IS_TEXTURE(16.0, 368.0, uvx, uvy)
#define IS_ACACIA(uvx, uvy) IS_TEXTURE_W(144.0, 72.0, 12.0, uvx, uvy)
#define IS_BIRCH(uvx, uvy) IS_TEXTURE(256.0, 48.0, uvx, uvy)

void main() {
    vec3 position = Position + ChunkOffset;
    float time = GameTime * 1000.0;

    float offset_x = 0.0;
    float offset_z = 0.0;

    if(IS_DARK_OAK(UV0.x, UV0.y) || IS_OAK(UV0.x, UV0.y) || IS_SPRUCE(UV0.x, UV0.y) || IS_ACACIA(UV0.x, UV0.y) || IS_BIRCH(UV0.x, UV0.y)) {
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

    gl_Position = ProjMat * ModelViewMat * (vec4(position, 1.0) + vec4(offset_x / texture_size, 0.0, offset_z / texture_size, 0.0));

    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
