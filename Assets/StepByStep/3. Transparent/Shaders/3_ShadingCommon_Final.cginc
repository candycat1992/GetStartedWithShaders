#ifndef SHADING_COMMON_FINAL
#define SHADING_COMMON_FINAL

sampler2D _MainTex;
float4 _MainTex_ST;
half4 _Color;
half _Cutoff;
sampler2D _GradientMap;

sampler2D _ShadowColor1stTex;
half4 _ShadowColor1st;
sampler2D _ShadowColor2ndTex;
half4 _ShadowColor2nd;

half4 _SpecularColor;
half _SpecularPower;

sampler2D _RimlightMask;
half4 _RimlightColor;
half _RimlightPower;

float4 _LightColor0;

struct a2v
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normalDir : TEXCOORD1;
	float3 worldPos : TEXCOORD2;
};

v2f vert(a2v v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.normalDir = UnityObjectToWorldNormal(v.normal);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	return o;
}

half4 frag(v2f i) : SV_Target
{
	half3 normalDir = normalize(i.normalDir);
	half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	half3 halfDir = normalize(lightDir + viewDir);

	half4 albedo = tex2D(_MainTex, i.uv) * _Color;

#if defined (IS_ALPHATEST)
	clip(albedo.a - _Cutoff);
#endif

	// Ambient lighting
	half3 ambient = max(ShadeSH9(half4(0.0, 1.0, 0.0, 1.0)), ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)));

	// Diffuse lighting
	half nl = dot(normalDir, lightDir) * 0.5 + 0.5;
	half2 diffGradient = tex2D(_GradientMap, float2(nl, 0.5)).rg;
	half3 diffAlbedo = lerp(albedo.rgb, tex2D(_ShadowColor1stTex, i.uv).rgb * _ShadowColor1st.rgb, diffGradient.x);
	diffAlbedo = lerp(diffAlbedo, tex2D(_ShadowColor2ndTex, i.uv).rgb * _ShadowColor2nd.rgb, diffGradient.y);
	half3 diff = diffAlbedo;

	// Specular lighting
	half nh = dot(normalDir, halfDir);
	half specGradient = tex2D(_GradientMap, float2(pow(max(nh, 1e-5), _SpecularPower), 0.5)).b;
	half3 spec = specGradient * albedo.rgb * _SpecularColor.rgb;

	// Rimlight
	half nv = dot(normalDir, viewDir);
	half rimlightGradient = tex2D(_GradientMap, float2(pow(max(1.0 - clamp(nv, 0.0, 1.0), 1e-5), _RimlightPower), 0.5)).a;
	half rimlightMask = tex2D(_RimlightMask, i.uv);
	half3 rimlight = rimlightGradient * _RimlightColor.rgb * rimlightMask * diff;

	half3 col = ambient * albedo.rgb + (diff + spec) * _LightColor0.rgb + rimlight;

#if defined (IS_TRANSPARENT)
	return half4(col, albedo.a);
#else
	return half4(col, 1.0);
#endif
}

#endif // SHADING_COMMON_FINAL