#ifndef INIT_ZY_SURFACEDATA
#define INIT_ZY_SURFACEDATA(input) InitSurfaceData(input)
ZYSurfaceData InitSurfaceData(Varyings input){
    ZYSurfaceData surfaceData = (ZYSurfaceData)0;
    surfaceData.albedo = 0.75;
    surfaceData.specular = (half3)0;
    surfaceData.roughness = 0.5;
    surfaceData.metallic = 0;
    surfaceData.occlusion = 1;
    surfaceData.height = 0;
    surfaceData.normalWS = input.tangentToWorldPacked[2].xyz;
    surfaceData.emission = 0;
    surfaceData.alpha = 1;
    return surfaceData;
}
#endif