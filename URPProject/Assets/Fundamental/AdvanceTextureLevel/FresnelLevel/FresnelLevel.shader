Shader "Custom/AdvanceTexture/FresnelLevel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelScale("Fresnel Scale",Range(0,1))=0.5
        _Cubemap("Reflection Cubemap",Cube)="_Skybox"{}
    }
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            half4 _Color;
            samplerCUBE _Cubemap;
            half _FresnelScale;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                half3 worldViewDir : TEXCOORD2;
                half3 worldRefl : TEXCOORD3;
            };

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, In.vertex);
                Out.worldNormal = mul(In.normal, (float3x3)unity_WorldToObject);
                Out.worldPos = mul(unity_ObjectToWorld, In.vertex);
                Out.worldViewDir = GetCameraPositionWS() - In.vertex;

                // Compute the reflect dir in world space
                Out.worldRefl = reflect(-Out.worldViewDir,Out.worldNormal);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 worldNormal = normalize(In.worldNormal);
                half3 worldLightDir = normalize(GetMainLight().direction.xyz - In.worldPos);
                half3 worldViewDir = normalize(In.worldViewDir);

                half3 ambient = _GlossyEnvironmentColor.rgb;

                half3 diffuse = GetMainLight().color.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

                // Use the reflect dir in world space to access the cubemap
                half3 reflection = texCUBE(_Cubemap, In.worldRefl).rgb;

                float4 shadowCoord = TransformWorldToShadowCoord(In.worldPos);

                half fresnel=_FresnelScale+(1-_FresnelScale)*pow(1-dot(worldViewDir,worldNormal),5);
                // Mix the diffuse color with the reflected color
                half3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * GetMainLight(shadowCoord).
                    shadowAttenuation;

                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}