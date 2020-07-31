#ifndef TOONSHADING_SHADOW_INPUT_HEADER
#define TOONSHADING_SHADOW_INPUT_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

float3 _LightDirection;

struct ShadowVertexInput
{
    float3 positionOS : POSITION;
    half3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct ShadowFragmentInput
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
};

sampler2D _MainTex;

CBUFFER_START(UnityPerMaterial)
    half4 _MainTex_ST;
CBUFFER_END

float4 GetShadowPositionHClip(ShadowVertexInput input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

ShadowFragmentInput ShadowVertex(ShadowVertexInput input)
{
    ShadowFragmentInput output;
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

half4 ShadowFragment(ShadowFragmentInput input) : SV_Target
{
    Alpha(tex2D(_MainTex, input.uv).a, half4(0, 0, 0, 1), 0.0);
    return 0;
}

#endif