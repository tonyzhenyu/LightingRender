#ifndef ZY_CUSTOM_FORWARDPASS
#define ZY_CUSTOM_FORWARDPASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#define _ALPHATEST_ON

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _NoiseMap_ST;
float4 _BaseColor;
float4 _OcclusionColor;

float _Distance;
half __ForceScaleScale;
half _AOIntensity;
half _FurEdgeSoftness;
half _FurSoftness;

float3 _ForceDirection;

#ifdef _ALPHATEST_ON
    float _Cutoff;
#endif
CBUFFER_END

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);
TEXTURE2D(_FlowMap);   SAMPLER(sampler_FlowMap);

half FUR_LAYER_OFFSET;

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
// -----------------------------------------

#pragma exclude_renderers gles glcore
#pragma target 4.5

#pragma vertex vert
#pragma fragment frag


Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz );
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,input.tangent);

    output.vertex = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
    output.worldPos = vertexInput.positionWS.xyz;
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS.xyz);
    output.normalWS = normalInput.normalWS;

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 color;
    half2 uv = input.uv;

    Light mainLight = GetMainLight();
    
    half3 h = SafeNormalize(mainLight.direction + normalize(input.viewDirWS));
    half nov = dot(normalize(input.normalWS) , normalize(input.viewDirWS));
    half nol = dot(mainLight.direction,normalize(input.normalWS));
    half noh = dot(h , normalize(input.normalWS));

    // caculate fresnel
    float fresnel = (1 - nov);

    // temp caculate simplelight
    half3 sampleEnironmentSH = SampleSH(input.normalWS); // environmentlight;
    half3 lambertlight = LightingLambert(mainLight.color,mainLight.direction,input.normalWS);
    half specularTerm = pow(saturate(noh), 64) * mainLight.distanceAttenuation;
    // ---------------------------
    half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

    color.rgb = texColor.rgb * _BaseColor.rgb;
    color.rgb = MixFog(color, input.fogCoord);
    color.a = 1.0;

    return half4(color.xyz * lambertlight.xyz + color.xyz *  sampleEnironmentSH +  specularTerm,1);
    
}

#endif