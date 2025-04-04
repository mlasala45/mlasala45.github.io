#ifdef GL_ES
precision mediump float;
#endif

varying vec2 vUV;
uniform sampler2D textureSampler;

void main() {
    vec4 textureColor = texture2D(textureSampler, vUV);
    gl_FragColor = textureColor;
}
