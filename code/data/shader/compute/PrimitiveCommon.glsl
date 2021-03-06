struct Vertex {
  vec3 pos;
  float u;
  vec3 norm;
  float v;
};

struct Primitive {
  Vertex a;
  Vertex b;
  Vertex c;
  uint matId;
  uint sortCode;
  vec2 pad_;
};

struct Ray {
  vec3 pos;
  vec3 dir;
};

struct Material {
  vec3 diffuseColor;
  float roughness;
  vec3 emissiveColor;
  float refractiveness;
  vec3 specularColor;
  float eta;
  uint diffuseTexId;
  uint specularTexId;
  uint emissiveTexId;
  uint normalTexId;
};

struct HitInfo {
  vec3 pos;
  vec3 norm;
  vec2 uv;
  float t;
  uint matId;
  mat3 tangentSpace;
  Material material;
};

struct SphereLight {
  vec3 center;
  float radius;
  vec4 color;
};

const float EPSILON = 0.00001;

bool intersectPrimitive(in Ray ray, in Primitive tri, out HitInfo hit) {
    const float INFINITY = 1e10;
    vec3 u, v, n; // triangle vectors
    vec3 w0, w;  // ray vectors
    float r, a, b; // params to calc ray-plane intersect

    // get triangle edge vectors and plane normal
    u = tri.b.pos - tri.a.pos;
    v = tri.c.pos - tri.a.pos;
    n = cross(u, v);

    w0 = ray.pos - tri.a.pos;
    a = -dot(n, w0);
    b = dot(n, ray.dir);
    if (abs(b) < 1e-5)
    {
        // ray is parallel to triangle plane, and thus can never intersect.
        return false;
    }

    // get intersect point of ray with triangle plane
    r = a / b;
    if (r < 1e-5)
        return false; // ray goes away from triangle.

    vec3 I = ray.pos + r * ray.dir;
    float uu, uv, vv, wu, wv, D;
    uu = dot(u, u);
    uv = dot(u, v);
    vv = dot(v, v);
    w = I - tri.a.pos;
    wu = dot(w, u);
    wv = dot(w, v);
    D = uv * uv - uu * vv;

    // get and test parametric coords
    float s, t;
    s = (uv * wv - vv * wu) / D;
    if (s < 0.0 || s > 1.0)
        return false;
    t = (uv * wu - uu * wv) / D;
    if (t < 0.0 || (s + t) > 1.0)
        return false;

    hit.norm = tri.a.norm * (1.0 - s - t) + tri.b.norm * s + tri.c.norm * t;
    hit.pos =  ray.pos + r * ray.dir;
    hit.t = r;
    hit.uv = vec2(tri.a.u, tri.a.v) * (1.0 - s - t) + vec2(tri.b.u, tri.b.v) * s + vec2(tri.c.u, tri.c.v) * t;
    hit.matId = tri.matId;

    hit.tangentSpace[0] = -normalize(v);
    hit.tangentSpace[2] = hit.norm; 
    hit.tangentSpace[1] = normalize(cross(hit.tangentSpace[2], hit.tangentSpace[0]));

    return true;
}

