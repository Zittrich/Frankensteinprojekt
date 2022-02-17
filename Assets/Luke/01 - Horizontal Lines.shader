Shader "Custom/01 - Horizontal Lines"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _LineColor ("Line Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {

        CGPROGRAM
       
        #pragma vertex vert
        #pragma fragment frag

        float4 _BaseColor;
        float4 _LineColor;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 color : TEXCOORD0;
        };

        v2f vert(float4 vertexPos : POSITION)
        {
            v2f output;
            output.pos = UnityObjectToClipPos(vertexPos);
            output.color = (vertexPos.y < 0) ? _LineColor : _BaseColor;
            return output;
        }

        float4 frag(v2f input) : COLOR
        {
            return input.color;
        }

        ENDCG

        }
    }
    FallBack "Diffuse"
}
