#ifndef ZY_CUSTOM_LIGHTING_COMMON
#define ZY_CUSTOM_LIGHTING_COMMON

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
half3 DiffuseTerm(Light light, half ndotl){
    half3 diffuseTerm ;
    diffuseTerm = ndotl;
    diffuseTerm = max(0 , diffuseTerm);

    diffuseTerm *= light.color * light.distanceAttenuation * light.shadowAttenuation;
    return diffuseTerm;
    
}
//SpecularTerm -----------------------------------
half3 SpecularTerm_BeckManned(DotVector v,half roughness, half3 specularColor,Light light ){
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
// RimLight -----------------------------------
half RimLight(half ndotv){

    half fresnel = 1 - max(0,ndotv);

    half rimLight = fresnel;
    rimLight *= rimLight * 2;
    
    return rimLight;
}
//light
#endif