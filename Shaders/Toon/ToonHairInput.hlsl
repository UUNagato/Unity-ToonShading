#ifndef TOONSHADING_HAIR_INPUT_HEADER
#define TOONSHADING_HAIR_INPUT_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

sampler2D _MainTex;
sampler2D _ShiftTex;

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half3 _DiffuseColorLow;
    half3 _DiffuseColorMed;
    half3 _DiffuseColorHigh;
    half _LMOffset;
    half _MHOffset;
    half _DiffuseSoftness;

    half3 _IndirectLightingColor;
    half _IndirectLightingStrength;

    float4 _ShiftTex_ST;
    half3 _SpecularColorLow;
    half3 _SpecularColorHigh;
    half _ShiftOffset;
    half _SpecularLowShiftExp;
    half _SpecularHighShiftExp;
    half _SpecularPower;
CBUFFER_END

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
    half3 normalWS : TEXCOORD3;
    half3 tangentWS : TEXCOORD4;
    float2 uv : TEXCOORD0;
    float2 shiftuv : TEXCOORD5;
    float4 positionWSAndFogFactor : TEXCOORD2;
};

struct SurfaceData
{
    half4 albedo;
    half3 normalWS;
    half3 viewDirectionWS;
    half3 tangentWS;
    float2 shiftuv;
};

#include "ToonShadingLight.hlsl"
#include "ToonShadingHairLight.hlsl"

BasePassFragmentInput BasePassVertex(BasePassVertexInput input)
{
    BasePassFragmentInput output;
    VertexPositionInputs vertexPosition = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormal = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float fogFactor = ComputeFogFactor(vertexPosition.positionCS.z);

    output.positionCS = vertexPosition.positionCS;
    output.positionWSAndFogFactor = float4(vertexPosition.positionWS, fogFactor);

    output.normalWS = vertexNormal.normalWS;
    output.tangentWS = vertexNormal.tangentWS;

    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.shiftuv = TRANSFORM_TEX(input.uv, _ShiftTex);
    return output;
}

void InitializeSurfaceData(BasePassFragmentInput input, out SurfaceData surface)
{
    surface.normalWS = normalize(input.normalWS);
    surface.tangentWS = normalize(cross(input.normalWS, input.tangentWS));
    surface.viewDirectionWS = SafeNormalize(GetCameraPositionWS() - input.positionWSAndFogFactor.xyz);
    surface.albedo = tex2D(_MainTex, input.uv);
    surface.shiftuv = input.shiftuv;
}

half4 shadeFinalColor(BasePassFragmentInput input)
{
    SurfaceData surface;
    InitializeSurfaceData(input, surface);

    Light mainLight = GetMainLight();

    half3 mainLightResult = shadeMainLight(surface, mainLight);

    half3 indirectLight = shadeIndirectLight(surface);

    half3 specular = ShadeHairSpecular(surface, mainLight) * _SpecularPower;

    return half4(mainLightResult + indirectLight + specular, 1.0);
}

#endif