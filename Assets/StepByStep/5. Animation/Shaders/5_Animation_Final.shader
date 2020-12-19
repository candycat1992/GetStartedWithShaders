Shader "Get Started With Shaders/5. Animation Final"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[HDR] _Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_ColorGradient ("Color Gradient", 2D) = "white" {}
		_ColorGradientTiling ("Color Gradient Tiling", Float) = 1.0
		_ColorGradientSpeed ("Color Gradient Speed", Float) = 1.0
		_AlphaGradient ("Alpha Gradient", 2D) = "white" {}
		_AlphaGradientTiling ("Alpha Gradient Tiling", Float) = 1.0
		_AlphaGradientSpeed ("Alpha Gradient Speed", Float) = 1.0
		_GridSize ("Grid Size", Range(0.0, 1.0)) = 0.1
		_SpotSize ("Spot Size", Range(0.0, 0.5)) = 0.3
    }
    SubShader
    {
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }

        Pass
        {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;

			sampler2D _ColorGradient;
			float _ColorGradientTiling;
			float _ColorGradientSpeed;
			sampler2D _AlphaGradient;
			float _AlphaGradientTiling;
			float _AlphaGradientSpeed;

			half _GridSize;
			half _SpotSize;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			half4 frag (v2f i) : SV_Target
            {
				half4 albedo = tex2D(_MainTex, i.uv) * _Color;
				half3 col = albedo.rgb;
				half alpha = albedo.a;

				float distToCenter = length(i.uv - 0.5);

				float colorGradientSample = distToCenter * _ColorGradientTiling + _Time.y * _ColorGradientSpeed;
				half3 colorGradient = tex2D(_ColorGradient, float2(colorGradientSample, 0.5));
				col *= colorGradient;

				float alphaGradientSample = distToCenter * _AlphaGradientTiling + _Time.y * _AlphaGradientSpeed;
				half alphagradient = tex2D(_AlphaGradient, float2(alphaGradientSample, 0.5));
				alpha *= alphagradient;

				half2 grid = fmod(i.uv, _GridSize) / _GridSize;
				half distToGrid = length(grid - 0.5);
				alpha *= step(distToGrid, _SpotSize);

				return half4(col, alpha);
            }
            ENDCG
        }
    }
}
