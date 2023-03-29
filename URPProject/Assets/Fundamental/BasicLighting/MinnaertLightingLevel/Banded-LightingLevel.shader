Shader "Custom/BasicLighting/Banded-LightingLevel"
{
    Properties
    {
        _MainTex("Main Tex",2D)="white" {}
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _LightSteps("Light Step",float)=1
        _layers("_layers",float)=1
        
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
            float _LightSteps;
            float _layers;
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
                float2 uv:TEXCOORD1;
            };

            v2f vert(a2v In)
            {
                v2f Out;
                Out.uv=TRANSFORM_TEX(In.uv,_MainTex);
                Out.pos =  mul(UNITY_MATRIX_MVP, In.vertex);
                Out.worldNormal = mul(In.normal, (float3x3)unity_WorldToObject);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 ambient = _GlossyEnvironmentColor;

                half3 worldNormal = normalize(In.worldNormal);

                half3 worldLightDir = normalize(GetMainLight().direction);

                float Ndotl = max(0.0,dot(worldNormal, worldLightDir));

                float lightBandsMultiplier=_LightSteps/256;

                float lightBandsAdditive=_LightSteps/2;

                float bandedNdotl=(floor((Ndotl*256+lightBandsAdditive)*_layers/_LightSteps))*lightBandsMultiplier;
                
float4 tex=tex2D(_MainTex,In.uv);
                
                float3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * bandedNdotl*tex;

                float3 color = diffuse+ambient;//ambient + diffuse;

                return float4(color, 1.0);
            }
            ENDHLSL
        }
    }

}