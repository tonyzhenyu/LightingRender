Shader "ZY/Standard Lit"
{
    Properties
    {
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma shader_feature_local _EMISSION
            #pragma shader_feature_local _NORMALMAP

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _fragment _ _SHADOWS_SOFT
            
			#pragma exclude_renderers gles glcore
			#pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag
            
            #include "ShaderLib/ZY_Input.hlsl"
            #include "ShaderLib/ZY_ForwardPass.hlsl"
        
            ENDHLSL

        }
        
    }

}
