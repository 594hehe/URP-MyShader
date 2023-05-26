Shader "StarRail"
{
    Properties
    {
        [Header(Shader Setting)]
        [Space(5)]
        [Toggle] _IsShadow ("外部阴影", int) = 1
        [Toggle] _addlight ("间接光", int) = 0

        _addLightInfluence ("间接光照强度", range(0.0, 0.5)) = 0
        //_Shadowlerp("阴影融合", Range(-1, 1)) = 0
        //_Shadowlerp2("阴影融合2", Range(-1, 1)) = 0
       // _shadowColor ("阴影 Color", Color) = (1.0, 1.0, 1.0, 1.0)
        
        //_Shadowlerp3("阴影融合3", Range(-1, 1)) = 0
        //_Shadowlerp4("阴影融合4", Range(-1, 1)) = 0
        [Space(5)]

        [Header(Main Texture Setting)]
        [Space(5)]
		_WorldLightInfluence ("世界灯光", range(0.0, 1.0)) = 0.1
		[HDR][MainColor] _MainColor ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Eyeslight("眼睛穿透度", Range(0, 1)) = 0
        _Brightness("亮度", Range(1, 1.5)) = 1
        _Contrast("对比度", Range(0.9, 1.1)) = 1
        _Saturation("饱和度", Range(0.9, 1.1)) = 1 //饱和度

        _darkshadow("暗部强度", Range(0.6, 1.1)) = 0.75 
        _darkshadow2("阴影强度", Range(0.6, 1)) = 0.6 


        
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        _hairc ("眼睛遮罩", 2D) = "black" {}
        _sock ("丝袜贴图", 2D) = "black" {}
        _sockColor ("丝袜颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _sockColor2 ("丝袜颜色2", Color) = (1.0, 1.0, 1.0, 1.0)
       _socklight("丝袜强度", Range(1, 5)) = 3
       _largesock("纹理大小", Range(10, 30)) = 25
   
	
       
        [Space(30)]

        [Header(Shadow Setting)]
        [Space(5)]
		_Emislight("自发光亮度", Range(0, 2)) = 1
        [HDR]_Selfcolor1 ("自发光颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _LightMap ("LightMap", 2D) = "grey" {}
        _RampMap ("RampMap", 2D) = "white" {}
        _ShadowSmooth ("Shadow Smooth", Range(0, 1)) = 0.5
        _RampShadowRange ("Ramp Shadow Range", Range(0.5, 0.99)) = 0.99
        
        
       
		
		
		[IntRange]_RampArea1 ("Ramp1 Color", Range(0, 5)) = 0
        [IntRange]_RampArea2 ("Ramp2 Color", Range(0, 5)) = 1
        [IntRange]_RampArea3 ("Ramp3 Color", Range(0, 5)) = 2
		[IntRange]_RampArea4 ("Ramp4 Color", Range(0, 5)) = 3
		[IntRange]_RampArea5 ("皮肤 Color", Range(0, 5)) = 4
        [IntRange]_RampArea6 ("额外 Color", Range(0, 5)) = 4
		[HDR]_RampColor1 ("Ramp Color1", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor2 ("Ramp Color2", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor3 ("Ramp Color3", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor4 ("Ramp Color4", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor5 ("Ramp Color5", Color) = (1.0, 1.0, 1.0, 1.0)
        [HDR]_RampColor6 ("Ramp Color6", Color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30)]


        [Header(Specular Setting)]
        [Space(5)]
        [Toggle] _EnableSpecular ("Enable Specular", int) = 1
        [Toggle] _ispaimon ("use DarkColor", int) = 0
        _MetalMap ("Metal Map", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _DarkColor ("Dark Color", Color) = (1.0, 1.0, 1.0, 1.0)

        _SpecExpon("高光裁切", Range(0.1, 10)) = 3
        _KsNonMetallic("非金属强度", Range(0, 1)) = 0.1
        _KsMetallic("金属强度", Range(0, 3)) = 1
		
		
        [Space(30)]

        [Header(Rim Setting)]
        [Space(5)]
        [Toggle] _EnableRim ("Enable Rim", int) = 1
        [HDR]_RimColor ("RimColor", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimOffset ("边缘宽度", Range(0, 2)) = 1    //粗细
        
        [Space(30)]

        [Header(Outline Setting)]
        [Space(5)]
       // _OutlineWidth ("Outline Width", Range(0, 2)) = 0.5
       // _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		
		 [Toggle(ENABLE_ALPHA_CLIPPING)]_EnableAlphaClipping ("EnableAlphaClipping", Float) = 0
        _Cutoff("Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque"}
        Cull off
        ZWrite On
        

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #include "Assets/Scripts/CustomShadowmap/CustomShadows.hlsl"
       

        
		#pragma multi_compile _ _MAIN_LIGHT_SHADOWS //接受阴影
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE //产生阴影
        #pragma multi_compile _ _SHADOWS_SOFT //软阴影  
        #pragma shader_feature _ALPHATEST_ON
        #pragma shader_feature _AdditionalLights

        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile_fog
            

        //int _IsNight;
        int _IsShadow;
        int _addlight;
        TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);
		TEXTURE2D(_NormalTex);            SAMPLER(sampler_NormalTex);
        TEXTURE2D(_LightMap);           SAMPLER(sampler_LightMap);
        TEXTURE2D(_RampMap);            SAMPLER(sampler_RampMap);
        TEXTURE2D(_MetalMap);           SAMPLER(sampler_MetalMap);
        TEXTURE2D(_hairc);           SAMPLER(sampler_hairc);
        TEXTURE2D(_sock);           SAMPLER(sampler_sock);

        TEXTURE2D(_MyTexture);        SAMPLER(sampler_MyTexture);
       // TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);

        // 单个材质独有的参数尽量放在 CBUFFER 中，以提高性能
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        half4 _MainColor;
        half4 _sockColor;
        half4 _sockColor2;
		half4 _RampColor1;
		half4 _RampColor2;
		half4 _RampColor3;
		half4 _RampColor4;
		half4 _RampColor5;
        half4 _RampColor6;
        half4 _Selfcolor1;
        float4 _LightMap_ST;
        float4 _RampMap_ST;
        half _ShadowSmooth;
        half _RampShadowRange;
		float _WorldLightInfluence;
		float _WorldLight;
		float _RampArea1;
        float _RampArea2;
		float _RampArea3;
		float _RampArea4;
        float _RampArea5;
        float _RampArea6;
		float _RangeAO;
        float _RangeAO1;
        float _RangeAO2;
        float _Shadowlerp;
        float _Shadowlerp2;
        float _Shadowlerp3;
        float _Shadowlerp4;
        float4 _shadowColor;
		float _NormalScale;
		float _RimBrightness;
		float _Emislight;
        int _EnableSpecular;
        int _ispaimon;
        float4 _MetalMap_ST;
        half4 _SpecularColor;
        half _MetalMapV;
        half _MetalMapIntensity;
        half _KsNonMetallic;
        half _KsMetallic;
        half _SpecExpon;
        float _FaceShadowOffset;
        float _addLightInfluence;
        float _FaceShadowPow;
        int _EnableRim;
        half4 _RimColor;
        half _RimOffset;
        half _RimThreshold;
        half _OutlineWidth;
        half4 _OutlineColor;
        half4 _DarkColor;
		half _Cutoff;
        half _Saturation;;
        half _Contrast;
        half _Brightness;
        half _darkshadow;
        half _darkshadow2;
        half _Eyeslight;
        half _socklight;
        half _largesock;
       
		
        CBUFFER_END

        struct a2v{
            float3 vertex : POSITION;       //顶点坐标
            half4 color : COLOR0;           //顶点色
            half3 normal : NORMAL;          //法线
            half4 tangent : TANGENT;        //切线
            float2 texCoord : TEXCOORD0;    //纹理坐标
        };
        struct v2f{
            float4 pos : POSITION;              //裁剪空间顶点坐标
			//float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;              //uv
            float3 worldPos : TEXCOORD1;        //世界坐标
            float3 worldNormal : TEXCOORD2;     //世界空间法线
            float3 worldTangent : TEXCOORD3;    //世界空间切线
            float3 worldBiTangent : TEXCOORD4;  //世界空间副切线
            float3 positionWS : TEXCOORD6; 
            float4 positionNDC:TEXCOORD5;
            float4 shadowCoord :TEXCOORD8;
            float fogCoord : TEXCOORD9;
            float4 shadowVertex : TEXCOORD7;
            //float2 uv2 : TEXCOORD11;
            half4 color : COLOR0;               //平滑Rim所需顶点色
        };
		
		
        ENDHLSL

        Pass
        {
            Tags {"LightMode"="UniversalForward" "RenderType"="Opaque"}
			
			Cull back
            ZTest LEqual
            ZWrite on
            Blend One Zero
            
            Stencil{
                Ref 222
                Comp Always
                Pass Replace
            }
            
            HLSLPROGRAM
			#pragma target 3.0
            #pragma vertex ToonPassVert
            #pragma fragment ToonPassFrag
			#pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            
            
            
			
            v2f ToonPassVert(a2v v)
            {
                v2f o;
                VertexPositionInputs vertexInput =GetVertexPositionInputs(v.vertex.xyz);
                o.positionWS = vertexInput.positionWS;
                o.positionNDC = vertexInput.positionNDC;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texCoord, _MainTex);
              

                o.worldPos = TransformObjectToWorld(v.vertex);
                // 使用URP自带函数计算世界空间法线
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normal, v.tangent);
                o.worldNormal = vertexNormalInput.normalWS;
                o.worldTangent = vertexNormalInput.tangentWS;
                o.worldBiTangent = vertexNormalInput.bitangentWS;
                
                
                o.shadowCoord = TransformWorldToShadowCoord(vertexInput.positionWS);

                o.shadowVertex = mul(_ZorroShadowMatrix, float4(o.worldPos.xyz, 1.0f));
                
                o.color = v.color;
                o.fogCoord = ComputeFogFactor(o.pos.z);
                return o;
            }

            half4 ToonPassFrag(v2f i) : SV_TARGET
            {
                float4 BaseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;
				
				#if ENABLE_ALPHA_CLIPPING
                    clip(BaseColor.a-_Cutoff);
                #endif
				//half4 NormalTex = SAMPLE_TEXTURE2D(_NormalTex,sampler_NormalTex,i.uv); //法线贴图
				
				
				
				
				//float3 normalTS = UnpackNormalScale(NormalTex,_NormalScale);               //控制法线强度
				//normalTS.z = pow((1 - pow(normalTS.x,2) - pow(normalTS.y,2)),0.5);         //规范化法线 
				//float3 norWS = mul(normalTS,i.worldNormal);  
				
                float4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv);
                Light mainLight = GetMainLight();
                Light Light1 = GetMainLight(i.shadowCoord);

                


                half4 LightColor = half4(mainLight.color, 1.0);
                half3 lightDir = normalize(mainLight.direction);
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 halfDir = normalize(viewDir + lightDir);

                float3 N=normalize(i.worldNormal);
                float3 V=viewDir;
                float3 L=lightDir;
                float3 H=normalize(L+V);

                float NoL=dot(normalize(i.worldNormal),normalize(Light1.direction));
                float NoH=dot(N,H);
                float NoV=dot(N,V);

                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V,N));


                float halfLambert = pow(dot(lightDir, i.worldNormal) * 0.5 + 0.5,2);
                //float halfLambert = dot(lightDir, i.worldNormal) * 0.5 + 0.5;

                //==========================================================================================
                // Base Ramp
                // 依据原来的lambert值，保留0到一定数值的smooth渐变，大于这一数值的全部采样ramp最右边的颜色，从而形成硬边
                halfLambert = smoothstep(0.0, _ShadowSmooth, halfLambert);
                // 常暗阴影
               // float ShadowAO2 = saturate(LightMapColor.r);
                float ShadowAO = smoothstep(0.1, 0.2, LightMapColor.g);

                float RampPixelX = 0.00390625;  //0.00390625 = 1/256

                // 对X做一步Clamp，防止采样到边界
                float RampX = clamp(halfLambert, RampPixelX+0.5, 1-RampPixelX);
				
               
                // 灰度0.0-0.2  硬Ramp
                // 灰度0.2-0.4  软Ramp
                // 灰度0.4-0.6  金属层
                // 灰度0.6-0.8  布料层，主要为silk类
                // 灰度0.8-1.0  皮肤/头发层
                // 白天采样上半，晚上采样下半
                    float4 ShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.9375));
                    float4 ShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.8125));
                    float4 ShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.6875));
                    float4 ShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.5625));
                    float4 ShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.0625));//皮肤
                    float4 ShadowRamp6 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.4375));//额外灰度

					float4 AllRamps[6] = {
                        ShadowRamp1, ShadowRamp2, ShadowRamp3, ShadowRamp4,ShadowRamp5,ShadowRamp6
                    };
					
                    float4 metalRamp2 = step(0.7,LightMapColor.a) * AllRamps[_RampArea1];//可发光处
					float4 metalRamp3 = (step(0.45,LightMapColor.a)-step(0.66,LightMapColor.a)) * AllRamps[_RampArea2];//常规色1
					float4 metalRamp4 = (step(0.3,LightMapColor.a)-step(0.45,LightMapColor.a))* AllRamps[_RampArea3];//金属范围
					float4 metalRamp5 = (step(0.2,LightMapColor.a)-step(0.3,LightMapColor.a))* AllRamps[_RampArea4];
                    float4 metalRamp6 = (step(0.1,LightMapColor.a)-step(0.2,LightMapColor.a))* AllRamps[_RampArea6];
					float4 metalRamp7 =(1-step(0.1,LightMapColor.a))* AllRamps[_RampArea5];//皮肤

                    float4 allramp =metalRamp2+metalRamp3+metalRamp4+metalRamp5+metalRamp6+metalRamp7;
                    allramp=allramp*allramp;
                    half gray = 0.2125 * _MainColor.r + 0.7154 * _MainColor.g + 0.0721 * _MainColor.b;
			        half3 grayColor = half3(gray, gray, gray);
				    //根据Saturation在饱和度最低的图像和原图之间差值
			        allramp.rgb = lerp(grayColor, allramp, _darkshadow2);
                    


                    float4 oShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.9375));
                    float4 oShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.8125));
                    float4 oShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.6875));
                    float4 oShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.5625));
                    float4 oShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.0625));
                    float4 oShadowRamp6 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.4375));//额外灰度

                    float4 oAllRamps[6] = {
                        oShadowRamp1, oShadowRamp2, oShadowRamp3, oShadowRamp4, oShadowRamp5,oShadowRamp6
                    };

                    float4 ometalRamp2 = step(0.7,LightMapColor.a) * oAllRamps[_RampArea1];
					float4 ometalRamp3 = (step(0.45,LightMapColor.a)-step(0.66,LightMapColor.a)) * oAllRamps[_RampArea2];
					float4 ometalRamp4 = (step(0.3,LightMapColor.a)-step(0.45,LightMapColor.a))* oAllRamps[_RampArea3];
					float4 ometalRamp5 = (step(0.2,LightMapColor.a)-step(0.3,LightMapColor.a))* oAllRamps[_RampArea4];
					float4 ometalRamp6 =(step(0.1,LightMapColor.a)-step(0.2,LightMapColor.a))* oAllRamps[_RampArea6];
                    float4 ometalRamp7 =(1-step(0.1,LightMapColor.a))* oAllRamps[_RampArea5];

                    float4 oallramp =ometalRamp2+ometalRamp3+ometalRamp4+ometalRamp5+ometalRamp6+ometalRamp7;
                    oallramp.rgb = lerp(grayColor, oallramp, _darkshadow);



                    //基础色调色

                    float4 baseRamp2 = step(0.7,LightMapColor.a) *_RampColor1;//可发光处
					float4 baseRamp3 = (step(0.45,LightMapColor.a)-step(0.66,LightMapColor.a)) *_RampColor2;//常规色1
					float4 baseRamp4 = (step(0.3,LightMapColor.a)-step(0.45,LightMapColor.a))*_RampColor3;//金属范围
					float4 baseRamp5 = (step(0.2,LightMapColor.a)-step(0.3,LightMapColor.a))*_RampColor4;
                    float4 baseRamp6 = (step(0.1,LightMapColor.a)-step(0.2,LightMapColor.a))*_RampColor6;
					float4 baseRamp7 =(1-step(0.1,LightMapColor.a))*_RampColor5;//皮肤

                    float4 BaseColor2=(baseRamp2+baseRamp3+baseRamp4+baseRamp5+baseRamp6+baseRamp7) *BaseColor;




                    


					float allao =halfLambert*ShadowAO;
                //— — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —




                float _DepthBias = _ZorroShadowParams.w;
				float3 _ShadowColor = _ZorroShadowParams.xyz;

				float3 shadowVertex = (((i.shadowVertex.xyz / i.shadowVertex.w) * 0.5) + 0.5);

				shadowVertex.z = (shadowVertex.z - _DepthBias);
			#if UNITY_REVERSED_Z //DirectX 
				shadowVertex.z = 1 - shadowVertex.z;
			#else
				
			#endif
				

				//flip Y for sample_CMP ,TODO platform dependent
			#if UNITY_UV_STARTS_AT_TOP //DirectX
				shadowVertex.y = 1 - shadowVertex.y;
			#endif
				
				float t = SAMPLE_TEXTURE2D_SHADOW(_ZorroShadowmapTexture, sampler__ZorroShadowmapTexture, shadowVertex.xyz);
				float tcolor = lerp(0, 1, t);
               //render feature中获取通道阴影贴图

                float4 oshadow = float4(tcolor,tcolor,tcolor,1);
                oshadow =lerp(oallramp,1,tcolor);


                float4 rampColor =lerp(allramp, 1,step(_RampShadowRange, allao));

                
                float4 rampColor1 =lerp(1, allramp,smoothstep(0,1, tcolor)-smoothstep(0.96,1, tcolor));

                  
               
                

                //float4 FinalRamp = rampColor * BaseColor*oshadow;
                float4  FinalRamp=0;
               

                if ( tcolor<allao &&_IsShadow == 1.0)//若处于阴影中
                FinalRamp =rampColor1*oshadow *BaseColor2;
                //FinalRamp =  rampColor *BaseColor * oshadow;
                else
                FinalRamp = rampColor * BaseColor2;

                

                FinalRamp=lerp(oallramp*oallramp*BaseColor2,FinalRamp,saturate(LightMapColor.g*3));//纯暗颜色
                FinalRamp=lerp(FinalRamp,BaseColor2,saturate(LightMapColor.g-0.5)*2);




              
                
				
                float lambertStep=smoothstep(0.423,0.450,halfLambert);
                // Blinn-Phong
                float BlinnPhongSpecular =step(0,dot(i.worldNormal, viewDir))*pow(max(0, dot(i.worldNormal, halfDir)),_SpecExpon);
                float3 nonMteallicSpec =step(1.04-BlinnPhongSpecular,LightMapColor.b)*LightMapColor.r*_KsNonMetallic; //非金属部分高光
                float3 metallicSpec = BlinnPhongSpecular*LightMapColor.b*(lambertStep*0.8+0.2)*BaseColor*_KsMetallic;//金属部分高光
                metallicSpec =lerp (metallicSpec*_SpecularColor,metallicSpec,BlinnPhongSpecular);
                
                float isMetal =saturate(smoothstep(0.44,0.45,LightMapColor.a))-saturate(smoothstep(0.6,0.61,LightMapColor.a));

                float3 Specular=lerp(nonMteallicSpec,metallicSpec,isMetal);


                // 金属部分matcap图采样
                float2 MetalMapUV = mul((float3x3) UNITY_MATRIX_V, i.worldNormal).xy * 0.5 + 0.5;
                float MetalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, MetalMapUV).r;

                float3 MetalMap1=lerp(_DarkColor*(1-MetalMap),1,MetalMap);//派蒙用

                float3 metallic;

                if (_ispaimon == 1.0)
                metallic=lerp(0,MetalMap1*BaseColor,isMetal);//贴图高光
                else
                metallic=lerp(0,MetalMap*BaseColor,isMetal);



                
                if (_EnableSpecular == 1.0)
                {
                    Specular=lerp(FinalRamp,metallic*lerp(oallramp* BaseColor,1,saturate(LightMapColor.g*2)),isMetal)+Specular;
                }
                else
                {
                    Specular=FinalRamp;
                }

                float4 FinalSpecular=float4(Specular,1);


                float4 sockMap = SAMPLE_TEXTURE2D(_sock, sampler_sock, i.uv);
                float PhongSpecular =pow(max(0, dot(i.worldNormal, viewDir)),_socklight);
                float sockcolor2=step(0.1,sockMap.r); 
                float sockMapUV = SAMPLE_TEXTURE2D(_sock, sampler_sock, float2(i.uv.x,i.uv.y)*_largesock).b;

                
               
                float4 sockl=BaseColor*saturate(PhongSpecular+0.5);
                float4 sockwenli=lerp(sockl+sockl*0.2,sockl,sockMapUV);
                float4 sock2=lerp(sockwenli,BaseColor,PhongSpecular);
                float4 sock3=lerp((BaseColor+0.3)*allramp*sock2,sock2,halfLambert);
                sock3=lerp(sock3*_sockColor,sock3*_sockColor2,sockMap.g);
             


                float4 Finalsock=lerp(FinalSpecular,sock3,sockcolor2);
                FinalSpecular=Finalsock;




                



                //==========================================================================================
                // 屏幕空间深度等宽边缘光
                


                float rimOffset=_RimOffset*6;//宽度
                float rimThreshold=0.03;
                float rimStrength=0.6;
                float rimMax=0.3;

                float2 screenUV=i.positionNDC.xy/i.positionNDC.w;
                float rawDepth=SampleSceneDepth(screenUV);
                float linearDepth=LinearEyeDepth(rawDepth,_ZBufferParams);
                float2 screenOffset= float2(lerp(-1,1,step(0,normalVS.x))*rimOffset/_ScreenParams.x/max(1,pow(linearDepth,2)),0);
                float offsetDepth=SampleSceneDepth(screenUV+screenOffset);
                float offsetLinearDepth=LinearEyeDepth(offsetDepth,_ZBufferParams);
                float4 rim=saturate(offsetLinearDepth-linearDepth);
                rim=step(rimThreshold,rim)*clamp(rim*rimStrength,0,rimMax)* _EnableRim*_RimColor;

                float fresnelPower =6;
                float fresnelClamp =0.8;
                float fresnel =1-saturate(NoV);
                fresnel =pow(fresnel,fresnelPower);
                fresnel =fresnel * fresnelClamp+(1-fresnelClamp);

                float4 FinalColor = 1-(1-rim*fresnel)*(1-FinalSpecular);


                int addLightsCount = GetAdditionalLightsCount();//定义在lighting库函数的方法 返回一个额外灯光的数量
                for (int idx = 0; idx < addLightsCount; idx++)

                {

                	Light addlight = GetAdditionalLight(idx, i.worldPos);//定义在lightling库里的方法 返回一个灯光类型的数据
                	//FinalColor.rgb += addlight.color * FinalColor * addlight.distanceAttenuation *_addLightInfluence;
                    if (_addlight==1)
                    FinalColor.rgb = lerp(FinalColor, addlight.color*_addLightInfluence*FinalColor+(1-_addLightInfluence)*FinalColor,addlight.distanceAttenuation) ;
                    else

                    FinalColor.rgb=FinalColor.rgb;
                    
                    
                }




               FinalColor = (_WorldLightInfluence * _MainLightColor * FinalColor + (1 - _WorldLightInfluence) * FinalColor);

               FinalColor.rgb = MixFog(FinalColor.rgb, i.fogCoord);//混合fog

               FinalColor=lerp(FinalColor,FinalColor*_Emislight*_Selfcolor1,step(0.8,LightMapColor.a));

               FinalColor=FinalColor*_Brightness;

               half3 avgColor = half3(0.5, 0.5, 0.5);
               FinalColor.rgb=lerp(avgColor, FinalColor, _Contrast);
               
				    //根据Saturation在饱和度最低的图像和原图之间差值
			   FinalColor.rgb = lerp(grayColor, FinalColor, _Saturation);

            float4  screenuv2= SAMPLE_TEXTURE2D(_MyTexture, sampler_MyTexture, screenUV); 
            float4 eyes=screenuv2;
            float liang=saturate(screenuv2*100);

            float hairc = SAMPLE_TEXTURE2D(_hairc, sampler_hairc, i.uv);
            

            FinalColor=lerp(FinalColor,screenuv2,liang*_Eyeslight*hairc*2);

            


              

               return FinalColor;
               
            
               
            //return saturate(LightMapColor.g*_WorldLightInfluence);
           
                
                
				
            }
            ENDHLSL
        }
        
        Pass {
            Name "back"
            Tags{ "LightMode" = "SRPDefaultUnlit"}
	        Cull front
            ZTest LEqual
            ZWrite On
            Blend One Zero

            Stencil{
                Ref 223
                Comp always
                Pass replace
                //Pass Replace
                
            }
	        HLSLPROGRAM
	        #pragma vertex vertback
	        #pragma fragment frag
			#pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
             
	          v2f vertback(a2v input) 
              {
                v2f o;
                o.pos = TransformObjectToHClip(input.vertex);
                o.uv = TRANSFORM_TEX(input.texCoord, _MainTex);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normal, input.tangent);
                o.worldNormal =1- vertexNormalInput.normalWS;
                o.fogCoord = ComputeFogFactor(o.pos.z);
                return o;
	     }
	     float4 frag(v2f input) :  SV_TARGET
        {
            
                 float4 BaseColorback = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _MainColor;
                 float4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv);
                 float rampVmove = 0.0;
                 
                    rampVmove=0;
                 

                    float4 oShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.9375));
                    float4 oShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.8125));
                    float4 oShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.6875));
                    float4 oShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.5625));
                    float4 oShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.0625));
                    float4 oShadowRamp6 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.5, 0.4375));//额外灰度

                    float4 oAllRamps[6] = {
                        oShadowRamp1, oShadowRamp2, oShadowRamp3, oShadowRamp4, oShadowRamp5,oShadowRamp6
                    };

                    
                    float4 ometalRamp2 = step(0.7,LightMapColor.a) * oAllRamps[_RampArea1];
					float4 ometalRamp3 = (step(0.45,LightMapColor.a)-step(0.66,LightMapColor.a)) * oAllRamps[_RampArea2];
					float4 ometalRamp4 = (step(0.3,LightMapColor.a)-step(0.45,LightMapColor.a))* oAllRamps[_RampArea3];
					float4 ometalRamp5 = (step(0.2,LightMapColor.a)-step(0.3,LightMapColor.a))* oAllRamps[_RampArea4];
					float4 ometalRamp6 =(step(0.1,LightMapColor.a)-step(0.2,LightMapColor.a))* oAllRamps[_RampArea6];
                    float4 ometalRamp7 =(1-step(0.1,LightMapColor.a))* oAllRamps[_RampArea5];

                    float4 oallramp =ometalRamp2+ometalRamp3+ometalRamp4+ometalRamp5+ometalRamp6+ometalRamp7;
                    

                   
                    BaseColorback*=oallramp;

                    BaseColorback.rgb = MixFog(BaseColorback.rgb, input.fogCoord);//混合fog
                
                 return BaseColorback;
	     }
            ENDHLSL
        }


        

		Pass
        {
            Tags{"LightMode"="ShadowCaster" }
            HLSLPROGRAM
            #pragma vertex ToonPassVert
            #pragma fragment ToonPassFrag

      

        

            v2f ToonPassVert(a2v i)
            {
                v2f o;
                
                o.uv=TRANSFORM_TEX(i.texCoord,_MainTex);
                
                float3 WSpos=TransformObjectToWorld(i.vertex.xyz);//网格大小
                Light MainLight=GetMainLight();
                MainLight.shadowAttenuation=1;
                float shadowAtten = 0;
                float3 WSnor=TransformObjectToWorldNormal(i.normal.xyz);


                

               o.pos=TransformWorldToHClip(ApplyShadowBias(WSpos,WSnor,MainLight.direction));
              
          



                #if UNITY_REVERSED_Z
                o.pos.z=min(o.pos.z,o.pos.w*UNITY_NEAR_CLIP_VALUE);
                #else
                o.pos.z=max(o.pos.z,o.pos.w*UNITY_NEAR_CLIP_VALUE);
                #endif
                
                return o;
                }
                half4 ToonPassFrag(v2f i):SV_TARGET
                {
                    #ifdef _CUT_ON
                    float alpha=SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv).a;
                    clip(alpha-_Cutoff);
                    #endif
                    float4 red;
                    red=(255,1,1,0);
                    return red;
                }
                    ENDHLSL
        }
                    


        
        Pass
        {
            Tags {"LightMode" = "DepthOnly"}
        }
    }
}
