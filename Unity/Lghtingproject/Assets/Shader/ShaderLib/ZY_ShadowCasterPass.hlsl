#ifndef ZY_CUSTOM_SHADOWCASTERPASS
#define ZY_CUSTOM_SHADOWCASTERPASS


Varyings vert(Attributes input){
    Varyings output = (Varyings)0;
    
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,input.tangent);

    output.vertex = vertexInput.positionCS;
    return output;
    
}

half4 frag(Varyings input):SV_Target{

    ZYSurfaceData surfaceData = INIT_ZY_SURFACEDATA(input);

    #if _ALPHATEST_ON
        clip((surfaceData.alpha - _Cutoff));
    #endif

    return 0;
}

#endif