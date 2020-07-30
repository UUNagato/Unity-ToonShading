Shader "ToonShading/ToonSkin"
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

        _NormalTex ("Normal Map", 2D) = "bump" {}

        [Header(IndirectLighting)]
        [HDR]_IndirectLightingColor("Indirect Light Constant", Color) = (1, 0, 0, 1)
        _IndirectLightingStrength("Indirect Strength", Range(0, 10)) = 0.5
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
            #pragma shader_feature _NORMALMAP

            #include "ToonShadingCommon.hlsl"

            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            BasePassFragmentInput BasePassVertex(BasePassVertexInput input)
            {
                BasePassFragmentInput output;
                VertexPositionInputs vertexPosition = GetVertexPositionInputs(input.positionOS);
                VertexNormalInputs vertexNormal = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                float fogFactor = ComputeFogFactor(vertexPosition.positionCS.z);

                output.positionCS = vertexPosition.positionCS;
                output.positionWSAndFogFactor = float4(vertexPosition.positionWS, fogFactor);

                output.normalWS = vertexNormal.normalWS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            half4 BasePassFragment(BasePassFragmentInput input) : SV_Target
            {
                return shadeFinalColor(input);
            }

            ENDHLSL
        }
    }
}
