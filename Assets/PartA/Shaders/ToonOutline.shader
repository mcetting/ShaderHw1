// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Toon/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ColorTint ("Tint Color", Color) = (0, 0, 0, 0)
		_RampTex ("Ramp Texture", 2D) = "white" {}
		_OutlineTint("Outline Tint", Color) = (0, 0, 0, 0)
		_OutlineExtrusion("Outline Depth", Range(0, 1)) = .1
		_Gloss("Gloss", Range(0, 100)) = 0
		_SpecularColor("Specular Color", Color) = (0.4,0.4,0.4,1)
    }
    SubShader
    {
        LOD 100

		// first pass lighting
        Pass
        {
			Tags{ "RenderMode" = "Opaque" "LightMode" = "ForwardBase" }

			// stencil for the outline pass
			Stencil
			{
				Ref 4
				Comp always
				Pass replace
				ZFail keep
			}
			// marks the stencil where this is placed and will cut the image out of the second pass
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc" // allows grabbing directional light color
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
				SHADOW_COORDS(2)
                float4 vertex : SV_POSITION;
				float4 pos : TEXCOORD3;
				float3 viewDirection : TEXCOORD1;
				float3 w_normal : NORMAL;
				float4 w_vertex : TEXCOORD4;
            };

            sampler2D _MainTex;
			sampler2D _RampTex;
            float4 _MainTex_ST;
			float4 _ColorTint;
			float _ShadowIntensity;
			float _Gloss;
			float4 _SpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDirection = WorldSpaceViewDir(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.w_normal = UnityObjectToWorldNormal(v.normal); // convert from object normal to world space normal

				// move the vertexs in shader space
				o.vertex.y = o.vertex.y * sin(_Time.x * 10);

				TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float shadow = SHADOW_ATTENUATION(i);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _ColorTint;

				// lighting calculations
				float3 norm = normalize(i.w_normal);
				float ndotl = clamp(dot(norm, normalize(_WorldSpaceLightPos0.xyz)), 0.0, 1.0);

				//float newShadow = tex2D(_RampTex, float2(shadow, 0)).rgb;
				float lightIntensity = tex2D(_RampTex, float2(ndotl * shadow, 0)).rgb;

				// specular calculation
				float3 viewDirection = normalize(i.viewDirection);
				float3 halfwayVector = normalize(_WorldSpaceLightPos0 + viewDirection);

				// getting the right look
				float ndoth = dot(halfwayVector, i.w_normal);
				float specularIntensity = pow(ndoth * lightIntensity, _Gloss * _Gloss);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity) * _SpecularColor;

				// check sampled ramp texture and multiply by the directional lights color
				float3 lighting = lightIntensity * _LightColor0 * col;
				
				// apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(lighting, 1) + specularIntensitySmooth;
            }
            ENDCG
        }
		Pass
        {
			Tags{ "RenderMode" = "Opaque" "LightMode" = "ForwardAdd" }
			Blend OneMinusDstColor One

			// stencil for the outline pass
			Stencil
			{
				Ref 4
				Comp always
				Pass replace
				ZFail keep
			}
			// marks the stencil where this is placed and will cut the image out of the second pass
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc" // allows grabbing directional light color
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
				SHADOW_COORDS(2)
                float4 vertex : SV_POSITION;
				float4 pos : TEXCOORD3;
				float3 viewDirection : TEXCOORD1;
				float3 w_normal : NORMAL;
            };

            sampler2D _MainTex;
			sampler2D _RampTex;
            float4 _MainTex_ST;
			float4 _ColorTint;
			float _ShadowIntensity;
			float _Gloss;
			float4 _SpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDirection = WorldSpaceViewDir(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.w_normal = UnityObjectToWorldNormal(v.normal); // convert from object normal to world space normal
				TRANSFER_SHADOW(o)

								// move the vertexs in shader space
				o.vertex.y = o.vertex.y * sin(_Time.x * 10);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float shadow = SHADOW_ATTENUATION(i);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _ColorTint;

				// lighting calculations
				float3 norm = normalize(i.w_normal);
				float ndotl = clamp(dot(norm, normalize(_WorldSpaceLightPos0.xyz)), 0.0, 1.0);

				float lightIntensity = tex2D(_RampTex, float2(ndotl, 0)).rgb * shadow;

				// specular calculation
				float3 viewDirection = normalize(i.viewDirection);
				float3 halfwayVector = normalize(_WorldSpaceLightPos0 + viewDirection);

				// getting the right look
				float ndoth = dot(halfwayVector, i.w_normal);
				float specularIntensity = pow(ndoth * lightIntensity, _Gloss * _Gloss);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity) * _SpecularColor;

				// check sampled ramp texture and multiply by the directional lights color
				float3 lighting = lightIntensity * _LightColor0 * col;
				
				// apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(lighting, 1) + specularIntensitySmooth;
            }
            ENDCG
        }
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
		// outline pass with normal extrusion
		Pass {
			Cull OFF
			ZWrite On
			ZTest On
			Stencil{
				Ref 4
				Comp notequal
				Fail keep
				Pass replace
			}
			CGPROGRAM
			// declaring the vert and frag funtions
			#pragma vertex vert
			#pragma fragment frag

			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _OutlineTint;
			float _OutlineExtrusion;

			v2f vert(appdata v)
			{
				v2f o;

				// extrude in normal directipn
				float3 normal = normalize(v.normal);
				v.vertex += float4(normal, 0.0) * _OutlineExtrusion;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
								// move the vertexs in shader space
				o.vertex.y = o.vertex.y * sin(_Time.x * 10);
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = _OutlineTint;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
    }
}
