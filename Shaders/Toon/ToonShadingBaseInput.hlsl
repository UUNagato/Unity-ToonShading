#ifndef TOONSHADING_BASE_INPUT_HEADER
#define TOONSHADING_BASE_INPUT_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _SpecularTex;
sampler2D _SSSLUTTex;

CBUFFER_START(UnityPerMaterial)
    half4 _MainColor;
    float4 _MainTex_ST;
    half3 _DiffuseColorLow;
    half3 _DiffuseColorMed;
    half3 _DiffuseColorHigh;
    half _LMOffset;
    half _MHOffset;
    half _DiffuseSoftness;
    float4 _NormalMap_ST;
    half _DirectLightMultiplier;

    half3 _SpecularColor;
    half _SpecularPower;
    half _SpecularMultiplier;

    half3 _IndirectLightingColor;
    half _IndirectLightingStrength;

    half _ShadowMultiplier;

    half3 _SSSColor;
    half _SSSMultiplier;
CBUFFER_END

#endif