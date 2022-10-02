#ifndef ZY_FURSHELL_INPUT
#define ZY_FURSHELL_INPUT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "FurShellSurfaceData.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _NoiseMap_ST;
half4 _BaseColor;
half4 _OcclusionColor;
half _AOIntensity;
half _Roughness;
half4 _SpecularColor;
half _Cutoff;
half _Distance;
half _FurEdgeSoftness;
half _FurSoftness;
half _ForceScale;
half3 _ForceDirection;
CBUFFER_END

// ---------------------------------- SAMPLER
TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);

#if _FLOWMAP
    TEXTURE2D(_FlowMap);   SAMPLER(sampler_FlowMap);
#endif

#if _EMISSION
    half4 _EmissionColor;
    TEXTURE2D(_EmissiveMap);   SAMPLER(sampler_EmissiveMap);
#endif

#if _IDMASK
    TEXTURE2D(_MaskMap);   SAMPLER(sampler_MaskMap);
#endif

// ---------------------------------- GLOBAL VALUE

half FUR_LAYER_OFFSET;

// ----------------------------------

//Vert struct
struct Attributes
{
    float4 positionOS       : POSITION;
    float2 uv               : TEXCOORD0;
    float3 normal           : NORMAL;
    float4 tangent          : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

//Frag Struct
struct Varyings
{
    float4 vertex       : SV_POSITION;
    float2 uv           : TEXCOORD0;
    float3 worldPos     : TEXCOORD1;
    float3 viewDirWS    : TEXCOORD2;
    float3 normalWS     : TEXCOORD3;
    float4 shadowCoord  : TEXCOORD4;
    float3 tangentWS    : VAR_TANGENT;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

// ----------------------------------- Init SurfaceData
#define INIT_SURFACEDATA(uv) InitSurfaceData(uv)

FurShellSurfaceData InitSurfaceData(half2 uv){

    FurShellSurfaceData surfaceData = (FurShellSurfaceData)0;
    half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    
    surfaceData.albedo = texColor.rgb * _BaseColor.rgb;
    surfaceData.metallic = 0;
    surfaceData.roughness = _Roughness;
    surfaceData.specular = _SpecularColor;
    surfaceData.occlusion = half4(_OcclusionColor.xyz,_AOIntensity);
    surfaceData.alpha = texColor.a * _BaseColor.a;
    #if _EMISSION
        surfaceData.emissionColor = _EmissionColor * _EmissiveMap;
    #else
        surfaceData.emissionColor = half3(0,0,0);
    #endif
    return surfaceData;
}
// ----------------------------------- End

#ifndef INIT_SURFACEDATA 
#define INIT_SURFACEDATA(uv) InitSurfaceData(uv)

FurShellSurfaceData InitSurfaceData(float2 uv){

    FurShellSurfaceData surfaceData = (FurShellSurfaceData)0;
    surfaceData.albedo = (half3)0.75;
    surfaceData.metallic = 0;
    surfaceData.roughness = 1;
    surfaceData.occlusion = half4(0,0,0,0);
    surfaceData.emissionColor = half3(0,0,0);
    surfaceData.alpha = 1;
    return surfaceData;
}
#endif

#endif