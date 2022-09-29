Shader "ZY/FurShell Lit"
{
    Properties
    {
        //mask map
        [Toggle(_IDMASK)] _IDMASK ("IDMASK?", Int) = 0
        _MaskMap("MaskMap", 2D) = "black" {}
        
        // flowmap
        [Toggle(_FLOWMAP)] _FLOWMAP ("FLOWMAP?", Int) = 0
        _FlowMap("FlowMap" ,2D) = "black" {}

        //NormalMap
        [Toggle(_NORMALMAP)] _NORMALMAP ("NORMALMAP?", Int) = 0
        [Normal]_NormalMap("NormalMap" , 2D) = "bump" {}

        //Emission
        [Toggle(_EMISSION)] _EMISSION ("EMISSION?", Int) = 0
        [HDR]_EmissionColor("* EmissionColor" ,color) = (0,0,0,1)
        _EmissionMap("EmissionMap" ,2D) = "black" {}

        //BaseColor
        _BaseColor("* Base Color", Color) = (1,1,1,1)
        _BaseMap("Main Texture",2D) = "white" {}
        
        //surfacedata
        _SpecularColor("Specular Color" , color) = (1,1,1,1)
        _Metallic("Metallic",range(0,1)) = 0
        _Roughness("Roughness" , range(0,1)) = 0.5

        //occlusion
        _AOIntensity("* AO Intensity",range(0,1)) = 0
        _OcclusionColor("* Occlusion Color", Color) = (0,0,0,0)

        //Force And displacement
        _Distance("Dis" , range(0,0.1)) = 0
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
        
        // Pass
        // {
        //     Name "ForwardLit"
            
        //     Tags
        //     {
        //        "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "UniversalForward" 
        //     } 

		// 	Cull back

        //     HLSLPROGRAM

        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        //     #pragma shader_feature_local _EMISSION
        //     #pragma shader_feature_local _NORMALMAP

        //     #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //     #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //     #pragma multi_compile _fragment _ _SHADOWS_SOFT
            
		// 	#pragma exclude_renderers gles glcore
		// 	#pragma target 4.5

        //     #pragma vertex vert
        //     #pragma fragment frag
            
        //     #include "FurShellInput.hlsl"
        //     #include "FurShellForwardPass.hlsl"
        
        //     ENDHLSL

        // }
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
            
            #define FUR_ALPHA_SHAPE
            
            #pragma shader_feature_local _EMISSION
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _IDMASK

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _fragment _ _SHADOWS_SOFT

			#pragma exclude_renderers gles glcore
			#pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            #include "FurShell/FurShellInput.hlsl"
            #include "FurShell/FurShellForwardPass.hlsl"
            
            ENDHLSL

        }
    }

}
