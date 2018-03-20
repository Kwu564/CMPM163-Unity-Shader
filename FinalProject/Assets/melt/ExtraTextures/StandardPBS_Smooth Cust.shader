 Shader "Tessellation/Standard Smooth 3" {
        Properties {
        	_Tess ("Tesselation", Range(1, 32)) = 4
            _EdgeLength ("Edge length", Range(2,50)) = 5
            _Phong ("Phong Strengh", Range(0,1)) = 0.5
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _MOS ("Metallic (R), Occlussion (G), Smoothness (B)", 2D) = "white" {}
            _Color ("Color", color) = (1,1,1,0)
            _Metallic ("Metallic", Range(0, 1)) = 0.5
            _Glossiness ("Smoothness", Range(0, 1)) = 0.5

            _NoiseTex ("Noise Texture (RGB)", 2D) = "white" {}
			_Amount ("Melt Amount", Range(-1.0,1.0)) = 0.0
			_Temp ("Temperature", Range(0.0,20.0)) = 0.0
			_MeltPoint ("Melting Point", Range(0.0,20.0)) = 5.0
			//_SurfPoint("Surf Point", Vector) = (0.0, 0.0, 0.0, 0.0)
			//_SurfPoint("Surface Point", Float) = 0.5
			_MeltCurve("Melt Curve", Range(0.001,10.0)) = 2.0
			_MeltForm("Melt Form", Range(0.001, 20.0)) = 1.0
			_MeltDist("Melt Distance", Float) = 1.0
			_SpreadFactor ("Spread Factor", Float) = 4.0

        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf Standard addshadow fullforwardshadows vertex:dispNone tessellate:tessEdge tessphong:_Phong
            #include "FreeTess_Tessellator.cginc"


            sampler2D _NoiseTex;
			float _Amount;
			float _Temp;
			float _MeltPoint;
			float _MeltForm;
			float _MeltDist;
			float _MeltCurve;

			float _Tracker;
			float _SpreadFactor;

			float _SurfPoint;

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };

            ////

            float4 newPos( float4 objectSpacePosition, float3 objectSpaceNormal, float cVal ) {

				float4 worldSpacePosition = mul( unity_ObjectToWorld, objectSpacePosition );
				float4 worldSpaceNormal   = mul( unity_ObjectToWorld, float4(objectSpaceNormal,0) );

				float melt = ( worldSpacePosition.y - _SurfPoint ) / _MeltForm;

				melt = 1 - saturate( melt );

				//t = t*t*t * (t * (6f*t - 15f) + 10f)
				melt = melt*melt*melt * (melt * (6.0 * melt - 15.0) + 10.0);
				//melt = pow(_MeltDist * melt, 2.0 );

				//float mel = worldSpacePosition.y * (-0.5);
				float mel = pow(worldSpacePosition.y * (-0.5), 2.0);

				worldSpacePosition.xz += worldSpaceNormal.xz * melt * mel;

				return mul( unity_WorldToObject, worldSpacePosition );
//				//use noisevalue to decrease
//				//float noiseVal = saturate(c.r);


//				//second try at melting
//				float4 worldSpacePosition = mul( unity_ObjectToWorld, objectSpacePosition );
//				float4 worldSpaceNormal   = mul( unity_ObjectToWorld, float4(objectSpaceNormal,0) );
//
//				if (_Temp >= _MeltPoint) {
//
//					float4 rate = (_Temp/_MeltPoint);
//					if (worldSpacePosition.y > _SurfPoint) {
//
//						worldSpacePosition.xyz += float3 (0, -1, 0) *rate * cVal * (_Time * 0.1);
//						float melt = ( worldSpacePosition.y - _SurfPoint ) / _MeltForm;
//
//						melt = 1 - saturate( melt );
//						melt = pow( _MeltDist * melt *melt, _MeltCurve );
//
//						worldSpacePosition.xz += worldSpaceNormal.xz * melt *melt * cVal;
//
//						return mul( unity_WorldToObject, worldSpacePosition );
//						//use noisevalue to decrease
//						//float noiseVal = saturate(c.r);
//
//
//						//float4 worldPosCheck = mul( unity_ObjectToWorld, objectSpacePosition );
//					} else {
//
//						if (worldSpacePosition.y < _SurfPoint) {
//	          				worldSpacePosition.y = _SurfPoint;
//	          			}
//					}
//
//				}

				return mul( unity_WorldToObject, worldSpacePosition );

//
//				//calculates world positions
//				float4 worldSpacePosition = mul( unity_ObjectToWorld, objectSpacePosition );
//				float4 worldSpaceNormal   = mul( unity_ObjectToWorld, float4(objectSpaceNormal,0) );
//
//				//if above melting point:
//				if (_Temp >= _MeltPoint) {
//	          		
//	          		float4 rate = (_Temp/_MeltPoint);
//	          		//worldPos += float3 (0, -1, 0) * rate;
//	          		//v.vertex.xyz = worldPos;
//
//	          		//if still can melt above a certain point
//	          		if (worldSpacePosition.y >= _SurfPoint) {
//
//	          			worldSpacePosition.xyz += float3 (0, -1, 0) *rate * cVal * (_Time * 0.1);
//	          			//meltvalue
//
//
//						float melt = ( worldSpacePosition.y - _SurfPoint ) / _MeltForm;
//						float scalar = sqrt(pow(worldSpacePosition.x, 2.0) + pow(worldSpacePosition.z, 2.0));
//
//						melt = 1 - saturate( melt );
//						//replace with noise texture
//						melt = pow( _MeltDist* melt, 2.0 );
//
//						worldSpacePosition.xz += (worldSpaceNormal.xz * melt * cVal);
//						//worldSpacePosition.y = objectSpacePosition.y;
//						//worldSpacePosition.y += (-1 * cVal * rate * (_Time * 2.0) * melt);
//
//						//float meltY = ( worldSpacePosition.y - _SurfPoint ) / _MeltForm;
//						//meltY = 1 - saturate( melt );
//						//replace with noise texture
//						//meltY = pow( _MeltDist* melt, 2.0 );
//
//						//worldSpacePosition.y = meltY;
//
//						float denom = sqrt(pow(worldSpacePosition.x, 2.0) + pow(worldSpacePosition.z, 2.0));
//						float heightval = 1.0/denom;
//
//						//if (_SurfPoint <= worldSpacePosition.y && worldSpacePosition.y < _SurfPoint + 0.2) {
//						//	worldSpacePosition.y = -(_SurfPoint+ 0.2/denom * 1.1) * denom + _SurfPoint + 0.2;
//
//						//}
//
//
//
//						//if (worldSpacePosition.y < heightval) {
//	          			//	worldSpacePosition.y = heightval ;
//	          			//}
//	          			if (worldSpacePosition.y >= _SurfPoint + 0.05) {
//	          				
//
//						} else if (worldSpacePosition.y < _SurfPoint + 0.05) {
//	          				worldSpacePosition.y = _SurfPoint + 0.05 ;
//	          			}
//
//	          		} else if (worldPosCheck.y < _SurfPoint) {
//	          			worldSpacePosition.y = _SurfPoint;
//	          		}
//
//
//
//					
//					
//					return mul( unity_WorldToObject, worldSpacePosition );
//
//
//
//
//
//
//
//	          	} else {
//	          		return objectSpacePosition;
//	          	}




			

//			//is above melting point
//          	if (_Temp >= _MeltPoint) {
//          		//if still can melt above a certain point
//          		if (objectSpacePosition.y >= _SurfPoint) {
//          			float4 rate = (_Temp/_MeltPoint);
//          			//worldPos += float3 (0, -1, 0) * rate;
//          			//v.vertex.xyz = worldPos;
//          			objectSpacePosition.xyz += float3 (0, -1, 0) * rate;
//          			return objectSpacePosition;
//
//          		}
//
//
//          	} else {
//          		return objectSpacePosition;
//          	}
//          	return objectSpacePosition;
		}
            void dispNone (inout appdata v) { 

            	float cVal = tex2Dlod (_NoiseTex, float4(v.texcoord.xy, 0, 0)).r;
            	cVal = cVal * 0.3;
	          	//float cVal = tex2Dlod (_NoiseTex, v.texcoord).r;
	          	//float3 cVal = sampler2D(_NoiseTex, v.texcoord); //
	          	//calculates new vertex position and normal
	          	float4 vertPosition = newPos( v.vertex, v.normal, cVal);

				float4 bitangent = float4( cross( v.normal, v.tangent ), 0 );

				//calculate new normals
				float4 v1 = newPos( v.vertex + v.tangent * 0.01, v.normal, cVal );
				float4 v2 = newPos( v.vertex + bitangent * 0.01, v.normal, cVal );

				float4 newTangent = v1 - vertPosition;
				float4 newBitangent = v2 - vertPosition;

				//new normal
				v.normal = cross( newTangent, newBitangent );

				v.vertex = vertPosition;

            }

            float _Tess;
            float _Phong;
            float _EdgeLength;

            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
            	return _Tess;
                //return FTSphereProjectionTessNoClip (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
            }

            struct Input {
                float2 uv_MainTex;
                float2 uv_MOS;
            };

            sampler2D _MainTex;
            sampler2D _MOS;
            sampler2D _NormalMap;
            fixed4 _Color;
            float _Metallic;
            float _Glossiness;



            void surf (Input IN, inout SurfaceOutputStandard o) {


                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                half4 mos = tex2D (_MOS, IN.uv_MOS);

                o.Albedo = c.rgb;
                o.Metallic = mos.r * _Metallic;
                o.Smoothness = mos.b *_Glossiness;
                o.Occlusion = mos.g;
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Standard"
    }