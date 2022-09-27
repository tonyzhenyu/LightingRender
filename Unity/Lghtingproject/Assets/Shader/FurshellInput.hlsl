#ifndef FURSHELL_INPUT
#define FURSHELL_INPUT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"



CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _NoiseMap_ST;
half4 _BaseColor;
half4 _OcclusionColor;
half _AOIntensity;
half _Roughness;
half4 _SpecularColor;

half _Distance;
half _FurEdgeSoftness;
half _FurSoftness;
half _ForceScaleScale;
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

// ----------------------------------

//GLOBAL VALUE
half FUR_LAYER_OFFSET;

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
    float fogCoord      : TEXCOORD1;
    float3 worldPos     : TEXCOORD2;
    float3 viewDirWS    : TEXCOORD3;
    float3 normalWS     : TEXCOORD4;
    float4 shadowCoord  : TEXCOORD5;
    float3 tangentWS    : VAR_TANGENT;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

#endif