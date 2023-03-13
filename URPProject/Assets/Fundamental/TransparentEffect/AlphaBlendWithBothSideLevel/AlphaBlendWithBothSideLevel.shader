Shader "Custom/AlphaBlendWithBothSideLevel"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _AlphaScale("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent""IgnoreProject"="True""RenderType"="Transparent"
        }
         Pass
        {

            Name"Universal2D"
            Tags
            {
                "LightMode" = "Universalforward"
            }
            Cull Front
            Zwrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            sampler2D _MainTex;
            half4 _Color;
            float4 _MainTex_ST;
            half _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            
            v2f vert(a2v v)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                Out.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                Out.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                Out.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 worldNormal = normalize(In.worldNormal);
                half4 texcolor = tex2D(_MainTex, In.uv);
                half3 lambert = LightingLambert(GetMainLight().color, GetMainLight().direction, worldNormal);
                half3 albedo = texcolor.rgb * _Color.rgb;
                half3 ambient = _GlossyEnvironmentColor.rgb * albedo;
                half3 diffuse = albedo * lambert;
                return half4(diffuse + ambient, texcolor.a * _AlphaScale);
            }
            ENDHLSL
        }
         Pass
        {

            Name"AlphaBlend"
            Tags
            {
                "LightMode" = "UniversalForwardOnly"
            }
            Cull Back
            Zwrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            sampler2D _MainTex;
            half4 _Color;
            float4 _MainTex_ST;
            half _AlphaScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            
            v2f vert(a2v v)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                Out.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                Out.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                Out.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 worldNormal = normalize(In.worldNormal);
                half4 texcolor = tex2D(_MainTex, In.uv);
                half3 lambert = LightingLambert(GetMainLight().color, GetMainLight().direction, worldNormal);
                half3 albedo = texcolor.rgb * _Color.rgb;
                half3 ambient = _GlossyEnvironmentColor.rgb * albedo;
                half3 diffuse = albedo * lambert;
                return half4(diffuse + ambient, texcolor.a * _AlphaScale);
            }
            ENDHLSL
        }
    }

}