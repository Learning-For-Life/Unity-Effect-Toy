Shader "Custom/BasicTexture/MaskTextureLevel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _BumpMap("Normal Map",2D)="bump"{}
        _BumpScale("Bump Scale",Float)=1.0
        _SpecualrMask("Specualr Mask",2D)="white"{}
        _SpecularScale("Specualr Scale",Float)=1.0
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
            sampler2D _BumpMap;
            float _BumpScale;
            float4 _BumpMap_ST;
            sampler2D _SpecularMask;
            float _SpecularScale;

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
                float3 lightDir:TEXCOORD0;
                float3 viewDir:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            inline float3 ObjSpaceLightDir(in float4 v)
            {
                float3 objSpaceLightPos = mul(unity_WorldToObject, GetMainLight().direction.xyz).xyz;
                #ifndef USING_LIGHT_MULTI_COMPILE
                return objSpaceLightPos.xyz- v.xyz;
                #else
                #ifndef USING_DIRECTIONAL_LIGHT
        return objSpaceLightPos.xyz - v.xyz;
                #else
        return objSpaceLightPos.xyz;
                #endif
                #endif
            }

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos = mul(UNITY_MATRIX_MVP, In.vertex);
                // Out.worldNormal = mul(In.normal, (float3x3)unity_WorldToObject);
                // Out.worldPos = mul(unity_ObjectToWorld, In.vertex);
                Out.uv = TRANSFORM_TEX(In.texcoord, _MainTex);
                float3 binormal = cross(normalize(In.normal), normalize(In.tangent.xyz)) * In.tangent.w;
                float3x3 rotation = float3x3(In.tangent.xyz, binormal, In.normal);

                Out.lightDir = mul(rotation, ObjSpaceLightDir(In.vertex)).xyz;
                Out.viewDir = mul(rotation, ObjSpaceLightDir(In.vertex)).xyz;


                //Out.lightDir=mul(rotation,mul(unity_WorldToObject,GetMainLight().direction).xyz);
                ///Out.lightDir=mul()

                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 tangentLighDir = normalize(In.lightDir);
                
                half3 tangenViewDir = normalize(In.viewDir);
                
                half3 tangentNormal=UnpackNormal(tex2D(_BumpMap, In.uv));

                tangentNormal.xy *= _BumpScale;

                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //half3 worldLightDir = normalize(GetMainLight().direction);

                half3 albedo = tex2D(_MainTex, In.uv).rgb * _Color.rgb;

                half3 ambient = _GlossyEnvironmentColor.xyz * albedo;

                half3 diffuse = _MainLightColor.rgb * albedo.rgb * max(0,dot(tangentNormal, tangentLighDir));

                half3 halfDir = normalize(tangentLighDir + tangenViewDir);
                
                half specularMask=tex2D(_SpecularMask,In.uv).r*_SpecularScale;
                ///上边这句存疑，效果特别弱，是否应该是立方的值。
                half3 specular = _MainLightColor.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal, halfDir)), _Gloss)*specularMask;

                return half4(ambient+diffuse+ specular, 1.0);
            }
            ENDHLSL
        }
    }
}