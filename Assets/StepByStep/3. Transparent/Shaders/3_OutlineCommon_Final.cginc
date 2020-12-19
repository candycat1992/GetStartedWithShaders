#ifndef OUTLINE_COMMON_FINAL
#define OUTLINE_COMMON_FINAL

sampler2D _MainTex;
float4 _MainTex_ST;
half4 _Color;
half _Cutoff;

float _OutlineWidth;
half4 _OutlineColor;

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
};

v2f vert(a2v v)
{
	v2f o;

	float3 viewPos = UnityObjectToViewPos(v.vertex);
	float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
	viewNormal.z = -0.5;
	viewPos = viewPos + normalize(viewNormal) * _OutlineWidth * 0.002;
	o.vertex = mul(UNITY_MATRIX_P, float4(viewPos, 1.0));
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);

	return o;
}

half4 frag(v2f i) : SV_Target
{
	half4 albedo = tex2D(_MainTex, i.uv) * _Color;

#if defined (IS_ALPHATEST)
	clip(albedo.a - _Cutoff);
#endif

	half3 col = albedo.rgb * _OutlineColor.rgb;

#if defined (IS_TRANSPARENT)
	return half4(col, albedo.a);
#else
	return half4(col, 1.0);
#endif
}

#endif // OUTLINE_COMMON_FINAL