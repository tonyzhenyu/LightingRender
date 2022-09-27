#ifndef FURSHELL_PASS
#define FURSHELL_PASS

#include "FurShellLighting.hlsl"
#include "FurShellSurfaceData.hlsl"

#ifndef INIT_SURFACEDATA 
#define INIT_SURFACEDATA InitSurfaceData()

FurShellSurfaceData InitSurfaceData(){

    FurShellSurfaceData surfaceData = (FurShellSurfaceData)0;
    surfaceData.albedo = (half3)0.75;
    surfaceData.metallic = 0;
    surfaceData.roughness = 1;
    surfaceData.occlusion = half4(0,0,0,0);
    surfaceData.emissionColor = half3(0,0,0);

    return surfaceData;
}
#endif


Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //force direction.
    float3 direction = lerp(input.normal.xyz , _ForceDirection * __ForceScaleScale  + input.normal * __ForceScaleScale,FUR_LAYER_OFFSET);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz + FUR_LAYER_OFFSET * direction * _Distance );
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,input.tangent);

    output.vertex = vertexInput.positionCS ;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
    output.worldPos = vertexInput.positionWS.xyz;
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS.xyz);
    output.normalWS = normalInput.normalWS;
    output.shadowCoord = GetShadowCoord(vertexInput);
    output.shadowCoord = TransformWorldToShadowCoord(vertexInput.positionWS);
    output.tangentWS = float4(TransformObjectToWorldDir(input.tangent.xyz), input.tangent.w);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    half4 color;
    half2 uv = input.uv;

    // ---------------------------- SurfaceData
    half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    
    color.rgb = texColor.rgb * _BaseColor.rgb;
    color.rgb = MixFog(color, input.fogCoord);
    color.a = 1.0;
    // ---------------------------

    // --------------------------- FurShell Alpha shape
    #if _FLOWMAP
        half2 flowmap = SAMPLE_TEXTURE2D(_FlowMap , sampler_FlowMap, uv ).rg;
        half noise = SAMPLE_TEXTURE2D(_NoiseMap , sampler_NoiseMap, uv * _NoiseMap_ST.xy + FUR_LAYER_OFFSET * flowmap + _NoiseMap_ST.zw).r;
    #else
        half noise = SAMPLE_TEXTURE2D(_NoiseMap , sampler_NoiseMap, uv * _NoiseMap_ST.xy + _NoiseMap_ST.zw).r;
    #endif

    half softness = (1 - _FurSoftness + 0.1) * 10;
    half alpha = max(0,1 - (pow(FUR_LAYER_OFFSET, softness * 2 ) /softness));

    half edgeFade = max(dot(input.normalWS , normalize(-input.viewDirWS)) + _FurEdgeSoftness,0);

    half softfur = alpha - edgeFade;
    
    #if _IDMASK
        half3 maskmap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv).rgb;
        maskmap = (maskmap.r+maskmap.g+maskmap.b)/3;
        half idmask = maskmap.r;
        color.a = softfur * idmask;
    #else
        color.a = softfur;
    #endif

    float clipValue = texColor.a * _BaseColor.a * noise * (1- FUR_LAYER_OFFSET) - _Cutoff;
    clip((step(lerp(0 ,1,FUR_LAYER_OFFSET)  , noise + (1- _Cutoff ) )  - 1) * idmask);
    // --------------------------- shaoe end

    FurShellSurfaceData surfaceData = INIT_SURFACEDATA;
    half3 lightCaculated = Litted(input, surfaceData);

    return half4(lightCaculated, color.a);
    
}

#endif
