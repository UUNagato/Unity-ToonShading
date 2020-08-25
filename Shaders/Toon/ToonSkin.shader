Shader "ToonShading/ToonSkin"
{
    Properties
    {
        [Header(Diffuse Color)]
        [Space]
        [HDR]_MainColor ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Base Texture", 2D) = "white" {}
        [HDR]_DiffuseColorLow("Low Color", Color) = (1, 1, 1, 1)
        [HDR]_DiffuseColorMed("Med Color", Color) = (1, 1, 1, 1)
        [HDR]_DiffuseColorHigh("High Color", Color) = (1, 1, 1, 1)
        _LMOffset("Low Med Point", Range(-1, 1)) = -0.3
        _MHOffset("Med High Point", Range(-1, 1)) = 0.7
        _DiffuseSoftness("Softness", Range(0, 0.5)) = 0.05
        _DirectLightMultiplier("Direct Light Multiplier", Range(0, 2)) = 1.0

        [Header(Specular Color)]
        [Space]
        _SpecularTex ("Specular Texture", 2D) = "white" {}
        [HDR]_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularPower ("Specular Power", Range(0, 200)) = 10
        _SpecularMultiplier("Specular Light Multiplier", Range(0, 2)) = 1.0

        [Header(Normal Map)][Space]
        [Toggle(_NORMALMAP)]_UseNormalMap("Use Normal Map", Int) = 0
        _NormalTex ("Normal Map", 2D) = "bump" {}

        [Header(Subsurface Scattering)]
        [Space]
        [Toggle(_PREINTEGRATED_SUBSURFACE_SCATTERING)]_SSSEnabled("Use Subsurface Scattering", Int) = 0
        _SSSLUTTex("Look Up Texture", 2D) = "white" {}
        [HDR]_SSSColor("SSS Color", Color) = (1, 1, 1, 1)
        _SSSMultiplier("SSS Strength", Range(0, 1)) = 0

        [Header(IndirectLighting)]
        [Space]
        [HDR]_IndirectLightingColor("Indirect Light Constant", Color) = (1, 0, 0, 1)
        _IndirectLightingStrength("Indirect Strength", Range(0, 10)) = 0.5

        [Header(Shadow)]
        [Space]
        _ShadowMultiplier("Shadow Received Amount", Range(0, 1)) = 0.5

        [Header(Outliner)]
        [Space]
        _OutlineWidth("Outline Width", Range(0,1)) = 0.05
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)

        [Header(Override)]
        [Space]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("CullMode", float) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 300

        Pass
        {
            Name "BasePass"
            Tags {
                "LightMode"="UniversalForward"
            }

            Cull [_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _PREINTEGRATED_SUBSURFACE_SCATTERING

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE


            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment
            
            #include "ToonShadingBaseInput.hlsl"
            #include "ToonShadingCommon.hlsl"
            half4 BasePassFragment(BasePassFragmentInput input) : SV_Target
            {
                return shadeFinalColor(input);
            }

            ENDHLSL
        }

        Pass
        {
            Name "Outliner"
            Tags {
                //"LightMode"="UniversalForward"
            }

            Cull Front

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex OutlineVertex
            #pragma fragment OutlineFragment

            #include "ToonOutlineInput.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            ZWrite On
            ZTest LEqual
            Cull [_Cull]

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma shader_feature _ALPHATEST_ON
            #pragma vertex ShadowVertex
            #pragma fragment ShadowFragment

            #include "ToonShadowInput.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags {
                "LightMode"="DepthOnly"
            }
            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment ShadowFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            //#pragma multi_compile_instancing
            #include "ToonShadowInput.hlsl"
            ENDHLSL
        }
    }
}
