#ifndef ZY_CUSTOM_SURFACEDATA
#define ZY_CUSTOM_SURFACEDATA

struct ZYSurfaceData{
    half3 albedo;
    half3 specular;
    half roughness;
    half metallic;
    half occlusion;
    half height;
    half3 normalTS;
    half3 emission;
    half alpha;
};

#ifndef INIT_ZY_SURFACEDATA
#define INIT_ZY_SURFACEDATA(uv) InitSurfaceData(uv)
InitSurfaceData(float2 uv){
    ZYSurfaceData surfaceData = (ZYSurfaceData)0;
    surfaceData.albedo = 0.75;
    surfaceData.specular = (half3)0;
    surfaceData.roughness = 0.5;
    surfaceData.metallic = 0;
    surfaceData.occlusion = 1;
    surfaceData.height = 0;
    surfaceData.normalTS = 0;
    surfaceData.emission = 0;
    surfaceData.alpha = 1;
    return surfaceData;
}
#endif

#endif 