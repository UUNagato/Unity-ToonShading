#ifndef TOONSHADING_COMMON_HEADER
#define TOONSHADING_COMMON_HEADER

#include "ToonShadingLight.hlsl"

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
CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
CBUFFER_END

half4 shadeFinalColor(BasePassFragmentInput input)
{
    SurfaceData surface;
    surface.albedo = tex2D(_MainTex, input.uv);
    surface.normalWS = input.normalWS;
    surface.viewDirectionWS = SafeNormalize(GetCameraPositionWS() - input.positionWSAndFogFactor.xyz);
    Light mainLight = GetMainLight();

    half3 mainLightResult = shadeMainLight(surface, mainLight);

    half3 indirectLight = SampleSH(0);

    return half4(mainLightResult + indirectLight, 1.0);
}

#endif