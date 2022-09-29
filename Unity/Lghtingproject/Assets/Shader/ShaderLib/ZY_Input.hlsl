#ifndef ZY_CUSTOM_INPUT
#define ZY_CUSTOM_INPUT

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _BaseColor;
float _Roughness;
float _Metallic;
float _Occlusion;
float _Height;
float _BumpScale;
float _Emission;
float _Alpha;

#ifdef _ALPHATEST_ON
    float _Cutoff;
#endif

CBUFFER_END

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);

#if _NORMALMAP
    TEXTURE2D(_BumpMap);   SAMPLER(sampler_BumpMap);
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

#include "ZY_SurfaceData.hlsl"

#endif