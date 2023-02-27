Shader "Custom/BasicLighting/SpecularFragmaLevel"
{
    Properties
    {
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
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            half4 _Diffuse;
            half4 _Specular;
            float _Gloss;
            
            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
            };

            v2f vert(a2v In)
            {
                v2f Out;
                Out.pos =  mul(UNITY_MATRIX_MVP, In.vertex);
                Out.worldNormal = mul(In.normal, (float3x3)unity_WorldToObject);
                return Out;
            }

            half4 frag(v2f In):SV_Target
            {
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                half3 worldNormal = normalize(In.worldNormal);

                half3 worldLightDir = normalize(GetMainLight().direction);

                half3 diffuse = _MainLightColor.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                half3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));

                half3 viewDir=normalize(_WorldSpaceCameraPos.xyz-In.worldNormal);

                half3 specular=_MainLightColor.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                half3 color = ambient + diffuse+specular;

                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }

}