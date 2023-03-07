Shader "Custom/AlphaTestLevel"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "IgnoreProject"="True""RenderType"="Universalforward"
        }
        Pass
        {

           Tags{"RenderType"="TransparentCutout"}
            HLSLPROGRAM
            
            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            sampler2D _MainTex;
            half4 _Color;
            float4 _MainTex_ST;
            half _Cutoff;

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

            inline float3 UnityObjectToWorldNormal(in float3 norm)
            {
                #ifdef UNITY_ASSUME_UNIFORM_SCALING
                return UnityObjectToWorldDir(norm);
                #else
                // mul(IT_M, norm) => mul(norm, I_M) => {dot(norm, I_M.col0), dot(norm, I_M.col1), dot(norm, I_M.col2)}
                return normalize(mul(norm, (float3x3)unity_WorldToObject));
                #endif
            }

            inline float3 UnityWorldSpaceLightDir(in float3 worldPos)
            {
                #ifndef USING_LIGHT_MULTI_COMPILE
                return GetMainLight().direction.xyz;
                #else
                #ifndef USING_DIRECTIONAL_LIGHT
                return GetMainLight().direction.xyz - worldPos;
                #else
                return GetMainLight().direction.xyz;
                #endif
                #endif
            }

            v2f vert(a2v v)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                Out.worldNormal = UnityObjectToWorldNormal(v.normal);
                Out.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                Out.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 worldNormal = normalize(In.worldNormal);
                half4 texcolor = tex2D(_MainTex, In.uv);
                clip(texcolor.a - _Cutoff);
                half3 lambert= LightingLambert(GetMainLight().color,GetMainLight().direction,worldNormal);
                half3 albedo = texcolor.rgb * _Color.rgb;
                half3 ambient = _GlossyEnvironmentColor.rgb*albedo;
                half3 diffuse =  albedo * lambert;
                return half4(diffuse+ambient , 1.0);
            }
            ENDHLSL
        }
    }

}