#ifndef TOONSHADING_HAIR_LIGHT_HEADER
#define TOONSHADING_HAIR_LIGHT_HEADER

half3 ShiftTangent (half3 T, half3 N, half3 shift)
{
    half3 shiftedT = T + shift * N;
    return normalize(shiftedT);
}

half StrandSpecular(half3 T, half3 V, half3 L, half exponent)
{
    half3 H = normalize(L + V);
    half TdotH = dot(T, H);
    half sinTH = sqrt(1.0 - TdotH * TdotH);
    half dirAtten = smoothstep(-1.0, 0.0, TdotH);
    return dirAtten * pow(sinTH, exponent);
}

half3 ShadeHairSpecular(SurfaceData surface, Light light)
{
    half shiftTex = tex2D(_ShiftTex, surface.shiftuv).r - 0.5;
    half3 t1 = ShiftTangent(surface.tangentWS, surface.normalWS, _ShiftOffset + shiftTex);
    half3 t2 = ShiftTangent(surface.tangentWS, surface.normalWS, _ShiftOffset + shiftTex);

    half3 highSpec = _SpecularColorHigh * StrandSpecular(t1, surface.viewDirectionWS, light.direction, _SpecularHighShiftExp);
    half3 lowSpec = _SpecularColorLow * StrandSpecular(t2, surface.viewDirectionWS, light.direction, _SpecularLowShiftExp);

    half lightAttenuation = getStandardLightAttenuation(light);

    return (lowSpec + highSpec) * lightAttenuation;
}

#endif