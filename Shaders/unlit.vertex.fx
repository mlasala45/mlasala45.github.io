#ifdef GL_ES
precision mediump float;
#endif

attribute vec3 position;
//attribute vec2 uv;
#include<instancesDeclaration>

//varying vec2 vUV;
uniform mat4 viewProjection;

void main() {
    //vUV = uv;
#include<instancesVertex>
    vec4 p = vec4(position, 1.0);
    gl_Position = viewProjection * finalWorld * p;
}