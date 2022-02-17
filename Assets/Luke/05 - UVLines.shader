Shader "Unlit/05 - UVLines"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Lines ("Lines", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        //_LineDensity ("Line Density", Range(0, 1000)) = 10
        //_LineStrength ("Line Strength", Range(0.0, 5.0)) = 1.0
        _JellyStrength ("Jelly Strength", Range(0.0, 10.0)) = 1.0
        _GlobalOpacity ("Global Opacity", Range(0.0, 1.0)) = 1.0
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            float4 _MainTex_ST;
            float4 _BaseColor;
            sampler2D _Lines;
            float4 _Lines_ST;
            //int _LineDensity;
            //float _LineStrength;
            float _JellyStrength;
            float _GlobalOpacity;

            v2f vert (vertexInput v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _Lines);
                o.pos = UnityObjectToClipPos(v.vertexPos);
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertexPos)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float jellyfish = min(1.0, _BaseColor.a / abs(dot(i.viewDir, i.normal))) * _JellyStrength;
                fixed4 lines = tex2D(_Lines, i.uv);

                fixed4 col = _BaseColor;
                return fixed4(lines);
            }
            ENDCG
        }
    }
}
