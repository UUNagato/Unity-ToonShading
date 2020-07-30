#ifndef TOONSHADING_COMMON_HEADER
#define TOONSHADING_COMMON_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct BasePassVertexInput
{
    float3 positionOS : POSITION;
    half3 normalOS : NORMAL;
    half4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
};

struct BasePassFragmentInput
{
    float4 positionCS : SV_POSITION;
    half3 normalWS : NORMAL;
    float2 uv : TEXCOORD0;
    float4 positionWSAndFogFactor : TEXCOORD2;
};

sampler2D _MainTex;
sampler2D _NormalTex;

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half3 _DiffuseColorLow;
    half3 _DiffuseColorMed;
    half3 _DiffuseColorHigh;
    half _LMOffset;
    half _MHOffset;
    half _DiffuseSoftness;
    float4 _NormalTex_ST;

    half3 _IndirectLightingColor;
    half _IndirectLightingStrength;
CBUFFER_END

#include "ToonShadingLight.hlsl"

half4 shadeFinalColor(BasePassFragmentInput input)
{
    SurfaceData surface;
    surface.normalWS = normalize(input.normalWS);
    surface.viewDirectionWS = SafeNormalize(GetCameraPositionWS() - input.positionWSAndFogFactor.xyz);
    Light mainLight = GetMainLight();

    surface.albedo = tex2D(_MainTex, input.uv);

    half3 mainLightResult = shadeMainLight(surface, mainLight);

    half3 indirectLight = shadeIndirectLight(surface);

    return half4(mainLightResult + indirectLight, 1.0);
}

#endif