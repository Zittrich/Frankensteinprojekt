Shader "Unlit/10 - Final"
{
    Properties
    {
        [Header(General)]
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _GlobalOpacity ("Global Opacity", Range(0.0, 1.0)) = 1.0
        _ColorBlend ("Color Blend", Range(0.0, 1.0)) = 0.5

        [Header(Static Line)]
        _LineColor ("Color", Color) = (1,1,1,1)
        _LineDensity ("Density", Range(0, 10000)) = 10
        _LineStrength ("Opacity", Range(0.0, 1.0)) = 0.3
        _LineThickness ("Thickness", Range(0.0, 1.0)) = 0.5
        _LineHardness ("Hardness", Range(0.0, 1.0)) = 0.5

        [Header(Moving Line)]
        _MovingLineColor ("Color", Color) = (1,1,1,1)
        _MovingLineOpacity ("Opacity", Range(0.0, 1.0)) = 0.5
        _MovingLineSpeed ("Speed", Range(0.0, 10.0)) = 1.0
        _MovingLineDensity ("Density", Range(0.0, 10.0)) = 1.0
        _MovingLinePow ("Power", Range(0.0, 100.0)) = 1.0
        
        [Header(Outline)]
        _OutlineColor ("Color", Color) = (1,1,1,1)
        _OutlineStrength ("Outline Strength", Range(0.0, 100.0)) = 10.0
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
                float2 uv : TEXCOORD3;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };

            float4 _MainTex_ST;
            sampler2D _MainTex;

            float4 _BaseColor;
            float4 _OutlineColor;
            float4 _LineColor;
            float4 _MovingLineColor;
            int _LineDensity;
            float _LineStrength;
            float _MovingLineOpacity;
            float _GlobalOpacity;
            float _ColorBlend;

            float _MinOpacity;
            float _MaxOpacity;
            float _OutlineStrength;
            float _MovingLinePow;
            float _MovingLineSpeed;
            float _MovingLineDensity;
            float _LineThickness;
            float _LineHardness;


            v2f vert (vertexInput v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertexPos);
                o.pos = UnityObjectToClipPos(v.vertexPos);
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertexPos)).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Glowing outline = Jellyfish aus der Vorlesung
                float jellyfish = smoothstep(_MinOpacity, _MaxOpacity, 1 - (dot(i.normal, i.viewDir) * 0.5 + 0.5));

                //stehende Linien
                float lines1 = floor(frac(i.worldPos.y * _LineDensity) + _LineThickness) * _LineStrength;
                float lines2 = frac(i.worldPos.y * _LineDensity) * _LineStrength;
                float lines = lerp(lines1, lines2, _LineHardness);

                //bewegende Linien
                float movingLines = pow(frac((i.worldPos.y * _MovingLineDensity) - (_Time.y * _MovingLineSpeed)), _MovingLinePow) * _MovingLineOpacity;
                //movingLines = floor(movingLines + 0.1);

                //Zusammenführung
                float jellyLinesMove = jellyfish + lines + movingLines;
                jellyLinesMove = clamp(jellyLinesMove, 0.2, 1.0); //Variablen


                //Color
                fixed4 col = _BaseColor;
                col = lerp(col, _LineColor, lines);
                col = lerp(col, _MovingLineColor, movingLines);
                col = lerp(col, _OutlineColor, pow(jellyfish, _OutlineStrength));
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                fixed4 outputCol = lerp(col, mainCol, _ColorBlend);


                //Ausgabe
                return fixed4(outputCol.rgb, jellyLinesMove * _GlobalOpacity);
            }
            ENDCG
        }
    }
}
