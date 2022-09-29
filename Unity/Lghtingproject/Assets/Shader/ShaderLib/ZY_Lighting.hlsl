#ifndef ZY_CUSTOM_LIGHTING
#define ZY_CUSTOM_LIGHTING

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "ZY_LightingCommon.hlsl"

//DiffuseTerm -----------------------------------
half3 DiffuseTerm(Light light,half nov, half ndotl){
    half3 diffuseTerm ;
    diffuseTerm = ndotl;
    diffuseTerm = max(0 , diffuseTerm);

    diffuseTerm *= light.color * light.distanceAttenuation * light.shadowAttenuation;
    return diffuseTerm;
    
}
//SpecularTerm
half3 SpecularTerm(DotVector v,half roughness, half3 specularColor,Light light ){
    //specularTerms
    half nol = max(0,v.nol) ;
    half loh = max(0,v.loh) ;
    half e = 2.71828;
    half3 specularTerm;
    
    half smoothness = pow(roughness + 0.5 ,2);//input smoothness^2
    half3 F0 = specularColor;//half3(0.98,1,0.98);
    half3 F = F0 + (1-F0) * pow(1 - loh,5);

    half powerterm = (v.noh * v.noh - 1)/(smoothness * smoothness * v.noh * v.noh);
    half D_beckmann = pow( e ,powerterm ) / ( PI * smoothness * smoothness * pow(v.noh,4));
    
    half c = 0.797884560802865h; // c = sqrt( 2/ PI)
    half k = smoothness * c;

    half gl = nol * (1 - k) + k;
    half gv = v.nov * (1 - k) + k;

    half G_SmithBeckMannVisibilityTerm = (1.0 / (gl * gv + 1e-5f)) * 0.25;

    specularTerm = F * D_beckmann * G_SmithBeckMannVisibilityTerm / (v.nov * v.noh) ;
    specularTerm = saturate(specularTerm) * light.distanceAttenuation * light.color;
    specularTerm *= light.color.rgb;

    return specularTerm;

}
// RimLight
half RimLight(half ndotv){

    half fresnel = 1 - max(0,ndotv);

    half rimLight = fresnel;
    rimLight *= rimLight * 2;
    
    return rimLight;
}
//light

//PBR Part
#ifndef FRAGMENT_PBR
#define FRAGMENT_PBR(input, surfaceData) ZYFragmentPBR(input, surfaceData)
    half3 ZYFragmentPBR(Varyings input , ZYSurfaceData surfaceData){
        half3 finnalcolor;

        // ----------------- init input data
        Light mainLight = GetMainLight(input.shadowCoord);
        DotVector dotvector = InitSafeDotVector(surfaceData.normalTS,input.viewDirWS,mainLight.direction);

        half3 tangent = SafeNormalize(input.tangentToWorldPacked[0].xyz);
            
        //EnironmentTerm
        half3 sampleEnironmentSH = SampleSH(surfaceData.normalTS); // environmentlight;
        half3 SHL = lerp(0, sampleEnironmentSH, surfaceData.occlusion);

        //------------Distance
        half dist = saturate(distance(input.worldPos, _WorldSpaceCameraPos) / 5);

        half3 diffuseTerm = DiffuseTerm(mainLight,dotvector.nov,dotvector.nol);
        half3 specularTerm = SpecularTerm(dotvector,surfaceData.roughness,surfaceData.specular,mainLight);
        half rimLight = RimLight(dotvector.nov) * sampleEnironmentSH;
        
        //return specularTerm;
        finnalcolor =  surfaceData.albedo * diffuseTerm + surfaceData.albedo * SHL + specularTerm;
        
        return finnalcolor;
    }
#endif

#endif