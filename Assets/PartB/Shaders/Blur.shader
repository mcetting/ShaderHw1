Shader "Unlit/Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Steps ("Steps", Float) = 3
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            uniform float4 _MainTex_TexelSize; //special value
            uniform float _Steps;
            
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 texel = float2(
                    _MainTex_TexelSize.x, 
                    _MainTex_TexelSize.y 
                );
        
                float3 avg = 0.0;
                int steps = ((int)_Steps) * 2 + 1;
                if (steps < 0) {
                    avg = tex2D( _MainTex, i.uv).rgb;
                }else {
                    int x, y;
                    for ( x = -steps/2; x <=steps/2 ; x++) {
                        for (int y = -steps/2; y <= steps/2; y++) {
                            avg += tex2D( _MainTex, i.uv + texel * float2( x, y ) ).rgb;
                        }
                    }
                    avg /= steps * steps;
                }             
        
                return float4(avg, 1.0); 
            }
            ENDCG
        }
    }
}
