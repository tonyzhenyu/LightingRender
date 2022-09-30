Shader "ZY/Standard Lit"
{
    Properties
    {

        //NormalMap
        [Toggle(_NORMALMAP)] _NORMALMAP ("NORMALMAP?", Int) = 0
        [Normal]_BumpMap("NormalMap" , 2D) = "bump" {}

        //Emission
        [Toggle(_EMISSION)] _EMISSION ("EMISSION?", Int) = 0
        [HDR]_EmissionColor("* EmissionColor" ,color) = (0,0,0,1)
        _EmissionMap("EmissionMap" ,2D) = "white" {}

        //PBR
        [Toggle(_USEPBRMAP)] _USEPBRMAP ("USEPBRMAP?", Int) = 0
        _PBRMap("PBR Map" ,2D) = "white" {}

        //BaseColor
        _BaseColor("* Base Color", Color) = (1,1,1,1)
        _BaseMap("Main Texture",2D) = "white" {}
        
        _BumpScale("BumpScale",float) = 1
        //surfacedata
        _Metallic("Metallic",range(0,1)) = 0
        _Roughness("Roughness" , range(0,1)) = 0.5
        _Occlusion("AO Intensity",range(0,1)) = 0
        _Height("Height",range(0,1)) = 0

        [Header(Fur)]
        _Cutoff("* CutOff" , range(0,1)) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 10
		[Toggle]_ZWrite("__zw", Float) = 1.0
        [Toggle(_ALPHATEST_ON)]_ALPHATEST_ON("_ALPHATEST_ON",Float) = 1
        
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

            Blend[_SrcBlend][_DstBlend]
			ZWrite[_ZWrite]
			Cull back

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #pragma shader_feature_local _EMISSION
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _USEPBRMAP

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            
			#pragma exclude_renderers gles glcore
			#pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            #include "ShaderLib/ZY_Input.hlsl"
            #include "ShaderLib/ZY_ForwardPass.hlsl"
        
            ENDHLSL

        }
        Pass
        {
            Name "ShadowCaster"

            Tags{
                "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "ShadowCaster" 
            }

            HLSLPROGRAM
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            ENDHLSL
        }
    }

}
