Shader "ToonShading/Hair"
{
    Properties
    {
        [Header(Diffuse Color)]
        _MainTex ("Base Texture", 2D) = "white" {}
        [HDR]_DiffuseColorLow("Low Color", Color) = (1, 1, 1, 1)
        [HDR]_DiffuseColorMed("Med Color", Color) = (1, 1, 1, 1)
        [HDR]_DiffuseColorHigh("High Color", Color) = (1, 1, 1, 1)
        _LMOffset("Low Med Point", Range(-1, 1)) = -0.3
        _MHOffset("Med High Point", Range(-1, 1)) = 0.7
        _DiffuseSoftness("Softness", Range(0, 0.5)) = 0.05

        [Header(IndirectLighting)]
        [HDR]_IndirectLightingColor("Indirect Light Constant", Color) = (1, 0, 0, 1)
        _IndirectLightingStrength("Indirect Strength", Range(0, 10)) = 0.5

        [Header(Hair)]
        _ShiftTex ("Hair ShiftMap", 2D) = "black" {}
        [HDR]_SpecularColorLow("Specular Color Low", Color) = (0.7, 0.7, 0.7, 0.7)
        [HDR]_SpecularColorHigh("Specular Color High", Color) = (1, 1, 1, 1)
        _ShiftOffset("Specular Offset", Range(-1, 1)) = 0
        _SpecularLowShiftExp("Low Specular Exponent", Range(1, 500)) = 20
        _SpecularHighShiftExp("High Specular Exponent", Range(1, 500)) = 50
        _SpecularPower("Highlight Power", Range(0, 3)) = 0.8
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }

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
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #define _HAIRSHADING
            #include "ToonHairInput.hlsl"

            half4 BasePassFragment(BasePassFragmentInput input) : SV_Target
            {
                return shadeFinalColor(input);
            }

            ENDHLSL
        }
    }
}
