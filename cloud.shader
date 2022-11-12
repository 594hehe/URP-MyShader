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
		_sdf("sdf",range(0,0.2))=0.15
		_LerpCtrl("生成速度",range(0.0,1))=1
		_cloudspeed("旋转速度",range(0.0,0.005))=0
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
			float _cloudspeed;
			float _LerpCtrl;
			
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertexColor : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
                float4 positionCS : SV_POSITION;
				float4 vertexColor : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
				float angle=_Time.z*_cloudspeed;
				//下面就是运用到旋转矩阵
				float xx=v.vertex.x*cos(angle)+sin(angle)*v.vertex.y;
				float zz=-v.vertex.x*sin(angle)+cos(angle)*v.vertex.y;
				//将值赋给顶点的x与z的数值
				v.vertex.x=xx;
				v.vertex.y=zz;
				//这句代码的意思是将物体坐标系转到相机坐标系，其实就是MVP
				

                o.positionCS = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
				o.uv1 = TRANSFORM_TEX(v.uv1, _BaseMap);
				o.vertexColor = v.vertexColor; 
                #if UNITY_REVERSED_Z //这个宏是用来判断平台的，有个平台最远裁剪值是1，有的是-1
                    o.positionCS.z = o.positionCS.w * 0.000001f;
                #else
                    o.positionCS.z = o.positionCS.w * 0.9999f;
                #endif  
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
               
				float2 time3=float2(0,_Time.y*_Edgespeed);
				float4 cloudEdgeNoise = SAMPLE_TEXTURE2D(_CloudEdgeNoise,sampler_CloudEdgeNoise,i.uv.xy*2*_CloudEdgeNoise_ST.xy + _CloudEdgeNoise_ST.zw + time3*_CloudEdgeNoise_ST.xy);
				float2 cloudNoiseUV = i.uv.xy + float2(cloudEdgeNoise.x,cloudEdgeNoise.y)*0.02;
				
				
				half4 col=SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,cloudNoiseUV);
                col.rgb = DecodeHDREnvironment(col, _BaseMap_HDR) * _BaseColor.rgb;
				
				float lerptime=(abs(clamp(sin(_Time.x),-1,1))*_LerpCtrl);
				float verColor=abs(lerptime-i.vertexColor.r);
				
				half cloudStep =1-verColor;
				half a1 = clamp(smoothstep(saturate(cloudStep-0.1),cloudStep,col.b),0,col.a);  
				//控制云的消失
				col.a=col.a*smoothstep(0,_sdf,i.uv1.y-0.01);
				{
					if (_IsPlane == 0.0)
				    {
						col.rgb=_ShadowColor*(1-col.r)+_BaseColor*col.r+_rimColor*col.g*0;//颜色叠加方式
			            col.a=a1*col.a;
					}
			
			        else 
			        {
						col.rgb=_BaseColor.rgb;
						col.a=col.a;
					}
				   
				
			    }
			    
				
                return col;
			
            }
            ENDHLSL

        }
    }
}
