#ifndef TOONSHADING_COMMON_HEADER
#define TOONSHADING_COMMON_HEADER

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
    half3 normalWS : TEXCOORD3;
#ifdef _NORMALMAP
    half3 tangentWS : TEXCOORD4;
    half3 bitangentWS : TEXCOORD5;
#endif
    float2 uv : TEXCOORD0;
    float4 positionWSAndFogFactor : TEXCOORD2;
    float4 shadowCoord : TEXCOORD6;
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

#ifdef _MAIN_LIGHT_SHADOWS
    output.shadowCoord = TransformWorldToShadowCoord(vertexPosition.positionWS);
#else
    output.shadowCoord = half4(0, 0, 0, 1);
#endif

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
    surface.albedo = tex2D(_MainTex, input.uv) * _MainColor;
}

half4 shadeFinalColor(BasePassFragmentInput input)
{
    SurfaceData surface;
    InitializeSurfaceData(input, surface);

#ifdef _MAIN_LIGHT_SHADOWS
    Light mainLight = GetMainLight(input.shadowCoord);
#else
    Light mainLight = GetMainLight();
#endif

    half3 mainLightResult = shadeMainLight(surface, mainLight);
    half3 specularLight = shadeSpecularColor(surface, mainLight);
    half3 indirectLight = shadeIndirectLight(surface);

    half3 finalColor = mainLightResult + specularLight + indirectLight;

#if defined(_PREINTEGRATED_SUBSURFACE_SCATTERING)
    half curvature = saturate(length(fwidth(input.normalWS)) / length(fwidth(input.positionWSAndFogFactor.xyz)));
    half3 sssColor = shadeSubsurfaceScattering(surface, curvature, mainLight);

    finalColor += sssColor;
#endif

    return half4(finalColor, 1.0);
}

#endif