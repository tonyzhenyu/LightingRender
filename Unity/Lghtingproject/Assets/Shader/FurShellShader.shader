Shader "Custom/Lit/FurShell"
{
    Properties
    {
        //mask map
        [ToggleOff(_IDMASK)] _IDMASK ("IDMASK?", Int) = 0
        _MaskMap("MaskMap", 2D) = "black" {}
        
        // flowmap
        [ToggleOff(_FLOWMAP)] _FLOWMAP ("FLOWMAP?", Int) = 0
        _FlowMap("FlowMap" ,2D) = "black" {}

        //NormalMap
        [ToggleOff(_NORMALMAP)] _NORMALMAP ("NORMALMAP?", Int) = 0
        [Normal]_NormalMap("NormalMap" , 2D) = "bump" {}

        //Emission
        [Toggle(_EMISSION)] _EMISSION ("EMISSION?", Int) = 0
        [HDR]_EmissionColor("* EmissionColor" ,color) = (0,0,0,1)
        _EmissionMap("EmissionMap" ,2D) = "black" {}

        //BaseColor
        _BaseColor("* Base Color", Color) = (1,1,1,1)
        [MainTexture]_BaseMap("Main Texture",2D) = "white" {}
        
        //surfacedata
        _SpecularColor("Specular Color" , color) = (1,1,1,1)
        _Metallic("Metallic",range(0,1)) = 0
        _Roughness("Roughness" , range(0,1)) = 0.5

        //occlusion
        _AOIntensity("* AO Intensity",range(0,1)) = 0
        _OcclusionColor("* Occlusion Color", Color) = (1,1,1,1)

        //Force And DISPLACEMENT
        [PowerSlider(0,0.01)]_Distance("Dis" , range(0,0.1)) = 0
        _ForceScale("* ForceScale", float) = 0
        _ForceDirection("ForceDirection" , vector) = (0,0,0,0)

        [Header(Fur)]
        _NoiseMap("* FurMap" ,2D) = "black" {}
        _Cutoff("* CutOff" , range(0,1)) = 0
        _FurEdgeSoftness("* FurEdgeSoftness" , range(0,1)) = 1
        _FurSoftness("* FurSoftness" , range(0.1,1)) = 1

        
    }
    SubShader
    {
		Tags {"Queue" = "Geometry" }
        
        Pass
        {
            Name "ForwardLit"
            
            Tags
            {
               "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "UniversalForward" 
            } 

			Cull back

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #define _ALPHATEST_ON
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _NoiseMap_ST;
            float4 _BaseColor;
            float4 _OcclusionColor;

            float _Distance;
            half __ForceScaleScale;
            half _AOIntensity;
            half _FurEdgeSoftness;
            half _FurSoftness;

            float3 _ForceDirection;

            #ifdef _ALPHATEST_ON
                float _Cutoff;
            #endif


            CBUFFER_END

            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);
            TEXTURE2D(_FlowMap);   SAMPLER(sampler_FlowMap);

            half FUR_LAYER_OFFSET;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                float3 normal           : NORMAL;
                float4 tangent          : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float fogCoord      : TEXCOORD1;
                
                float3 worldPos     : TEXCOORD2;
                float3 viewDirWS    : TEXCOORD3;
                float3 normalWS     : TEXCOORD4;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            // -----------------------------------------

			#pragma exclude_renderers gles glcore
			#pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag
            

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz );
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal,input.tangent);

                output.vertex = vertexInput.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

                output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
                output.worldPos = vertexInput.positionWS.xyz;
                output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS.xyz);
                output.normalWS = normalInput.normalWS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 color;
                half2 uv = input.uv;

                Light mainLight = GetMainLight();
                
                half3 h = SafeNormalize(mainLight.direction + normalize(input.viewDirWS));
                half nov = dot(input.normalWS , normalize(input.viewDirWS));
                half nol = dot(mainLight.direction,input.normalWS);
                half noh = dot(h , input.normalWS);
 
                // caculate fresnel
                float fresnel = (1 - nov);

                // temp caculate simplelight 
                
                half3 sampleEnironmentSH = SampleSH(input.normalWS); // environmentlight;
                half3 lambertlight = LightingLambert(mainLight.color,mainLight.direction,input.normalWS);
                half specularTerm = pow(saturate(noh), 64) * mainLight.distanceAttenuation;
                // ---------------------------
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

                color.rgb = texColor.rgb * _BaseColor.rgb;
                color.rgb = MixFog(color, input.fogCoord);
                color.a = 1.0;

                return half4(color.xyz * lambertlight.xyz + color.xyz *  sampleEnironmentSH +  specularTerm,1);
                
            }

            ENDHLSL

        }
        Pass
        {
            Name "FurShellPass"
            
            Tags
            {
               "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "FurShellPass" 
            } 

			Cull back
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma shader_feature_local _EMISSION
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _IDMASK

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _fragment _ _SHADOWS_SOFT

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _NoiseMap_ST;

            half4 _BaseColor;
            half4 _OcclusionColor;
            half _AOIntensity;
            half _Roughness;
            half4 _SpecularColor;
            
            half _Distance;
            half _FurEdgeSoftness;
            half _FurSoftness;

            half _ForceScaleScale;
            half3 _ForceDirection;
            CBUFFER_END

            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);

            #if _FLOWMAP
                TEXTURE2D(_FlowMap);   SAMPLER(sampler_FlowMap);
            #endif
            
            #if _EMISSION
                half4 _EmissionColor;
                TEXTURE2D(_EmissiveMap);   SAMPLER(sampler_EmissiveMap);
            #endif

            #if _IDMASK
                TEXTURE2D(_MaskMap);   SAMPLER(sampler_MaskMap);
            #endif

            half FUR_LAYER_OFFSET;

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                float3 normal           : NORMAL;
                float4 tangent          : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 vertex       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float fogCoord      : TEXCOORD1;
                float3 worldPos     : TEXCOORD2;
                float3 viewDirWS    : TEXCOORD3;
                float3 normalWS     : TEXCOORD4;
                float4 shadowCoord  : TEXCOORD5;
                float3 tangentWS    : VAR_TANGENT;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            
            // -----------------------------------------

			#pragma exclude_renderers gles glcore
			#pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag
            

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

                // ----------------- init input data
                Light mainLight = GetMainLight(input.shadowCoord);
                half3 tangent = SafeNormalize(input.tangentWS.xyz );

                half3 h = SafeNormalize(mainLight.direction + normalize(input.viewDirWS));
                half nov = dot(input.normalWS , normalize(input.viewDirWS));
                half nol = dot(mainLight.direction,input.normalWS);
                half noh = dot(h,input.normalWS);
                half loh = dot(h,mainLight.direction);
                // ---------------------------- SurfaceData
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half maskmap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv).r;

                color.rgb = texColor.rgb * _BaseColor.rgb;
                color.rgb = MixFog(color, input.fogCoord);
                color.a = 1.0;
                // ---------------------------

                // --------------------------- shape
                half2 flowmap = SAMPLE_TEXTURE2D(_FlowMap , sampler_FlowMap, uv ).rg;
                half noise = SAMPLE_TEXTURE2D(_NoiseMap , sampler_NoiseMap, uv * _NoiseMap_ST.xy + FUR_LAYER_OFFSET * flowmap + _NoiseMap_ST.zw).r;

                half softness = (1 - _FurSoftness + 0.1) * 10;
                half alpha = max(0,1 - (pow(FUR_LAYER_OFFSET, softness * 2 ) /softness));
                half edgeFade = max(dot(input.normalWS , normalize(-input.viewDirWS)) + _FurEdgeSoftness,0);
                half softfur = alpha - edgeFade;
                
                half idmask = (step(maskmap * 5,1));
                color.a = softfur * idmask;

                #ifdef _ALPHATEST_ON
                    
                    float clipValue = texColor.a * _BaseColor.a * noise * (1- FUR_LAYER_OFFSET) - _Cutoff;
                    clip((step(lerp(0 ,1,FUR_LAYER_OFFSET)  , noise + (1- _Cutoff ) )  - 1) * idmask);
                #endif
                // ---------------------------


                // --------------------------- Light ----------------------
                half pi = 3.1415926;
                half e = 2.71828;

                half3 sampleEnironmentSH = SampleSH(input.normalWS); // environmentlight;
                half3 SHL = lerp(_OcclusionColor * sampleEnironmentSH, sampleEnironmentSH, 1 - _AOIntensity);

                //diffuse

                half dist = saturate(distance(input.worldPos, _WorldSpaceCameraPos) / 5);
                dist *= dist;
                dist = 1- dist; // lod 

                half3 diffuseTerm = (nol + FUR_LAYER_OFFSET + 0.5) / 4 -  pow(nov, 5) / pi ;// - nov;//max(max(0,nol) ,  nol - FUR_LAYER_OFFSET - nov);
                diffuseTerm = max(0 , diffuseTerm)* (8 /pi);

                diffuseTerm = lerp(max(0,nol),diffuseTerm,dist);
                diffuseTerm *= mainLight.color * mainLight.distanceAttenuation * mainLight.shadowAttenuation ;
                
                //specular

                nol = max(0,nol);
                loh = max(0,loh);

                half smoothness = pow(_Roughness + 0.5 ,2);//input smoothness^2
                
                half3 specularTerm;
                half3 F0 = _SpecularColor;//half3(0.98,1,0.98);

                half3 F = F0 + (1-F0) * pow(1 - loh,5);

                half powerterm = (noh * noh - 1)/(smoothness * smoothness * noh * noh);
                half D_beckmann = pow( e ,powerterm ) / ( pi * smoothness * smoothness * pow(noh,4));
                
                //half D_Blinnphong = pow(noh,1 - smoothness)*((1 - smoothness+2.0) * (0.5/pi));

                half c = 0.797884560802865h; // c = sqrt( 2/ pi)
                half k = smoothness * c;

                half gl = nol * (1 - k) + k;
                half gv = nov * (1 - k) + k;

                half G_SmithBeckMannVisibilityTerm = (1.0 / (gl * gv + 1e-5f)) * 0.25;

                specularTerm = F * D_beckmann * G_SmithBeckMannVisibilityTerm * FUR_LAYER_OFFSET * FUR_LAYER_OFFSET / (nov * noh) ;
                specularTerm = saturate(specularTerm) * mainLight.distanceAttenuation * mainLight.color;
                specularTerm = lerp(specularTerm * F, specularTerm * mainLight.color , FUR_LAYER_OFFSET * FUR_LAYER_OFFSET);

                // RimLight
                float occlusion = FUR_LAYER_OFFSET * FUR_LAYER_OFFSET; //lerp(1,FUR_LAYER_OFFSET,_AOIntensity);
                occlusion += 0.4;
                half fresnel = 1 - max(0,nov);
                half rimLight = fresnel * occlusion;
                rimLight *= rimLight;

                half3 lightCaculated = rimLight * sampleEnironmentSH + color.rgb * diffuseTerm + color.rgb * SHL + specularTerm;

                // --------------------------- Light ----------------------

                //return half4(_AOIntensity,_AOIntensity,_AOIntensity,color.a);

                return half4(lightCaculated, color.a);
                
            }

            ENDHLSL

        }
    }

}
