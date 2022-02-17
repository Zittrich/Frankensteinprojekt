Shader "Unlit/03 - HologramLines"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Lines ("Lines", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Bloom ("Bloom Effect", Range(1.0, 10.0)) = 5.0
        _MinOpacity ("Min Opacity", Range(0.0, 1.0)) = 0.0
        _MaxOpacity ("Max Opacity", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertexPos : POSITION;
                float3 normal : NORMAL;
                //float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                //float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            float4 _MainTex_ST;
            float4 _BaseColor;
            float _Bloom;
            float _MinOpacity;
            float _MaxOpacity;


            v2f vert (vertexInput v)
            {
                v2f o;
                //o.uv = v.uv;
                o.pos = UnityObjectToClipPos(v.vertexPos);
                o.normal = v.normal;
                //normalize(mul(float4(v.normal, 0.0), unity_WorldToObject)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertexPos)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float jellyfish = min(1.0, _BaseColor.a / abs(dot(i.viewDir, i.normal)));
                float jellyfish = smoothstep(_MinOpacity, _MaxOpacity, 1 - (dot(i.normal, i.viewDir) * 0.5 + 0.5));
                //float lines = i.uv.y * 10;
                //_LineDensity statt 2
                float jellyLines = frac(i.pos.y * 10 + _Time.y * 1) * jellyfish;
                //frac(lines);
                // sample the texture
                /*float4 col = tex2D(_MainTex , i.uv);
                col *= _BaseColor;*/
                fixed4 col = _BaseColor;
                return fixed4(col.rgb, jellyfish);
            }
            ENDCG
        }
    }
}
