//Parallax occlusion mapping shader that creates a landscape in a quad
Shader "Custom/Parallax"
{
	// Appears in the Inspector
	// Gives Unity3D access to the hidden variables within the shader
	Properties
	{
		_DisplaceTex("Displacement Map", 2D) = "white" {}
		_AlbedoTex("Albedo Map (RGB)", 2D) = "white" {}
		_Height("Height", Range(0.0001,5)) = 1.0
		_Metallic("Metallic", Range(0,1)) = 0.0
	}

		// Contains the actual code of our shader, executed for every pixel of our image
		SubShader
	{
		// Tell Unity to render objects with this shader opaque
		Tags{ "RenderType" = "Opaque" }

		// Cg/HLSL code below...
		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		// Define our properties
		sampler2D _DisplaceTex;
		sampler2D _AlbedoTex;
		float _Height;
		half _Metallic;

		struct Input
		{
			// What Unity can give you
			float2 uv_DisplaceTex;

			// What you have to calculate yourself
			float3 tangentViewDir;
		};

		// Vertex shader
		void vert(inout appdata_full i, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// Transform the view direction from world space to tangent space			
			float3 worldVertexPos = mul(unity_ObjectToWorld, i.vertex).xyz;
			float3 worldViewDir = worldVertexPos - _WorldSpaceCameraPos;

			// To convert from world space to tangent space we need the following
			// https://docs.unity3d.com/Manual/SL-VertexFragmentShaderExamples.html
			float3 worldNormal = UnityObjectToWorldNormal(i.normal);
			float3 worldTangent = UnityObjectToWorldDir(i.tangent.xyz);
			float3 worldBitangent = cross(worldNormal, worldTangent) * i.tangent.w * unity_WorldTransformParams.w;

			// Use dot products instead of building the matrix
			o.tangentViewDir = float3(
				dot(worldViewDir, worldTangent),
				dot(worldViewDir, worldNormal),
				dot(worldViewDir, worldBitangent)
				);
		}

		// Get the height from a uv position
		float getHeight(float2 position)
		{
			// Flatten the displacement a little
			float4 map = tex2Dlod(_DisplaceTex, float4(position * 0.2, 0, 0));

			// Get the height at each point of the image
			float height = (1 - map.r) * -1 * _Height;

			return height;
		}

		// Obtain texture position by interpolating between the position where we hit the terrain and the previous raymarched position
		float2 getTexPos(float3 rayPos, float3 rayDir, float stepDistance)
		{
			// Get the previous raymarched step back to the position before we hit the geometry represented by the displacement map
			float3 prevPos = rayPos - stepDistance * rayDir;

			float prevHeight = getHeight(prevPos.xz);

			// Distance between geometry and the previous raymarched position
			float prevDistToGeometry = abs(prevHeight - prevPos.y);

			float currentHeight = getHeight(rayPos.xz);

			// Distance between geometry and the current raymarched position
			float currentDistToGeometry = rayPos.y - currentHeight;

			float weight = currentDistToGeometry / (currentDistToGeometry - prevDistToGeometry);

			// Calculate texture coordinate
			float2 weightedTexPos = prevPos.xz * weight + rayPos.xz * (1 - weight);

			return weightedTexPos;
		}

		// Lets us specify properties of our surface shader
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Set the start position of the ray above the surface
			// This will also store the rayPos during raymarching
			float3 rayPos = float3(IN.uv_DisplaceTex.x, 0, IN.uv_DisplaceTex.y);

			// Set the ray's direction
			float3 rayDir = normalize(IN.tangentViewDir);

			// The default color used if the ray doesnt hit anything
			//float4 finalColor = 1;

			float4 color;

			// Raymarch a specified number of steps to determine where the ray intersects with
			// the displacement map
			int stepAmount = 900;
			float stepDistance = 0.01;
			for (int i = 0; i < stepAmount; i++)
			{
				// Calculate the height at this uv coordinate
				float height = getHeight(rayPos.xz);

				// During each step, check if the ray is below the surface
				if (rayPos.y < height)
				{
					// Obtain texture position by interpolating between the position where we hit the terrain and the previous raymarched position
					float2 texPos = getTexPos(rayPos, rayDir, stepDistance);

					// Calculate the height at this uv coordinate
					//float height = getHeight(texPos);

					color = tex2Dlod(_AlbedoTex, float4(texPos * 0.2, 0, 0));

					// Break when the ray below the surface has intersected the geometry represented by the displacement map
					break;
				}

				// Raymarch by the step distance
				rayPos += stepDistance * rayDir;
			}
			// Set the Albedo color
			o.Albedo = color.rgb;
			o.Metallic = _Metallic;
		}
		ENDCG
	}
}
