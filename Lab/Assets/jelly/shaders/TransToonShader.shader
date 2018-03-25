﻿Shader "Custom/TransToonShader"{
	Properties
    {
        _MainTex ("Albedo Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0.0,0.7)) = 0.25
        _CutoutThresh("Cutout Threshold", Range(0.0,1.0)) = 0.2
		_OutlineCorlor("Outline color", Color) = (0.1, 0.9, 0.2, 1.0)
 
    }

    SubShader
    {
        Tags  {"Queue"="Transparent" "RenderType"="Transparent" }
		Cull Front
		ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

       

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 color : COLOR;
 
            };

            sampler2D _MainTex;
			float4 _MainTex_ST;
            float4 _TintColor;
            float _Transparency;
            float _CutoutThresh;
			float4 _OutlineCorlor;
			v2f vert (appdata v)
            {
                v2f o;
                //v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Amplitude) * _Distance * _Amount;
				v.vertex.x += clamp(sin(_Time.y) * 0.01, 0, 1);
				//v.vertex.y += sin(_Time.y * _Speed + v.vertex.x * _Amplitude) * 0.04 - cos(_Time.y * _Speed + v.vertex.x * _Amplitude) * 0.05  ;
				v.vertex.y += clamp( 0.03 * sin(_Time.y * 4 + v.vertex.x *8)  - cos(_Time.y * 4 + v.vertex.x * 8) * 0.05, 0, 1)  ;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 norm = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(norm.xy); 
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.pos.xy += offset * 0.005;
				
				o.color = _OutlineCorlor;
				
				return o;
			}	
      
              
            
			
            fixed4 frag (v2f i) : COLOR
            {
				
                return fixed4(i.color.rgb, clamp(sin(_Time.y *2) * 0.4, 0, 1) + 0.2);
            }
			ENDCG
		}
		
			
			/**
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) +  _TintColor;	
				col.a = _Transparency;
				
				
			
               
                clip(col.r - _CutoutThresh);
                return col;
            }
			ENDCG**/

			
    }        
    
}