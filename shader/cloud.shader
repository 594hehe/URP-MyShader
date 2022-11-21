Shader "Custom/Cloud"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _Edgespeed("Edgespeed",range(0.0,0.05))=0.025

        _CloudEdgeNoise("CloudEdgeNoise", 2D) = "white" { }
		
        [HDR]_BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
		[HDR]_ShadowColor ("ShadowColor", Color) = (1, 1, 1, 1)
		[HDR]_ShadowColor2 ("ShadowColor2", Color) = (1, 1, 1, 1)
		[HDR]_rimColor ("RimColor", Color) = (1, 1, 1, 1)
        [Toggle] _IsPlane ("Plane", int) = 0
        _sdf("底部渐隐",range(0,0.2))=0.15
		_LerpCtrl("生成速度",range(0.0,1))=1
		_cloudspeed("旋转速度",range(0.0,0.005))=0

        _sunlightColor ("太阳光颜色", Color) = (1, 1, 1, 1)
		//_SunCol1 ("Sun Colour1", Color) = (1, 1, 1, 1)
        _SunDirectionWS("Sun DirectionWS", Vector) = (1, 1, 1, 1)

        _MoonCol ("月光颜色", Color) = (1, 1, 1, 1)
      
		_MoonScatteringIntensity("Moon Scattering Intensity", Range(0, 3)) = 0.5
        _MoonDirectionWS("Moon DirectionWS", Vector) = (1, 1, 1, 1)


    }
    SubShader
    {
        Tags { "RenderType" = "Background" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "ShaderModel" = "4.5""Queue" = "Transparent" }
        LOD 100

        ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		cull back

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
        TEXTURE2D(_CloudEdgeNoise);            SAMPLER(sampler_CloudEdgeNoise);
        CBUFFER_START(UnityPerMaterial)
        int _IsPlane;
        float4 _BaseMap_ST;
        float4 _BaseColor;
        float4 _CloudEdgeNoise_ST;
		float4 _ShadowColor;
		float4 _ShadowColor2;
		float4 _rimColor;
        float _sdf;
		float _Edgespeed;
		float _cloudspeed;
		float _LerpCtrl;
    
        float4 _sunlightColor;
		
        float4 _SunDirectionWS;
        float4 _MoonDirectionWS;
        float _SunSize;
        
        float _ScatteringIntensity;
		float _MoonScatteringIntensity;

        float4x4 _MoonWorld2Obj;
        float4 _MoonCol;
        
        
        

        CBUFFER_END
        ENDHLSL

        Pass
        {
            Name "Skybox"
            //Tags { "LightMode"="UniversalForward" }
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #define PI 3.1415926535
            #define MIE_G (-0.990)
            #define MIE_G2 0.9801
            static const float PI2 = PI * 2;
            static const float halfPI = PI * 0.5;


            struct a2v
            {
                float4 positionOS: POSITION;
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD5;
				float4 vertexColor : COLOR;
            };
            
            struct v2f
            {
                float4 positionCS: SV_POSITION;
                float3 positionWS: TEXCOORD1;
                float3 moonPos: TEXCOORD2;
                float3 positionOS: TEXCOORD3;
                float3 milkyWayPos: TEXCOORD4;
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD5;
                
				float4 vertexColor : COLOR;
				
            };
            
            



            v2f vert(a2v v)
            {
                v2f o;

                float angle=-(_Time.z*_cloudspeed);
				//下面就是运用到旋转矩阵
				float xx=v.positionOS.x*cos(angle)+sin(angle)*v.positionOS.z;
				float zz=-v.positionOS.x*sin(angle)+cos(angle)*v.positionOS.z;
				//将值赋给顶点的x与z的数值
				v.positionOS.x=xx;
				v.positionOS.z=zz;

                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
				o.uv1 = TRANSFORM_TEX(v.uv1, _BaseMap);
                o.vertexColor = v.vertexColor; 

                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = positionInputs.positionCS;
                o.positionWS = positionInputs.positionWS;
                o.positionOS = v.positionOS.xyz;

                o.moonPos = mul((float3x3)_MoonWorld2Obj, v.positionOS.xyz) * 6;
                o.moonPos.x *= -1;

                #if UNITY_REVERSED_Z //这个宏是用来判断平台的，有个平台最远裁剪值是1，有的是-1
                    o.positionCS.z = o.positionCS.w * 0.000001f;
                #else
                    o.positionCS.z = o.positionCS.w * 0.9999f;
                #endif  

               

                return o;
            }
            

            // Calculates the Mie phase function
            half getMiePhase(half eyeCos, half eyeCos2)
            {
                half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
                temp = pow(temp, pow(_SunSize, 0.65) * 10);
                temp = max(temp, 1.0e-4); // prevent division by zero, esp. in half precision
                temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;

                return temp;
            }

            // Calculates the sun shape
            half calcSunAttenuation(half3 lightPos, half3 ray)
            {
                // half3 delta = lightPos - ray;
                // half dist = length(delta);
                // half spot = 1.0 - smoothstep(0.0, _SunSize, dist);
                // return spot * spot;

                half focusedEyeCos = pow(saturate(dot(lightPos, ray)), 5);
                return getMiePhase(-focusedEyeCos, focusedEyeCos * focusedEyeCos);
            }

            inline float2 VoronoiRandomVector(float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)) * 46839.32);
                return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
            }

            void VoronoiNoise(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);

                for(int y=-1; y<=1; y++)
                {
                    for(int x=-1; x<=1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = VoronoiRandomVector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if(d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            float softLight( float s, float d )
            {
                return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d) 
                        : (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0) 
                                    : d + (2.0 * s - 1.0) * (sqrt(d) - d);
            }

            float3 softLight(float3 s, float3 d)
            {
                return float3(softLight(s.x, d.x), softLight(s.y, d.y), softLight(s.z, d.z));
            }



            half4 frag(v2f i): SV_Target
            {
                float3 normalizePosWS = normalize(i.positionOS);
                float2 sphereUV = float2(atan2(normalizePosWS.x, normalizePosWS.z) / PI2, asin(normalizePosWS.y) / halfPI);

                
                //自定义的一个类似大范围bloom的散射
                half4 scattering = smoothstep(0.5, 1.5, dot(normalizePosWS, -_SunDirectionWS.xyz)) ;
				half scatteringIntensity = max(1, smoothstep(0.6, 0.0, -_SunDirectionWS.y));
                scattering *= scatteringIntensity;
				 
                //刚日出时散射强度大
                

                

                //日出颜色与白天颜色插值
                

				//月亮的散射
				half4 moonScattering = smoothstep(_MoonScatteringIntensity, 1.5, dot(normalizePosWS, -_MoonDirectionWS.xyz));
				half moonscatteringIntensity = max(3, smoothstep(0.6, 0.0, -_MoonDirectionWS.y));
                moonScattering *= moonscatteringIntensity;

                float2 time3=float2(0,_Time.y*_Edgespeed);
				float4 cloudEdgeNoise = SAMPLE_TEXTURE2D(_CloudEdgeNoise,sampler_CloudEdgeNoise,i.uv.xy*2*_CloudEdgeNoise_ST.xy + _CloudEdgeNoise_ST.zw + time3*_CloudEdgeNoise_ST.xy);
				float2 cloudNoiseUV = i.uv.xy + float2(cloudEdgeNoise.x,cloudEdgeNoise.y)*0.02;

                half4 col=SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,cloudNoiseUV);

                float lerptime=(abs(clamp(sin(_Time.x),-1,1))*_LerpCtrl);
				float verColor=abs(lerptime-i.vertexColor.r);
				
				half cloudStep =1-verColor;
				half a1 = clamp(smoothstep(saturate(cloudStep-0.1),cloudStep,col.b),0,col.a);  
				
				
                float s1 = smoothstep(0.5, 0.01, length(i.uv1 ));
                col.a=col.a*smoothstep(0,_sdf,i.uv1.y-0.01);

                
                if (_IsPlane == 0.0)
				    {
                col.rgb=(_ShadowColor*(1-col.r)+_BaseColor*col.r+_rimColor*col.g*scattering+_rimColor*col.g*moonScattering)+moonScattering*_MoonCol;
                float3 suncolor=scattering*_sunlightColor;
                col.rgb=col.rgb+suncolor;
                col.a=a1*col.a;
                    }
                else
                {
                    col.rgb=_BaseColor.rgb;
					col.a=col.a;
                }
                return col;
            }
            ENDHLSL

        }
    }
}
