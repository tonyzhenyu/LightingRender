#ifndef FURSHELL_LIGHTING
#define FURSHELL_LIGHTING

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

inline half PI = 3.1415926;
inline half e = 2.71828;

//--- setup dot vector
struct DotVector{
    half nov;
    half nol;
    half noh;
    half loh;
    half3 halfvector;
};

DotVector InitDotVector(half3 normalWS,half3 viewDirWS,half3 lightDir){

    DotVector v = (DotVector)0;

    v.halfvector = SafeNormalize(lightDir + normalize(viewDirWS));
    v.nov = dot(normalWS , normalize(viewDirWS));
    v.nol = dot(lightDir,normalWS);
    v.noh = dot(v.halfvector,normalWS);
    v.loh = dot(v.halfvector,lightDir);

    return v;
}

DotVector InitSafeDotVector(half3 normalWS,half3 viewDirWS,half3 lightDir){
    DotVector v;
    v.halfvector = normalize(lightDir + normalize(viewDirWS));
    v.nov = max(dot(normalWS , normalize(viewDirWS)),0);
    v.nol = max(dot(lightDir,normalWS),0);
    v.noh = max(dot(v.halfvector,normalWS),0);
    v.loh = max(dot(v.halfvector,lightDir),0);
    return v;
}
//DiffuseTerm -----------------------------------
half3 DiffuseTerm(Light light, half ndotl,half offset , half loddist){
    half3 diffuseTerm ;
    diffuseTerm = (ndotl + offset + 0.5) / 4 -  pow(nov, 5) / PI ;
    diffuseTerm = max(0 , diffuseTerm)* (8 /PI);

    diffuseTerm = lerp(max(0,ndotl),diffuseTerm,loddist);
    diffuseTerm *= light.color * light.distanceAttenuation * light.shadowAttenuation;
    
    return diffuseTerm;
}
//SpecularTerm
half3 SpecularTerm(DotVector v,half roughness, half3 specularColor,Light light , half offset){
    //specularTerms
    nol = max(0,v.nol) ;
    loh = max(0,v.loh) ;

    half3 specularTerm;
    
    half smoothness = pow(roughness + 0.5 ,2);//input smoothness^2
    half3 F0 = specularColor;//half3(0.98,1,0.98);
    half3 F = F0 + (1-F0) * pow(1 - loh,5);

    half powerterm = (noh * noh - 1)/(smoothness * smoothness * v.noh * v.noh);
    half D_beckmann = pow( e ,powerterm ) / ( PI * smoothness * smoothness * pow(noh,4));
    
    half c = 0.797884560802865h; // c = sqrt( 2/ PI)
    half k = smoothness * c;

    half gl = nol * (1 - k) + k;
    half gv = nov * (1 - k) + k;

    half G_SmithBeckMannVisibilityTerm = (1.0 / (gl * gv + 1e-5f)) * 0.25;

    specularTerm = F * D_beckmann * G_SmithBeckMannVisibilityTerm * offset * offset / (v.nov * v.noh) ;
    specularTerm = saturate(specularTerm) * light.distanceAttenuation * light.color;
    specularTerm = lerp(specularTerm * F, specularTerm * light.color , offset * offset);

    return specularTerm;
}

half RimLight(half offset,half ndotv){
    // RimLight
    float selfocclusion = offset * offset;
    selfocclusion += 0.4;

    half fresnel = 1 - max(0,ndotv);

    half rimLight = fresnel * selfocclusion;
    rimLight *= rimLight;
    
    return rimLight;
}
//light
inline half3 Litted(Varyings input,FurShellSurfaceData surfaceData){
    // ----------------- init input data
    Light mainLight = GetMainLight(input.shadowCoord);

    DotVector dotvector = InitSafeDotVector(input.normalWS,input.viewDirWS,mainLight.direction);
    half3 tangent = SafeNormalize(input.tangentWS.xyz);
    half3 h = dotvector.halfvector;
    half nov = dotvector.nov;
    half nol = dotvector.nol;
    half noh = dotvector.noh;
    half loh = dotvector.loh;

    //EnironmentTerm
    half3 sampleEnironmentSH = SampleSH(input.normalWS); // environmentlight;
    half3 SHL = lerp(surfaceData.occlusion.xyz * sampleEnironmentSH, sampleEnironmentSH, 1 - surfaceData.occlusion.w);

    //------------Distance
    half dist = saturate(distance(input.worldPos, _WorldSpaceCameraPos) / 5);
    dist *= dist;
    dist = 1- dist; // lod 

    half3 diffuseTerm = DiffuseTerm(mainLight,dotvector.nol,FUR_LAYER_OFFSET,dist);
    half3 specularTerm = SpecularTerm(v,surfaceData.roughness,surfaceData.specular,mainLight, FUR_LAYER_OFFSET);
    half rimLight = RimLight(FUR_LAYER_OFFSET, v.nov);

    half3 lightCaculated = rimLight * sampleEnironmentSH + surfaceData.albedo * diffuseTerm + surfaceData.albedo * SHL + specularTerm;
    
    return lightCaculated;
    // --------------------------- Light ----------------------
}

#endif