Shader "Custom/BasicTexture/SingleTextureLevel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="UniversalForward"
            }


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            half4 _Color;
            sampler2D _MainTex;
            float _Gloss;
            half4 _Specular;
            float4 _MainTex_ST;

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

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, In.vertex);
                Out.worldNormal = mul(In.normal, (float3x3)unity_WorldToObject);
                Out.worldPos = mul(unity_ObjectToWorld, In.vertex);
                Out.uv = TRANSFORM_TEX(In.texcoord, _MainTex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 worldNormal = normalize(In.worldNormal);

                half3 worldLightDir = normalize(GetMainLight().direction);

                half3 albedo = tex2D(_MainTex, In.uv).rgb * _Color.rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = _MainLightColor.rgb * albedo.rgb * (saturate(dot(worldNormal, worldLightDir)) * 0.5 +
                    0.5);

                half3 viewDir = normalize(GetCameraPositionWS());

                half3 halfDir = normalize(worldLightDir + viewDir);

                half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                

                return half4(ambient+specular+diffuse, 1.0);
            }
            ENDHLSL
        }
    }
}