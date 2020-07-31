#ifndef TOONSHADING_COMMON_HEADER
#define TOONSHADING_COMMON_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

sampler2D _MainTex;
sampler2D _NormalMap;

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half3 _DiffuseColorLow;
    half3 _DiffuseColorMed;
    half3 _DiffuseColorHigh;
    half _LMOffset;
    half _MHOffset;
    half _DiffuseSoftness;
    float4 _NormalMap_ST;
    half _DirectLightMultiplier;

    half3 _IndirectLightingColor;
    half _IndirectLightingStrength;
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
#ifdef _NORMALMAP
    half3 tangentWS : TEXCOORD4;
    half3 bitangentWS : TEXCOORD5;
#endif
    float2 uv : TEXCOORD0;
    float4 positionWSAndFogFactor : TEXCOORD2;
};

struct SurfaceData
{
    half4 albedo;
    half3 normalWS;
    half3 viewDirectionWS;
};

#include "ToonShadingLight.hlsl"

BasePassFragmentInput BasePassVertex(BasePassVertexInput input)
{
    BasePassFragmentInput output;
    VertexPositionInputs vertexPosition = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs vertexNormal = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float fogFactor = ComputeFogFactor(vertexPosition.positionCS.z);

    output.positionCS = vertexPosition.positionCS;
    output.positionWSAndFogFactor = float4(vertexPosition.positionWS, fogFactor);

    output.normalWS = vertexNormal.normalWS;
#ifdef _NORMALMAP
    output.tangentWS = vertexNormal.tangentWS;
    output.bitangentWS = vertexNormal.bitangentWS;
#endif
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    return output;
}

void InitializeSurfaceData(BasePassFragmentInput input, out SurfaceData surface)
{
#if defined(_NORMALMAP)
    half4 normalTexValue = tex2D(_NormalMap, input.uv);
    half3 normalTS = UnpackNormal(normalTexValue);
    surface.normalWS = normalize(TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, 
                            input.bitangentWS.xyz, input.normalWS.xyz)));
#else
    surface.normalWS = normalize(input.normalWS);
#endif
    surface.viewDirectionWS = SafeNormalize(GetCameraPositionWS() - input.positionWSAndFogFactor.xyz);
    surface.albedo = tex2D(_MainTex, input.uv);
}

half4 shadeFinalColor(BasePassFragmentInput input)
{
    SurfaceData surface;
    InitializeSurfaceData(input, surface);

    Light mainLight = GetMainLight();

    half3 mainLightResult = shadeMainLight(surface, mainLight);

    half3 indirectLight = shadeIndirectLight(surface);

    return half4(mainLightResult + indirectLight, 1.0);
}

#endif