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


#endif