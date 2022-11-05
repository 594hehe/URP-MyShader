Shader "PlaneCloud"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
		_CloudEdgeNoise("CloudEdgeNoise", 2D) = "white" { }
		_Edgespeed("Edgespeed",range(0.0,0.05))=0.025
		[Toggle] _IsPlane ("Plane", int) = 0
        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
		_ShadowColor ("ShadowColor", Color) = (1, 1, 1, 1)
		_ShadowColor2 ("ShadowColor2", Color) = (1, 1, 1, 1)
		_rimColor ("RimColor", Color) = (1, 1, 1, 1)
		_sdf("sdf",range(0.01,1))=0.01
    }
    SubShader
    {
        Tags { "RenderType" = "Background" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "ShaderModel" = "4.5""Queue" = "Transparent" }
        LOD 100

        ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		cull back

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			
			TEXTURE2D(_CloudEdgeNoise);            SAMPLER(sampler_CloudEdgeNoise);
            

            CBUFFER_START(UnityPerMaterial)
			int _IsPlane;
            float4 _BaseMap_ST;
            float4 _BaseMap_HDR;
			float4 _CloudEdgeNoise_ST;
            float4 _BaseColor;
			float4 _ShadowColor;
			float4 _ShadowColor2;
			float4 _rimColor;
			float _sdf;
			float _Edgespeed;
			
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                #if UNITY_REVERSED_Z //这个宏是用来判断平台的，有个平台最远裁剪值是1，有的是-1
                    o.positionCS.z = o.positionCS.w * 0.000001f;
                #else
                    o.positionCS.z = o.positionCS.w * 0.9999f;
                #endif  
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
               
				float2 time=float2(0,_Time.y*_Edgespeed);
				float4 cloudEdgeNoise = SAMPLE_TEXTURE2D(_CloudEdgeNoise,sampler_CloudEdgeNoise,i.uv.xy*5*_CloudEdgeNoise_ST.xy + _CloudEdgeNoise_ST.zw + time*_CloudEdgeNoise_ST.xy);
				float2 cloudNoiseUV = i.uv.xy + float2(cloudEdgeNoise.x-1,cloudEdgeNoise.y-0.25)*0.02;
				
				
				half4 col=SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,cloudNoiseUV);
                col.rgb = DecodeHDREnvironment(col, _BaseMap_HDR) * _BaseColor.rgb;
				half4 colsdf;
				colsdf=step(_sdf,col.b);
				{
					if (_IsPlane == 0.0)
				    col.rgb=_ShadowColor*(1-col.r)+_BaseColor*+col.r+_rimColor*col.g;
			        
			
			        else
			        col.rgb=_BaseColor.rgb;
				
			}
			    //col.a=colsdf;
                return col;
				//return cloudEdgeNoise;
            }
            ENDHLSL

        }
    }
}
