Shader "Custom/ScrollingBackground"
{
    Properties
    {
        _DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
        _MainTex ("Image Sequence", 2D) = "white" {}
        _ScrollX ("Base layer Scroll Speed", Float) = 1.0
		_Scroll2X ("2nd layer Scroll Speed", Float) = 1.0
		_Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
        }
        Pass
        {
            Tags
            {
                "LightMode"="Universalforward"
            }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};
			

            v2f vert (a2v v) {
				v2f o;
				o.pos = GetVertexPositionInputs(v.vertex).positionCS;
				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
				////frac函数，返回小数部分， 如果1.1，返回0.1  如果2.4 返回0.4
				return o;
			}
			
			half4 frag (v2f i) : SV_Target {
				half4 firstLayer = tex2D(_MainTex, i.uv.xy);
				half4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				//把secondlayer里面透明的部分用firstlayer填充
				half4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				c.rgb *= _Multiplier;
				
				return c;
			}
            ENDHLSL
        }
    }
}