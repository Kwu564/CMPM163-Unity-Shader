Shader "Custom/TransluShader"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (0.0, 0.0, 0.0, 1.0)
		_SpecColor( "Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess(" Shininess", Range(0.03, 1)) = 0.078125
		
		_Power("Subsurface Power", Float) = 1.0
		_Distortion("Subsurface Distortion", Float) = 0.0
		_Scale("Subsurface Scale", Float) = 0.5
		_SubColor("Subsurface Color", Color) = (1.0, 1.0, 1.0, 1.0)
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 0
		
        Blend SrcAlpha OneMinusSrcAlpha
		

		CGPROGRAM
		#pragma surface surf Translucent vertex:vert
		#pragma exclude_renderers flash

		sampler2D _MainTex, _BumpMap;

		float _Scale, _Power, _Distortion;
		fixed4 _Color, _SubColor;
		half _Shininess;
		struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
		void vert(inout appdata_full v) {
           
            
             //vertex.y += sin(_Time.y * 4 + v.vertex.x * 2) * 0.2 * 0.19;
			 v.vertex.y += sin(_Time.y * 4 + v.vertex.x *8) * 0.04 + cos(_Time.y * 4 + v.vertex.x * 8) * 0.05  ;
			 v.vertex.x += v.normal * clamp(sin(_Time.y) * 0.05, 0, 2);
         }
		struct Input {
			float2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color.rgb;
			//o.Alpha = tex2D(_Thickness, IN.uv_MainTex).r;
			o.Alpha = 0.8;
			o.Gloss = tex.a;
			o.Specular = _Shininess;
		}

		inline fixed4 LightingTranslucent (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
		{		

			// Translucency.
			half3 transLightDir = lightDir + s.Normal * _Distortion;
			float transDot = pow ( max (0, dot ( viewDir, -transLightDir ) ), _Power ) * _Scale;
			fixed3 transLight = (atten * 2) * ( transDot ) * s.Alpha * _SubColor.rgb;
			fixed3 transAlbedo = s.Albedo * _LightColor0.rgb * transLight;

			// Regular BlinnPhong.
			half3 h = normalize (lightDir + viewDir); //halfway vector
			fixed diff = max (0, dot (s.Normal, lightDir));
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular*128.0) * s.Gloss;
			fixed3 diffAlbedo = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
		
			fixed4 c;
			c.rgb = diffAlbedo + transAlbedo;
			c.a = _LightColor0.a * _SpecColor.a * spec * atten;
			return c;
		}

		ENDCG
	}
	//FallBack "Bumped Diffuse"
}
