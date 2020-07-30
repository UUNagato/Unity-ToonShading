Shader "PreintegratedSkin/PreintegrateSSS"
{
    Properties
    {
        _Samples("Samples", Int) = 256
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            int _Samples;

            const float PI = 3.1415926536;

            float gaussian(float v, float r)
            {
                return 1.0 / (2.0 * PI * v) * exp(-r * r / (2.0 * v));
            }

            float3 R(float r)
            {
                return gaussian(.0064, r) * float3(0.233, 0.455, 0.649)
                        + gaussian(.0484, r) * float3(0.1, 0.336, 0.344)
                        + gaussian(.187, r) * float3(0.118, 0.198, 0)
                        + gaussian(.567, r) * float3(0.113, .007, .007)
                        + gaussian(1.99, r) * float3(.358, .004, 0)
                        + gaussian(7.41, r) * float3(.078, 0, 0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float2 pos = v.uv * 2.0 - 1.0;
                o.vertex = float4(pos.x, pos.y, 1.0, 1.0);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            
                float r = 1.0 / max(i.uv.y, 0.0001);
                float NdotL = 1.0 / i.uv.x;
                float Theta = acos(NdotL);
                float step = PI / _Samples;
                float3 numerator = 0;
                float3 denominator = 0;
                for (float x = -0.5 * PI; x <= 0.5 * PI; x += step) {
                    float RTerm = R(2.0 * r * sin(0.5 * x));
                    numerator += clamp(cos(Theta + x), 0, 1) * RTerm;
                    denominator += RTerm;
                }
                fixed3 integrad = numerator / denominator;
                fixed4 col = fixed4(integrad, 1.0);
                //fixed4 col = fixed4(1.0, 0, 0, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
