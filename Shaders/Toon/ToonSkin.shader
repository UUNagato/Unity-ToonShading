Shader "ToonShading/ToonSkin"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                output.uv = input.uv;
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
