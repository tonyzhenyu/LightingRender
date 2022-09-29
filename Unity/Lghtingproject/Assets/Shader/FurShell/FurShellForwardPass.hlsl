#ifndef ZY_FURSHELL_PASS
#define ZY_FURSHELL_PASS

#include "FurShellLighting.hlsl"

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //force direction.
    float3 direction = lerp(input.normal.xyz , _ForceDirection * _ForceScale  + input.normal * _ForceScale,FUR_LAYER_OFFSET);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz + FUR_LAYER_OFFSET * direction * _Distance );
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,input.tangent);

    output.vertex = vertexInput.positionCS ;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.worldPos = vertexInput.positionWS.xyz;
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS.xyz);
    output.normalWS = normalInput.normalWS;
    output.shadowCoord = GetShadowCoord(vertexInput);
    output.shadowCoord = TransformWorldToShadowCoord(vertexInput.positionWS);
    output.tangentWS = float4(TransformObjectToWorldDir(input.tangent.xyz), input.tangent.w).xyz;

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    half4 color;
    half2 uv = input.uv;

    // ---------------------------- Init SurfaceData
    FurShellSurfaceData surfaceData = INIT_SURFACEDATA(uv.xy);

    color.rgb = surfaceData.albedo;
    color.a = 1.0;
    // ---------------------------

    // --------------------------- FurShell Alpha shape
    #ifdef FUR_ALPHA_SHAPE
        #if _FLOWMAP
            half2 flowmap = SAMPLE_TEXTURE2D(_FlowMap , sampler_FlowMap, uv ).rg;
            half noise = SAMPLE_TEXTURE2D(_NoiseMap , sampler_NoiseMap, uv * _NoiseMap_ST.xy + FUR_LAYER_OFFSET * flowmap + _NoiseMap_ST.zw).r;
        #else
            half noise = SAMPLE_TEXTURE2D(_NoiseMap , sampler_NoiseMap, uv * _NoiseMap_ST.xy + _NoiseMap_ST.zw).r;
        #endif

        half softness = (1 - _FurSoftness + 0.1) * 10;
        half alpha = max(0,1 - (pow(FUR_LAYER_OFFSET, softness * 2 ) / softness));
        half edgeFade = max(dot(input.normalWS , normalize(-input.viewDirWS)) + _FurEdgeSoftness,0);
        half softfur = alpha - edgeFade;
        
        #if _IDMASK
            half3 maskmap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv).rgb;
            maskmap = (maskmap.r + maskmap.g + maskmap.b)/3;
            half idmask = maskmap.r;
            color.a = softfur * idmask;
        #else
            color.a = max(0,softfur) ;
        #endif

        #if _IDMASK
            float clipValue = surfaceData.alpha * noise * (1- FUR_LAYER_OFFSET) - _Cutoff;
            clip((step(lerp(0 ,1,FUR_LAYER_OFFSET)  , noise + (1 - _Cutoff ) )  - 1) * idmask);
        #else
            float clipValue = surfaceData.alpha * noise * (1 - FUR_LAYER_OFFSET) - _Cutoff;
            clip((step(lerp(0 ,1,FUR_LAYER_OFFSET)  , noise + (1 - _Cutoff ) )  - 1));
        #endif
    #endif
    // --------------------------- shape end

    half3 finnalcolor = FurshellFragmentPRB(input, surfaceData);

    return half4(finnalcolor, color.a);
    
}

#endif
