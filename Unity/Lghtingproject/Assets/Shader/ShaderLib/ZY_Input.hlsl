#ifndef ZY_CUSTOM_INPUT
#define ZY_CUSTOM_INPUT

struct Attributes
{
    float4 positionOS       : POSITION;
    float2 uv               : TEXCOORD0;
    float3 normal           : NORMAL;
    float4 tangent          : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 vertex       : SV_POSITION;
    float2 uv           : TEXCOORD0;
    float fogCoord      : TEXCOORD1;
    
    float3 worldPos     : TEXCOORD2;
    float3 viewDirWS    : TEXCOORD3;
    float3 normalWS     : TEXCOORD4;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


#endif