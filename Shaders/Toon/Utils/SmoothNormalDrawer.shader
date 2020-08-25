Shader "ToonShading/Utils/SmoothNormalDrawer"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalRenderPipeline"}
        LOD 100

        Pass
        {
            Tags { "LightMode"="UniversalForward"}
            ZTest Always
            Blend SrcAlpha DstAlpha, One One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normalOS : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float2 clipedUV = float2(v.uv.x, 1.0 - v.uv.y);
                clipedUV = clipedUV * 2.0 - 1.0;
                o.vertex = float4(clipedUV, 1.0, 1.0);
                o.normalOS = v.normalOS;
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float3 transformedNormal = saturate((i.normalOS * 0.5) + 0.5);
                half4 col = half4(transformedNormal, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
