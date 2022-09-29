#ifndef ZY_CUSTOM_FORWARDPASS
#define ZY_CUSTOM_FORWARDPASS

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ZY_Lighting.hlsl"

// vertex shader------------------------------

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,input.tangent);

    output.vertex = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
    
    output.worldPos = vertexInput.positionWS.xyz;
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS.xyz);

    #ifdef _NORMALMAP
        half sgn = input.tangent.w;
        float3x3 tangentToWorld = CreateTangentToWorld(normalInput.normalWS,normalInput.tangentWS,sgn);
        output.tangentToWorldPacked[0].xyz = tangentToWorld[0];
        output.tangentToWorldPacked[1].xyz = tangentToWorld[1];
        output.tangentToWorldPacked[2].xyz = tangentToWorld[2];
    #else
        output.tangentToWorldPacked[0].xyz = half3(0,0,0);
        output.tangentToWorldPacked[1].xyz = half3(0,0,0);
        output.tangentToWorldPacked[2].xyz = normalInput.normalWS;
    #endif

    return output;
}

// fragment shader -------------------------------

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    ZYSurfaceData surfaceData = INIT_ZY_SURFACEDATA(input);
    half3 pbrlitcolor = FRAGMENT_PBR(input,surfaceData);

    return half4(pbrlitcolor,1);
}

#endif