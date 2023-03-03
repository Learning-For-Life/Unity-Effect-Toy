Shader "Custom/BasicTexture/RampTextureLevel"
{
    Properties
    {
        _Color ("ColorTint", Color) = (1,1,1,1)
        _RampTex ("RampTex", 2D) = "white" {}
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
            sampler2D _RampTex;
            float _Gloss;
            half4 _Specular;
            float4 _RampTex_ST;

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
                Out.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, In.normal));
                Out.worldPos = mul(unity_ObjectToWorld, In.vertex).xyz;
                Out.uv = TRANSFORM_TEX(In.texcoord, _RampTex);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 worldNormal = normalize(In.worldNormal);

                half3 worldLightDir = normalize(GetMainLight().direction);

                half3 ambient = _GlossyEnvironmentColor;

                half halflambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                half3 diffusecolor = tex2D(_RampTex, float2(min(halflambert,1), min(halflambert,1))).rgb * _Color.rgb;
                half3 diffuse = GetMainLight().color * diffusecolor;

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - In.worldPos);

                half3 halfDir = normalize(worldLightDir + viewDir);

                half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)), _Gloss);


                return half4(ambient+diffuse+specular , 1.0);
            }
            ENDHLSL
        }
    }
}