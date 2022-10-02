#ifndef ZY_CUSTOM_LIGHTING
#define ZY_CUSTOM_LIGHTING

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "ZY_LightingCommon.hlsl"
#include "ZY_InitSurfaceData.hlsl"

//PBR Part
#ifndef FRAGMENT_PBR
#define FRAGMENT_PBR(input, surfaceData) ZYFragmentPBR(input, surfaceData)
    half3 ZYFragmentPBR(Varyings input , ZYSurfaceData surfaceData){
        half3 finnalcolor;

        // ----------------- init input data
        Light mainLight = GetMainLight(input.shadowCoord);
        DotVector dotvector = InitSafeDotVector(normalize(surfaceData.normalWS),input.viewDirWS,mainLight.direction);

        half3 tangent = SafeNormalize(input.tangentToWorldPacked[0].xyz);
            
        // ----------------- EnironmentTerm
        half3 sampleEnironmentSH = SampleSH(normalize(surfaceData.normalWS)); // environmentlight;
        half3 SHL = lerp(0, sampleEnironmentSH, surfaceData.occlusion);

        // ----------------- Distance
        half dist = saturate(distance(input.worldPos, _WorldSpaceCameraPos) / 5);

        half3 diffuseTerm = DiffuseTerm(mainLight,dotvector.nol);
        half3 specularTerm = SpecularTerm_BeckManned(dotvector,surfaceData.roughness,half3(1,1,1),mainLight);
        half3 rimLight = RimLight(dotvector.nov) * sampleEnironmentSH;
        
        //return specularTerm;
        finnalcolor =  surfaceData.albedo * diffuseTerm + surfaceData.albedo * SHL + specularTerm + surfaceData.emission;
        
        return finnalcolor;
    }
#endif

#endif