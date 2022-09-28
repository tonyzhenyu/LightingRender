#ifndef ZY_CUSTOM_FORWARDPASS
#define ZY_CUSTOM_FORWARDPASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _NoiseMap_ST;
float4 _BaseColor;
float4 _OcclusionColor;
half _AOIntensity;
#ifdef _ALPHATEST_ON
    float _Cutoff;
#endif
CBUFFER_END

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);

// -----------------------------------------

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
    ZYSurfaceData surfaceData = INIT_ZY_SURFACEDATA(input.uv);
    // caculate fresnel
    float fresnel = (1 - nov);

    // temp caculate simple light
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