// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/meltsurflight" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Color2 ("Melt Color", Color) = (0, 0, 0, 0)
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise Texture (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Amount ("Melt Amount", Range(-1.0,1.0)) = 0.0
		_Temp ("Temperature", Range(0.0,20.0)) = 0.0
		_MeltPoint ("Melting Point", Range(0.0,20.0)) = 5.0
		//_SurfPoint("Surf Point", Vector) = (0.0, 0.0, 0.0, 0.0)
		//_SurfPoint("Surface Point", Float) = 0.5
		_MeltForm("Melt Form", Float) = 1
		_MeltDist("Melt Distance", Float) = 1.0
		_MeltSize("Melt Size", Float) = 2.0
		_Tess ("Tesselation", Range(1, 50)) = 4

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma multi_compile_shadowcaster
		//#pragma multi_compile UNITY_PASS_SHADOWCASTER
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow nolightmap tessellate:tessFixed

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 4.6

		//use tesselation code
		#include "Tessellation.cginc"

		struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
            fixed4 color: COLOR;
        };

		sampler2D _MainTex;
		sampler2D _NoiseTex;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _Color2;
		float _Amount;
		float _Temp;
		float _MeltPoint;
		float _MeltForm;
		float _MeltDist;
		float _MeltSize;

		float _SurfPoint;
		fixed4 prevPoint;

		float _MeltDuration;

		float _Tess;
		float _MeltVar;

		struct Input {
			float2 uv_MainTex;
			//position of pixel in world?
			//float4 vertex : POSITION;
			//float4 color: COLOR;
			float3 localPos;
			float3 worldPos;
		};

		float4 tessFixed() {
			return _Tess;
		}

		//create new position of vertex
		float4 newPos( float4 objectSpacePosition, float3 objectSpaceNormal, float cVal ) {

			float4 objCenter = unity_ObjectToWorld[3];
			float4 worldSpacePosition = mul( unity_ObjectToWorld, objectSpacePosition );
			float4 worldSpaceNormal   = mul( unity_ObjectToWorld, float4(objectSpaceNormal,0) );

			float rate = _Temp/_MeltPoint;
			worldSpacePosition.y += float3(0, -1, 0) * rate * cVal;
			//for when it starts melting around
			float melt = ( worldSpacePosition.y - _SurfPoint ) / _MeltForm;


			float mel = melt;


			//float mel = melt;
			//0 is not melted, 1 is fully melted
			melt = 1 - saturate( melt );


			//smoother step
			//t = t*t*t * (t * (6f*t - 15f) + 10f)
			melt = (melt*melt*melt * (melt * (6.0 * melt - 15.0) + 10.0)) ;
			//melt = melt + meY;
			//melt = pow( melt, 2.0 );

			float magnitude = pow(cVal, 2.0);

			//worldSpacePosition.y += float3(0, -1, 0) * magnitude;
			//later on, use _MeltVar to increase radial
			worldSpacePosition.z += worldSpaceNormal.z  * melt  *_MeltVar/3.0 *cVal;
			worldSpacePosition.x += worldSpaceNormal.x  * melt  * _MeltVar/3.0;
		

			if (worldSpacePosition.y <= _SurfPoint) {
				
				worldSpacePosition.y = _SurfPoint - (mel * _MeltSize);
			} else  {
				//worldSpacePosition.y += float3 (0, -1, 0) *rate * (_Time * 0.1);
			}

			return mul( unity_WorldToObject, worldSpacePosition );

		}


		//uses Conewars shader to do code
		//taken from http://diary.conewars.com/vertex-displacement-shader/
		void vert (inout appdata v) {

			UNITY_SETUP_INSTANCE_ID( v);
			//UNITY_INITIALIZE_OUTPUT(Input, o);

          	float cVal = tex2Dlod (_NoiseTex, float4(v.texcoord.xy, 0, 0)).r;
          	cVal = pow(cVal, 2.0);
          	//float cVal = tex2Dlod (_NoiseTex, v.texcoord).r;
          	//float3 cVal = sampler2D(_NoiseTex, v.texcoord); //
          	//calculates new vertex position and normal
          	float4 vertPosition = newPos( v.vertex, v.normal, cVal);

			float4 bitangent = float4( cross( v.normal, v.tangent ), 0 );
			float vertOffset = 0.01;

			float4 v1 = newPos( v.vertex + v.tangent * vertOffset, v.normal, cVal );
			float4 v2 = newPos( v.vertex + bitangent * vertOffset, v.normal, cVal );

			float4 newTangent = v1 - vertPosition;
			float4 newBitangent = v2 - vertPosition;

			//new normal
			v.normal = cross( newTangent, newBitangent );

			v.vertex = vertPosition;

			//o.uv_MainTex = v.texcoord;


      	}

      	//melted color
      	float nColor( float3 worldSpacePosition ) {
			float4 objectSpacePosition = mul( unity_WorldToObject, float4( worldSpacePosition, 0 ));
			float melt = ( worldSpacePosition.y - _SurfPoint ) / _MeltForm;

			melt = 1 - saturate( melt );
			melt = (melt*melt*melt * (melt * (6.0 * melt - 15.0) + 10.0)); 

			return melt;
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color

			//float val = nColor(IN.worldPos);
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			//o.Albedo = lerp(c.rgb, _Color2.rgb, val);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
