#ifndef ZY_CUSTOM_SURFACEDATA
#define ZY_CUSTOM_SURFACEDATA

struct ZYSurfaceData{
    half3 albedo;
    half3 specular;
    half roughness;
    half metallic;
    half occlusion;
    half height;
    half3 normalWS;
    half3 emission;
    half alpha;
};

#endif 