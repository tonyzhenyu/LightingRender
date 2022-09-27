#ifndef FURSHELL_SURFACEDATA
#define FURSHELL_SURFACEDATA

struct FurShellSurfaceData{
    half3 albedo;
    half3 specular;
    half metallic;
    half roughness;
    half3 normalTS;
    half4 occlusion;
    //half height;
    half alpha;
    half3 emissionColor;
};

#endif
