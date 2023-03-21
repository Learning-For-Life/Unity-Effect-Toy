Shader "Custom/BasicLighting/Directionallit"
{
    Properties
    {
        _MainTex("MainTex",2D)="white"{}
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward""RenderType"="Transparent" 
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            half4 _Diffuse;
            half4 _Specular;
            float _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 positionWS :TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, In.vertex);
                Out.worldNormal = mul(In.normal, (float3x3)unity_WorldToObject);
                Out.positionWS = TransformObjectToWorld(In.vertex);
                Out.uv = TRANSFORM_TEX(In.uv, _MainTex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                half3 worldNormal = normalize(In.worldNormal);

                half3 worldLightDir = normalize(GetMainLight().direction);
                //
                float4 shadowCoord = TransformWorldToShadowCoord(In.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                //

                half3 diffuse = tex2D(_MainTex, In.uv) * _MainLightColor.rgb * _Diffuse.rgb * saturate(
                    dot(worldNormal, worldLightDir));

                half3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - In.worldNormal);

                half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);


                half3 color = (ambient + diffuse + specular) * mainLight.shadowAttenuation;

                return half4(color, 1.0);
            }
            ENDHLSL
        }
                Pass 
        {
            Name "ShadowCaster"
            Tags{ "LightMode" = "ShadowCaster" }
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ALPHATEST_ON
            // jave.lin : 根据你的 alpha test 是否开启而定
            //#pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert(a2v v)
            {
                v2f o = (v2f)0;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            real4 frag(v2f i) : SV_Target
            {
#if _ALPHATEST_ON
                half4 col = tex2D(_MainTex, i.uv);
                clip(col.a - 0.001);
#endif
                return 0;
            }
            ENDHLSL
        }

    }

}