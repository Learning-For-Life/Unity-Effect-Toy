Shader "Custom/BasicLighting/DiffuseFragmaHLSLLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            half4 _Diffuse;
            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 NormalFrag:TEXCOORD;
            };

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos =  mul(UNITY_MATRIX_MVP, In.vertex);
                Out.NormalFrag=In.normal;
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 diffuse=_Diffuse*LightingLambert(GetMainLight().color,GetMainLight().direction,In.NormalFrag);
                return half4(diffuse, 1.0);
            }
            ENDHLSL
        }
    }

}