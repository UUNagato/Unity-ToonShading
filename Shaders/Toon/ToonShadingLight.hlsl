#ifndef TOONSHADING_LIGHT_HEADER
#define TOONSHADING_LIGHT_HEADER

half getStandardLightAttenuation(Light light)
{
    half lightAttenuation = lerp(1, light.shadowAttenuation, _ShadowMultiplier);
    lightAttenuation *= min(2, light.distanceAttenuation);

    return lightAttenuation;
}

half3 getDiffuseRamp(half NdotL)
{
    half factor1 = smoothstep(_LMOffset - _DiffuseSoftness, _LMOffset + _DiffuseSoftness, NdotL);
    half3 LMColor = lerp(_DiffuseColorLow, _DiffuseColorMed, saturate(factor1));
    half factor2 = smoothstep(_MHOffset - _DiffuseSoftness, _MHOffset + _DiffuseSoftness, NdotL);
    half3 MHColor = lerp(LMColor, _DiffuseColorHigh, saturate(factor2));

    return MHColor;
}

real3 fresnelSchlick(real cosTheta, real3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

real distributionGGX(real3 N, real3 H, real roughness)
{
    real a = roughness * roughness;
    real a2 = a * a;
    real NdotH = dot(N, H);
    real NdotH2 = NdotH * NdotH;

    real num = a2;
    real denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return num / denom;
}

real geometrySchlickGGX(real NdotV, real roughness)
{   
    real r = (roughness + 1.0);
    real k = (r * r) / 8.0;

    real num = NdotV;
    real denom = NdotV * (1.0 - k) + k;

    return num / denom;
}

real geometrySmith(real3 N, real3 V, real3 L, real k)
{
    real NdotV = saturate(dot(N, V));
    real NdotL = saturate(dot(N, L));
    real ggx1 = geometrySchlickGGX(NdotV, k);
    real ggx2 = geometrySchlickGGX(NdotL, k);

    return ggx1 * ggx2;
}

real3 shaderGGXSpecular(SurfaceData surface, Light light)
{
    return half3(0, 0, 0);
}

half3 shadeSpecularColor(SurfaceData surface, Light light)
{
    half3 N = surface.normalWS;
    half3 L = light.direction;
    half3 V = surface.viewDirectionWS;
    half3 H = normalize(L + V);

    half NdotH = saturate(dot(N, H));
    half specularTerm = pow(NdotH, _SpecularPower);
    half lightAttenuation = getStandardLightAttenuation(light) * _SpecularMultiplier;

    return _SpecularColor * surface.albedo.xyz * light.color * specularTerm * lightAttenuation;
}

half3 shadeMainLight(SurfaceData surface, Light light)
{
    half3 N = surface.normalWS;
    half3 L = light.direction;

    half NdotL = dot(N, L);
    half3 rampColor = getDiffuseRamp(NdotL);

    half lightAttenuation = getStandardLightAttenuation(light) * _DirectLightMultiplier;

    return rampColor * surface.albedo.xyz * light.color * lightAttenuation;
}

#if defined(_PREINTEGRATED_SUBSURFACE_SCATTERING)
half3 shadeSubsurfaceScattering(SurfaceData surface, half curvature, Light light)
{
    half NdotL = dot(surface.normalWS, light.direction);
    NdotL = saturate((NdotL + 1.0) * 0.5);
    half3 SSSValue = tex2D(_SSSLUTTex, half2(NdotL, curvature));

    half lightAttenuation = getStandardLightAttenuation(light) * _SSSMultiplier;

    return SSSValue * surface.albedo.xyz * _SSSColor * light.color * lightAttenuation;
}
#endif

half3 shadeIndirectLight(SurfaceData surface)
{
    half3 constAO = SampleSH(0);
    return ((constAO + _IndirectLightingColor) * surface.albedo.xyz * _IndirectLightingStrength);
}

#endif