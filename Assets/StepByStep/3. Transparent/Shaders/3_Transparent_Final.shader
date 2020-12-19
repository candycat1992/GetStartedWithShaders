Shader "Get Started With Shaders/3. Transparent Final"
{
    Properties
    {
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_GradientMap ("Gradient Map", 2D) = "white" {}

		_ShadowColor1stTex ("1st Shadow Color Tex", 2D) = "white" {}
		_ShadowColor1st ("1st Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_ShadowColor2ndTex ("2nd Shadow Color Tex", 2D) = "white" {}
		_ShadowColor2nd ("2nd Shadow Color", Color) = (1.0, 1.0, 1.0, 1.0)

		[HDR] _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecularPower ("Specular Power", Float) = 20.0

		_RimlightMask ("Rimlight Mask", 2D) = "white" {}
		[HDR] _RimlightColor ("Rimlight Color", Color) = (0.0, 0.0, 0.0, 1.0)
		_RimlightPower ("Rimlight Power", Float) = 20.0

		_OutlineWidth ("Outline Width", Range(0.0, 3.0)) = 1.0
		_OutlineColor ("Outline Color", Color) = (0.2, 0.2, 0.2, 1.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }

		// Extra pass that renders to depth buffer only
		Pass
		{
			ZWrite On
			ColorMask 0
		}

        Pass
        {
			Tags { "LightMode" = "ForwardBase" }

			Cull Back
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

			#define IS_TRANSPARENT
			#include "3_ShadingCommon_Final.cginc"

            ENDCG
        }

		Pass
        {
			Tags { "LightMode" = "ForwardBase" }

			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

			#define IS_TRANSPARENT
			#include "3_OutlineCommon_Final.cginc"
			
            ENDCG
        }
    }
}
