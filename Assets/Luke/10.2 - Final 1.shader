Shader "Unlit/10.2 - Final 1"
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
        _LineOpacity ("Opacity", Range(0.0, 1.0)) = 0.3
        _LineThickness ("Thickness", Range(0.0, 1.0)) = 0.5
        _LineHardness ("Hardness", Range(0.0, 1.0)) = 0.5

        [Header(Moving Line)]
        _MovingLineColor ("Color", Color) = (1,1,1,1)
        _MovingLineOpacity ("Opacity", Range(0.0, 1.0)) = 0.5
        _MovingLineSpeed ("Speed", Range(0.0, 10.0)) = 1.0
        _MovingLineDensity ("Density", Range(0.0, 10.0)) = 1.0
        _MovingLinePow ("Power", Range(0.0, 100.0)) = 1.0
        _MovingLineHardness ("Hardness", Range(0.0, 1.0)) = 0.0
        
        [Header(Outline)]
        _OutlineColor ("Color", Color) = (1,1,1,1)
        _OutlineStrength ("Power", Range(0.0, 100.0)) = 10.0
        _OutlineMinOpacity ("Min Opacity", Range(0.0, 1.0)) = 0.2
        _OutlineMaxOpacity ("Max Opacity", Range(0.0, 1.0)) = 1.0
        _OutlineMinStrength ("Min Strength", Range(0.0, 1.0)) = 0.3
        _OutlineMaxStrength ("Max Strength", Range(0.0, 1.0)) = 0.5
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
                float4 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            //General
            float4 _MainTex_ST;
            sampler2D _MainTex;
            float4 _BaseColor;
            float _GlobalOpacity;
            float _ColorBlend;
            float _OutlineMinOpacity;
            float _OutlineMaxOpacity;

            //Static Line
            float4 _LineColor;
            int _LineDensity;
            float _LineOpacity;
            float _LineThickness;
            float _LineHardness;
            
            //Moving Line
            float4 _MovingLineColor;
            float _MovingLineOpacity;
            float _MovingLineSpeed;
            float _MovingLineDensity;
            float _MovingLinePow;
            float _MovingLineHardness;

            //Outline
            float4 _OutlineColor;
            float _OutlineStrength;
            float _OutlineMinStrength;
            float _OutlineMaxStrength;


            v2f vert (vertexInput v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertexPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertexPos);
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertexPos)).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Glowing outline = Jellyfish aus der Vorlesung
                float jellyfish = smoothstep(_OutlineMinStrength, _OutlineMaxStrength, 1 - (dot(i.normal, i.viewDir) * 0.5 + 0.5));

                //stehende Linien
                float lines1 = floor(frac(i.worldPos.y * _LineDensity) + _LineThickness);
                float lines2 = frac(i.worldPos.y * _LineDensity);
                float lines = lerp(lines2, lines1, _LineHardness) * _LineOpacity;

                //bewegende Linien
                float movingLines1 = floor(pow(frac((i.worldPos.y * _MovingLineDensity) - (_Time.y * _MovingLineSpeed)), _MovingLinePow) + 0.5);
                float movingLines2 = pow(frac((i.worldPos.y * _MovingLineDensity) - (_Time.y * _MovingLineSpeed)), _MovingLinePow);
                float movingLines = lerp(movingLines2, movingLines1, _MovingLineHardness) * _MovingLineOpacity;

                //Zusammenführung
                float jellyLinesMove = jellyfish + lines + movingLines;
                jellyLinesMove = clamp(jellyLinesMove, _OutlineMinOpacity, _OutlineMaxOpacity);


                //Color
                fixed4 col = _BaseColor;
                col = lerp(col, _LineColor, lines);
                fixed4 mainCol = tex2D(_MainTex, i.uv);
                fixed4 outCol = lerp(col, mainCol * col, _ColorBlend);
                outCol = lerp(outCol, _MovingLineColor, movingLines);
                outCol = lerp(outCol, _OutlineColor, pow(jellyfish, _OutlineStrength));


                //Ausgabe
                return fixed4(outCol.rgb, jellyLinesMove * _GlobalOpacity);
            }
            ENDCG
        }
    }
}
