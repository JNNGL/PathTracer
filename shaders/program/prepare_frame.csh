#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform bool hideGUI;

void main() {
    quadBuffer.count = 0u;
    quadBuffer.aabb = scene_aabb(0, 0, 0, 0, 0, 0);

    if (hideGUI) {
        renderState.frame++;
        renderState.clear = false;
    } else {
        renderState.frame = 0;
        renderState.clear = true;
    }
}