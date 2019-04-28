// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "A/DiffuseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorTint("Color Tint", Color) = (1, 1, 1, 1)
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss("Gloss Value", float) = 0
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            // need light direction and color
            // need normals

            // for specular maybe a gloss value
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 w_normal : NORMAL;
                float3 viewDirection : TEXCOORD1;
                float4 w_vertex : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorTint;
            float4 _SpecularColor;
            float _Gloss;

            // note hlsl requires function prototyping or proper syntx
            // generates diffuse lighting from the directional light
            float4 DiffuseLighting(v2f i, float ndotl){
                float4 lighting = ndotl * _LightColor0 * _ColorTint;
                return lighting;
            }

            // handles specular lighting using blinn phong model with
            // a halfway vector
            float4 SpecularLighting(v2f i){
                float3 V = normalize(_WorldSpaceCameraPos     - i.w_vertex);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - i.w_vertex);
                float3 H = normalize(L + V);
                float4 specular = pow(max(dot(i.w_normal, H), 0), _Gloss) * _SpecularColor * _LightColor0;
                return specular;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.w_normal = UnityObjectToWorldNormal(v.normal);
                o.viewDirection = WorldSpaceViewDir(v.vertex);
                o.w_vertex = mul(unity_ObjectToWorld, o.vertex);
                				// move the vertexs in shader space
				o.vertex.y = o.vertex.y * sin(_Time.x * 10);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // normalize the normal and viewdirection
                normalize(i.w_normal);
     
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // ndotl
                float ndotl = max(dot(i.w_normal, _WorldSpaceLightPos0), 0);

                float4 d = DiffuseLighting(i, ndotl);
                float4 s = SpecularLighting(i);
                float4 a = float4(UNITY_LIGHTMODEL_AMBIENT.rgb, 1);

                if(ndotl <= 0) s = 0;

                return col * (d + s + a);
            }
            ENDCG
        }
    }
}
