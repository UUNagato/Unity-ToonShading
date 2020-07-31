Shader "ToonShading/ToonSkin"
{
    Properties
    {
        [Header(Diffuse Color)]
        [Space]
        _MainTex ("Base Texture", 2D) = "white" {}
        [HDR]_DiffuseColorLow("Low Color", Color) = (1, 1, 1, 1)
        [HDR]_DiffuseColorMed("Med Color", Color) = (1, 1, 1, 1)
        [HDR]_DiffuseColorHigh("High Color", Color) = (1, 1, 1, 1)
        _LMOffset("Low Med Point", Range(-1, 1)) = -0.3
        _MHOffset("Med High Point", Range(-1, 1)) = 0.7
        _DiffuseSoftness("Softness", Range(0, 0.5)) = 0.05
        _DirectLightMultiplier("Direct Light Multiplier", Range(0, 2)) = 1.0

        [Toggle(_NORMALMAP)]_UseNormalMap("Use Normal Map", Int) = 0
        _NormalTex ("Normal Map", 2D) = "bump" {}

        [Header(IndirectLighting)]
        [Space]
        [HDR]_IndirectLightingColor("Indirect Light Constant", Color) = (1, 0, 0, 1)
        _IndirectLightingStrength("Indirect Strength", Range(0, 10)) = 0.5

        [Header(Outliner)]
        [Space]
        _OutlineWidth("Outline Width", Range(0,1)) = 0.05
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
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

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature _NORMALMAP

            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

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
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex ShadowVertex
            #pragma fragment ShadowFragment

            #include "ToonShadowInput.hlsl"

            ENDHLSL
        }
    }
}
