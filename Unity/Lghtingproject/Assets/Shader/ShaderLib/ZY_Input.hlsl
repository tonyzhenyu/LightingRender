#ifndef ZY_CUSTOM_INPUT
#define ZY_CUSTOM_INPUT

#include "ZY_SurfaceData.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _BaseColor;

float _Roughness;
float _Metallic;
float _Occlusion;
float _Height;
float _BumpScale;

float4 _EmissionColor;

#ifdef _ALPHATEST_ON
    float _Cutoff;
#endif

CBUFFER_END

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);

#if _USEPBRMAP
    TEXTURE2D(_PBRMap);   SAMPLER(sampler_PBRMap);
#endif

#if _NORMALMAP
    TEXTURE2D(_BumpMap);   SAMPLER(sampler_BumpMap);
#endif

#if _EMISSION
    TEXTURE2D(_EmissionMap);   SAMPLER(sampler_EmissionMap);
#endif

struct Attributes
{
    float4 positionOS       : POSITION;
    float2 uv               : TEXCOORD0;
    float3 normal           : NORMAL;
    float4 tangent          : TANGENT;
    float4 color            : COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 vertex       : SV_POSITION;
    float2 uv           : TEXCOORD0;
    float fogCoord      : TEXCOORD1;
    float3 worldPos     : TEXCOORD2;
    float3 viewDirWS    : TEXCOORD3;
    float4 shadowCoord   : TEXCOORD4;
    float4 tangentToWorldPacked[3]:TEXCOORD5;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#define INIT_ZY_SURFACEDATA(input) InitSurfaceData(input)

ZYSurfaceData InitSurfaceData(Varyings input){
    ZYSurfaceData surfaceData = (ZYSurfaceData)1;

    half2 transformUV = input.uv.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
    
    half4 basemap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,transformUV.xy);


    #if _USEPBRMAP
        half4 pbrmap = SAMPLE_TEXTURE2D(_PBRMap,sampler_PBRMap,transformUV.xy);
        surfaceData.metallic = pbrmap.r;
        surfaceData.roughness = pbrmap.g;
        surfaceData.occlusion = pbrmap.b;
        surfaceData.height = pbrmap.a;
    #endif

    surfaceData.albedo = _BaseColor * basemap.rgb;
    surfaceData.specular = (half3)0;

    surfaceData.roughness *= _Roughness;
    surfaceData.metallic *= _Metallic;
    surfaceData.occlusion *= 1 - _Occlusion;
    surfaceData.height *= _Height;

    #if _NORMALMAP
        half3 tangent = input.tangentToWorldPacked[0];
        half3 binormal = input.tangentToWorldPacked[1];
        half3 normal = input.tangentToWorldPacked[2];

        half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, transformUV.xy), _BumpScale);
        surfaceData.normalWS = half3(
            normalTS.x * tangent +
            normalTS.y * binormal +
            normalTS.z * normal
        );
    #else
        surfaceData.normalWS = input.tangentToWorldPacked[2].xyz;
    #endif

    #if _EMISSION
        half4 emitTex = SAMPLE_TEXTURE2D(_EmissionMap,sampler_EmissionMap,transformUV.xy);
        surfaceData.emission = _EmissionColor * emitTex;
    #else
        surfaceData.emission = 0;
    #endif

    surfaceData.alpha = basemap.a * _BaseColor.a;

    return surfaceData;
}
#endif