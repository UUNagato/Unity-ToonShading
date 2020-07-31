#ifndef TOONSHADING_LIGHT_HEADER
#define TOONSHADING_LIGHT_HEADER

half3 getDiffuseRamp(half NdotL)
{
    half factor1 = smoothstep(_LMOffset - _DiffuseSoftness, _LMOffset + _DiffuseSoftness, NdotL);
    half3 LMColor = lerp(_DiffuseColorLow, _DiffuseColorMed, saturate(factor1));
    half factor2 = smoothstep(_MHOffset - _DiffuseSoftness, _MHOffset + _DiffuseSoftness, NdotL);
    half3 MHColor = lerp(LMColor, _DiffuseColorHigh, saturate(factor2));

    return MHColor;
}

half3 shadeMainLight(SurfaceData surface, Light light)
{
    half3 N = surface.normalWS;
    half3 L = light.direction;
    half3 V = surface.viewDirectionWS;
    half3 H = normalize(L + V);

    half NdotL = dot(N, L);
    half3 rampColor = getDiffuseRamp(NdotL);

    half lightAttenuation = light.shadowAttenuation;
    lightAttenuation *= min(2, light.distanceAttenuation);
    lightAttenuation *= _DirectLightMultiplier;

    return rampColor * surface.albedo.xyz * light.color * lightAttenuation;
}

half3 shadeIndirectLight(SurfaceData surface)
{
    half3 constAO = SampleSH(0);
    return ((constAO + _IndirectLightingColor) * surface.albedo * _IndirectLightingStrength);
}

#endif