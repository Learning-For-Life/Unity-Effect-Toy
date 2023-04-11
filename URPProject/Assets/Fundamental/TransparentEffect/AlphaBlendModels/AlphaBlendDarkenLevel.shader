Shader "Custom/AlphaEffect/AlphaBlendDarkenLevel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

    }
    SubShader
    {
        Tags
        {
            "IgnoreProject"="True""RenderType"="Transparent"
        }
        
        Pass
        {
            Cull Front
            Name"DepthOnly"
            Tags
            {
                "LightMode"="DepthOnly"
            }
            ZWrite On
            ColorMask 0
        }
        Pass
        {

            Name"AlphaBlend"
            Tags
            {
                "RenderType"="Universalforward"
            }
            Cull Back
            ZWrite Off
            BlendOp Min
            Blend One One
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            half4 _Color;
            struct a2v
            {
                float4 vertex:POSITION;

            };
            struct v2f
            {
                float4 pos:SV_POSITION;
            };
            v2f vert(a2v v)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {

                _Color = LinearToGamma22(_Color);
                return half4(_Color);
            }
            ENDHLSL
        }
    }

}