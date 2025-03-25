@group(0) @binding(0) var tbuf : texture_storage_2d < rgba8unorm, write>;

@compute @workgroup_size(1, 1, 1)

fn main(@builtin(global_invocation_id) global_id : vec3<u32>)
{
    textureStore(tbuf, vec2<i32>(global_id.xy), vec4<f32>(1,1,0,1));
}
