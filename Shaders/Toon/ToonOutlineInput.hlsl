#ifndef TOONSHADING_OUTLINE_INPUT_HEADER
#define TOONSHADING_OUTLINE_INPUT_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

sampler2D _MainTex;

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half _OutlineWidth;
    half4 _OutlineColor;
CBUFFER_END

struct OutlineVertexInput
{
    float3 positionOS : POSITION;
    half3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct OutlineFragmentInput
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD2;
    half3 normalWS : TEXCOORD3;
};

#define INV_EDGE_THICKNESS_DIVISOR 0.00285
#define EDGE_SATURATION 0.6
#define BRIGHTNESS_FACTOR 0.8

OutlineFragmentInput OutlineVertex(OutlineVertexInput input)
{
    OutlineFragmentInput output;
    VertexPositionInputs vertexPos = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNorm = GetVertexNormalInputs(input.normalOS);
    
    half4 normalCS = normalize(mul(UNITY_MATRIX_MVP, half4(input.normalOS, 0)));
    half4 scaledNormal = _OutlineWidth * INV_EDGE_THICKNESS_DIVISOR * normalCS;
    scaledNormal.z += 0.00001;

    output.positionCS = vertexPos.positionCS + scaledNormal;
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.normalWS = vertexNorm.normalWS;

    return output;
}

half4 OutlineFragment(OutlineFragmentInput input) : SV_Target
{
    half4 diffuse = tex2D(_MainTex, input.uv);

    half maxChannel = max(max(diffuse.r, diffuse.g), diffuse.b);
    maxChannel -= (1.0 / 255.0);
    half3 lerpVal = saturate((diffuse.rgb - half3(maxChannel, maxChannel, maxChannel)) * 255.0);
    half3 OutlineFactor = lerp(EDGE_SATURATION * diffuse.rgb, diffuse.rgb, lerpVal);

    return half4(BRIGHTNESS_FACTOR * OutlineFactor * diffuse.rgb, diffuse.a) * _OutlineColor;
}

#endif