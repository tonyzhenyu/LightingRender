#ifndef ZY_CUSTOM_LIGHTING
#define ZY_CUSTOM_LIGHTING

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


//------------------------- setup dot vector
struct DotVector{
    half nov;
    half nol;
    half noh;
    half loh;
    half3 halfvector;
};

inline DotVector InitDotVector(half3 normalWS,half3 viewDirWS,half3 lightDir){
    DotVector v = (DotVector)0;

    v.halfvector = SafeNormalize(lightDir + normalize(viewDirWS));
    v.nov = dot(normalWS , normalize(viewDirWS));
    v.nol = dot(lightDir,normalWS);
    v.noh = dot(v.halfvector,normalWS);
    v.loh = dot(v.halfvector,lightDir);

    return v;
}

inline DotVector InitSafeDotVector(half3 normalWS,half3 viewDirWS,half3 lightDir){
    DotVector v = (DotVector)0;

    v.halfvector = normalize(lightDir + normalize(viewDirWS));
    v.nov = max(dot(normalWS , normalize(viewDirWS)),0);
    v.nol = max(dot(lightDir,normalWS),0);
    v.noh = max(dot(v.halfvector,normalWS),0);
    v.loh = max(dot(v.halfvector,lightDir),0);
    return v;
}
// End SetupVectors -----------------------------

//DiffuseTerm -----------------------------------
half3 DiffuseTerm(Light light,half nov, half ndotl,half offset , half loddist){
    half3 diffuseTerm ;

    diffuseTerm = (ndotl  + offset + 0.5) / 4  - (pow(nov-0.25, 5) / PI) ;
    diffuseTerm = max(0 , diffuseTerm) *(6/PI);

    //diffuseTerm = lerp(max(0,ndotl),diffuseTerm,loddist);
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
half RimLight(half offset,half ndotv){
    
    float selfocclusion = offset * offset;
    selfocclusion += 0.4;

    half fresnel = 1 - max(0,ndotv);

    half rimLight = fresnel * selfocclusion;
    rimLight *= rimLight * 2;
    
    return rimLight;
}
//light

//PBR Part
#ifndef FRAGMENT_PBR
#define FRAGMENT_PBR(input, surfaceData) ZYFragmentPBR(input, surfaceData)
    inline half3 ZYFragmentPBR(Varyings input , ZYSurfaceData surfaceData){
        half3 finnalcolor;

        // ----------------- init input data
        Light mainLight = GetMainLight(input.shadowCoord);
        DotVector dotvector = InitSafeDotVector(input.normalWS,input.viewDirWS,mainLight.direction);

        half3 tangent = SafeNormalize(input.tangentWS.xyz);
            
        //EnironmentTerm
        half3 sampleEnironmentSH = SampleSH(input.normalWS); // environmentlight;
        half3 SHL = lerp(surfaceData.occlusion.xyz * sampleEnironmentSH, sampleEnironmentSH, 1 - surfaceData.occlusion.w);

        //------------Distance
        half dist = saturate(distance(input.worldPos, _WorldSpaceCameraPos) / 5);

        half3 diffuseTerm = DiffuseTerm(mainLight,dotvector.nov,dotvector.nol,FUR_LAYER_OFFSET,dist);
        half3 specularTerm = SpecularTerm(dotvector,surfaceData.roughness,surfaceData.specular,mainLight, FUR_LAYER_OFFSET);
        half rimLight = RimLight(FUR_LAYER_OFFSET, dotvector.nov) * sampleEnironmentSH;
        
        //return specularTerm;
        finnalcolor = surfaceData.albedo * diffuseTerm + surfaceData.albedo * SHL + specularTerm;
        
        return finnalcolor;
    }
#endif

#endif