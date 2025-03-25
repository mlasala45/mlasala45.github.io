uniform mat4 u_inverseViewProjection;
uniform vec3 u_cameraPosition;

uniform int u_numArms;
uniform float u_swirlFactor;
uniform float u_armClusteringPow;
uniform float u_armClusteringFactor;

varying vec2 vUV; // v_uv should be provided by your vertex shader (0.0 - 1.0)

const float PI = 3.14159265359;
float galaxyDensityFunction(float theta, float rNormalized, float r) {
    float angPerArm = 2.0 * PI / u_numArms;

    float effectiveTheta = theta;

    float closestArmTheta = angPerArm * round(effectiveTheta / angPerArm);

    float x = r * cos(theta);
    float z = r * sin(theta);

    float rClosestPoint = x * cos(closestArmTheta) + z * sin(closestArmTheta);
    float xClosestPoint = rClosestPoint * cos(closestArmTheta);
    float zClosestPoint = rClosestPoint * sin(closestArmTheta);

    float distToArm = distance(vec2(xClosestPoint, zClosestPoint), vec2(x, z));

    float maxDist = u_armClusteringFactor / rNormalized;
    float armDensity = 1.0 - (distToArm / maxDist);

    float distanceFromCenterBias = 1.0 - rNormalized;

    float rNormalizedClamped = clamp(rNormalized, 0, 1);
    return (armDensity - distanceFromCenterBias) * (1.0 - rNormalizedClamped);
}

float calculateDensity(vec3 pos) {
    const float discRadius = 10.0;

    float r = length(vec2(pos.x, pos.z));
    float theta = atan(pos.z, pos.x); // atan2(y, x) gives correct signed angle
    float rNormalized = r / discRadius;

    float thicknessMult = 1 - rNormalized;
    thicknessMult = pow(thicknessMult, 2.5);
    if(abs(pos.y) > 1 * thicknessMult) return 0;

    theta -= u_swirlFactor * rNormalized;

    float density = galaxyDensityFunction(theta, rNormalized, r);
    if(density < 0) return 0;

    return density;
}

void main() {
    // Convert UV to NDC coordinates (-1 to 1)
    vec2 ndc = vUV * 2.0 - 1.0;

    // Create a clip space position at the near plane (z = 0)
    vec4 clipPos = vec4(ndc, 0.0, 1.0);

    // Transform clip space position to world space
    vec4 worldPos = u_inverseViewProjection * clipPos;
    // Perspective division to get the 3D coordinates
    worldPos /= worldPos.w;

    // Compute the ray direction from the camera position to the world position
    vec3 rayDir = normalize(worldPos.xyz - u_cameraPosition);

    vec3 u_boxMin = vec3(-8,-1,-8);
    vec3 u_boxMax = abs(u_boxMin);

    // Ray-AABB intersection using the slab method.
    vec3 invDir = 1.0 / rayDir;
    vec3 t0 = (u_boxMin - u_cameraPosition) * invDir;
    vec3 t1 = (u_boxMax - u_cameraPosition) * invDir;

    // For each axis, compute the entry and exit times
    vec3 tsmaller = min(t0, t1);
    vec3 tbigger  = max(t0, t1);

    // Find the largest entry time and smallest exit time
    float tMin = max(max(tsmaller.x, tsmaller.y), tsmaller.z);
    float tMax = min(min(tbigger.x, tbigger.y), tbigger.z);

    // Check if the ray intersects the AABB
    if (tMax < 0.0 || tMin > tMax) {
        // No intersection: output background color.
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // There is an intersection.
        // If the ray starts inside the box, tMin might be negative.
        float tEarlier = (tMin < 0.0) ? 0 : tMin;
        float tLater = tMax;

        // Compute the intersection point
        vec3 scanStartPoint = u_cameraPosition + tEarlier * rayDir;
        vec3 scanEndPoint  = u_cameraPosition + tLater * rayDir;
        float scanLength = length(scanEndPoint - scanStartPoint);

        // Example: use a simple shading based on the intersection point.
        // You can replace this with your desired shading logic.
        vec3 normal = normalize(scanStartPoint - (u_boxMin + u_boxMax) * 0.5);
        vec3 color = abs(normal);

        // Optionally, you might perform further sampling inside the box (similar to your galaxy density sampling)
        int sampleCount = 100;
        float stepSize = scanLength / sampleCount;
        float totalDensity = 0.0;
        for (float i = 0.0; i < float(sampleCount); i++) {
            float tStep = stepSize * i;
            vec3 pos = scanStartPoint + tStep * rayDir;

            float density = calculateDensity(pos);
            density *= 3;
            totalDensity += density * stepSize;
        }
        color = vec3(totalDensity);

        gl_FragColor = vec4(color, 1.0);
    }
}