Shader "Custom/BasicTexture/NormalMapWorldSpaceLevel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _BumpMap("Normal Map",2D)="bump"{}
        _BumpScale("Bump Scale",Float)=1.0
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
            half4 _Color;
            sampler2D _MainTex;
            float _Gloss;
            half4 _Specular;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            float4 _BumpMap_ST;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 TtoW0:TEXCOORD1;
                float4 TtoW1:TEXCOORD2;
                float4 TtoW2:TEXCOORD3;
            };

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, In.vertex);
                Out.uv.xy = TRANSFORM_TEX(In.texcoord, _MainTex);
                Out.uv.zw = TRANSFORM_TEX(In.texcoord, _BumpMap);

                half3 worldPos = mul(unity_ObjectToWorld, In.vertex).xyz;
                half3 worldNormal = normalize(mul((float3x3)unity_WorldToObject, In.normal.xyz));
                half3 worldTangent = normalize(mul((float3x3)unity_WorldToObject, In.tangent.xyz));
                half3 worldBinormal = cross(worldNormal, worldTangent) * In.tangent.w;


                Out.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                Out.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                Out.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);


                //Out.lightDir=mul(rotation,mul(unity_WorldToObject,GetMainLight().direction).xyz);
                ///Out.lightDir=mul()

                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                float3 worldPos = float3(In.TtoW0.w, In.TtoW1.w, In.TtoW2.w);
                half3 lightDir = normalize(GetMainLight().direction - worldPos);
                half3 viewdir = normalize(GetCameraPositionWS().xyz - worldPos);

                half3 bump = UnpackNormal(tex2D(_BumpMap, In.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
                bump = normalize(half3(dot(In.TtoW0.xyz, bump), dot(In.TtoW1.xyz, bump), dot(In.TtoW2.xyz, bump)));
                //half3 worldLightDir = normalize(GetMainLight().direction);

                half3 albedo = tex2D(_MainTex, In.uv).rgb * _Color.rgb;

                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                half3 diffuse = _MainLightColor.rgb * albedo.rgb * (saturate(dot(bump, lightDir)) * 0.5 +
                    0.5);


                half3 halfDir = normalize(lightDir + viewdir);

                half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);


                return half4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }
}