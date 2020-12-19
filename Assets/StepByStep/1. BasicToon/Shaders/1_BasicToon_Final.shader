Shader "Get Started With Shaders/1. Basic Toon Final"
{
    Properties
    {
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_ShadowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
		_ShadowThreshold ("Shadow Threshold", Range(-1.0, 1.0)) = 0.0
		[HDR] _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecularPower ("Specular Power", Float) = 20.0
		_SpecularThreshold ("Specular Threshold", Range(0.0, 1.0)) = 0.5

		_OutlineWidth ("Outline Width", Range(0.0, 3.0)) = 1.0
		_OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
			Tags { "LightMode" = "ForwardBase" }

			Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;

			half4 _ShadowColor;
			half _ShadowThreshold;
			half4 _SpecularColor;
			half _SpecularPower;
			half _SpecularThreshold;

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

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target
			{
				half3 normalDir = normalize(i.normalDir);
				half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 halfDir = normalize(lightDir + viewDir);

				half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				// Ambient lighting
				half3 ambient = max(ShadeSH9(half4(0.0, 1.0, 0.0, 1.0)), ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)));

				// Diffuse lighting
				half nl = dot(normalDir, lightDir);
				half3 diff = nl > _ShadowThreshold ? 1.0 : _ShadowColor.rgb;

				// Specular lighting
				half nh = dot(normalDir, halfDir);
				half3 spec = pow(max(nh, 1e-5), _SpecularPower) > _SpecularThreshold ? _SpecularColor.rgb : 0.0;

				half3 col = ambient * albedo.rgb + (diff + spec) * albedo.rgb * _LightColor0.rgb;

                return half4(col, 1.0);
            }
            ENDCG
        }

		Pass
        {
			Tags { "LightMode" = "ForwardBase" }

			Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;

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

            v2f vert (a2v v)
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

            half4 frag (v2f i) : SV_Target
			{
				half3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				half3 col = albedo.rgb * _OutlineColor.rgb;

                return half4(col, 1.0);
            }
            ENDCG
        }
    }
}
