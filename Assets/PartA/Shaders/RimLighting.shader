Shader "Unlit/RimLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorTint("Color Tint", Color) = (1, 1, 1, 1)
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Power", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorTint;
            float4 _RimColor;
            float _RimPower;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.viewDir = ObjSpaceViewDir(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                				// move the vertexs in shader space
				o.vertex.y = o.vertex.y * sin(_Time.x * 10);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half rim = 1.0 - saturate(dot (normalize(i.viewDir), i.normal));
                float3 rimValue = _RimColor.rgb * pow (rim, _RimPower);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(rimValue, 1);
            }
            ENDCG
        }
    }
}
