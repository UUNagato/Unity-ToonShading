#ifndef TOONSHADING_LIGHT_HEADER
#define TOONSHADING_LIGHT_HEADER

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct SurfaceData
{
    half4 albedo;
    half3 normalWS;
    half3 viewDirectionWS;
};

half3 shadeMainLight(SurfaceData surface, Light light)
{
    half3 N = surface.normalWS;
    half3 L = light.direction;
    half3 V = surface.viewDirectionWS;
    half3 H = normalize(L + V);

    half NdotL = dot(N, L) * 0.5 + 0.5;

    half lightAttenuation = NdotL;

    lightAttenuation *= light.shadowAttenuation;
    lightAttenuation *= min(2, light.distanceAttenuation);

    return surface.albedo * light.color * lightAttenuation;
}

#endif