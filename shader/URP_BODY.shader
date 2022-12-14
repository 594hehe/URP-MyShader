Shader "URP_BODY"
{
    Properties
    {
        [Header(Shader Setting)]
        [Space(5)]
        [KeywordEnum(Base,Hair)] _ShaderEnum("Shader类型",int) = 0
        [Toggle] _IsNight ("夜晚", int) = 0
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
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
		[Normal]_NormalTex ("NormalTexture", 2D) = "black" {}
		_NormalScale ("NormalScale", Range(0, 1)) = 1
       
        [Space(30)]

        [Header(Shadow Setting)]
        [Space(5)]
		_Eyeslight("眼睛亮度", Range(0, 2)) = 1
        _LightMap ("LightMap", 2D) = "grey" {}
        _RampMap ("RampMap", 2D) = "white" {}
        _ShadowSmooth ("Shadow Smooth", Range(0, 1)) = 0.5
        _RampShadowRange ("Ramp Shadow Range", Range(0.5, 0.99)) = 0.99
        
        
       
		
		
		[IntRange]_RampArea1 ("Ramp1 Color", Range(0, 4)) = 0
        [IntRange]_RampArea2 ("Ramp2 Color", Range(0, 4)) = 1
        [IntRange]_RampArea3 ("Ramp3 Color", Range(0, 4)) = 2
		[IntRange]_RampArea4 ("Ramp4 Color", Range(0, 4)) = 3
		[IntRange]_RampArea5 ("Ramp5 Color", Range(0, 4)) = 4
		[HDR]_RampColor1 ("Ramp Color1", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor2 ("Ramp Color2", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor3 ("Ramp Color3", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor4 ("Ramp Color4", Color) = (1.0, 1.0, 1.0, 1.0)
		[HDR]_RampColor5 ("Ramp Color5", Color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30)]


        [Header(Specular Setting)]
        [Space(5)]
        [Toggle] _EnableSpecular ("Enable Specular", int) = 1
        [Toggle] _ispaimon ("use DarkColor", int) = 0
        _MetalMap ("Metal Map", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _DarkColor ("Dark Color", Color) = (1.0, 1.0, 1.0, 1.0)

        _SpecExpon("高光裁切", Range(0, 10)) = 3
        _KsNonMetallic("非金属强度", Range(0, 1)) = 0.1
        _KsMetallic("金属强度", Range(0, 3)) = 1
		
		
        [Space(30)]

        [Header(Rim Setting)]
        [Space(5)]
        [Toggle] _EnableRim ("Enable Rim", int) = 1
        _RimOffset ("边缘宽度", Range(0, 2)) = 1    //粗细
        
        [Space(30)]

        [Header(Outline Setting)]
        [Space(5)]
        _OutlineWidth ("Outline Width", Range(0, 2)) = 0.5
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		
		 [Toggle(ENABLE_ALPHA_CLIPPING)]_EnableAlphaClipping ("EnableAlphaClipping", Float) = 0
        _Cutoff("Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque"}
        Cull off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        //#include "Assets/BOXOPHOBIC/Atmospheric Height Fog/Core/Includes/AtmosphericHeightFog.cginc"

        #pragma shader_feature _SHADERENUM_BASE _SHADERENUM_HAIR _SHADERENUM_FACE
		#pragma multi_compile _ _MAIN_LIGHT_SHADOWS //接受阴影
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE //产生阴影
        #pragma multi_compile _ _SHADOWS_SOFT //软阴影  
        #pragma shader_feature _ALPHATEST_ON

        #pragma shader_feature _AdditionalLights

        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile_fog
            

        int _IsNight;
        int _IsShadow;
        int _addlight;
        TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);
		TEXTURE2D(_NormalTex);            SAMPLER(sampler_NormalTex);
        TEXTURE2D(_LightMap);           SAMPLER(sampler_LightMap);
        TEXTURE2D(_RampMap);            SAMPLER(sampler_RampMap);
        TEXTURE2D(_MetalMap);           SAMPLER(sampler_MetalMap);
       // TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);

        // 单个材质独有的参数尽量放在 CBUFFER 中，以提高性能
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        half4 _MainColor;
		half4 _RampColor1;
		half4 _RampColor2;
		half4 _RampColor3;
		half4 _RampColor4;
		half4 _RampColor5;
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
		float _Eyeslight;
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
                o.color = v.color;
                return o;
            }

            half4 ToonPassFrag(v2f i) : SV_TARGET
            {
                float4 BaseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;
				//float4 Rampcolor1 = _Rampcolor1;
				#if ENABLE_ALPHA_CLIPPING
                    clip(BaseColor.a-_Cutoff);
                #endif
				
				
				half4 NormalTex = SAMPLE_TEXTURE2D(_NormalTex,sampler_NormalTex,i.uv); //法线贴图
				
				
				
				
				float3 normalTS = UnpackNormalScale(NormalTex,_NormalScale);               //控制法线强度
				normalTS.z = pow((1 - pow(normalTS.x,2) - pow(normalTS.y,2)),0.5);         //规范化法线 
				float3 norWS = mul(normalTS,i.worldNormal);  
				
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


                half halfLambert = dot(lightDir, i.worldNormal) * 0.5 + 0.5;

                //==========================================================================================
                // Base Ramp
                // 依据原来的lambert值，保留0到一定数值的smooth渐变，大于这一数值的全部采样ramp最右边的颜色，从而形成硬边
                halfLambert = smoothstep(0.0, _ShadowSmooth, halfLambert);
                // 常暗阴影
                float ShadowAO = smoothstep(-0.1, 0.2, LightMapColor.g);

                float RampPixelX = 0.00390625;  //0.00390625 = 1/256
                float RampPixelY = 0.03125;     //0.03125 = 1/16/2   尽量采样到ramp条带的正中间，以避免精度误差
                float RampX, RampY;
				float rampVmove = 0.0;
                // 对X做一步Clamp，防止采样到边界
                RampX = clamp(halfLambert*ShadowAO, RampPixelX, 1-RampPixelX);
 // Base Ramp
				
                if (_IsNight == 0.0)
                    rampVmove=0;
                else
                    rampVmove=-0.5;
                // 灰度0.0-0.2  硬Ramp
                // 灰度0.2-0.4  软Ramp
                // 灰度0.4-0.6  金属层
                // 灰度0.6-0.8  布料层，主要为silk类
                // 灰度0.8-1.0  皮肤/头发层
                // 白天采样上半，晚上采样下半
                    float4 ShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.95+rampVmove));
                    float4 ShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.85+rampVmove));
                    float4 ShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.75+rampVmove));
                    float4 ShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.65+rampVmove));
                    float4 ShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(RampX, 0.55+rampVmove));
                   
					float4 AllRamps[5] = {
                        ShadowRamp1, ShadowRamp2, ShadowRamp3, ShadowRamp4, ShadowRamp5
                    };
					float4 eyes=smoothstep(0.51, 1, LightMapColor.g);
					float4 eyes1=smoothstep(1, 0.51, LightMapColor.g);//眼睛分离

                    float4 metalRamp2 = smoothstep(0.8,0.85,LightMapColor.a) * AllRamps[_RampArea1]-eyes;
					float4 metalRamp3 = (smoothstep(0.6,0.65,LightMapColor.a)-smoothstep(0.8,0.85,LightMapColor.a)) * AllRamps[_RampArea2]-eyes;
					float4 metalRamp4 = (smoothstep(0.4,0.45,LightMapColor.a)-smoothstep(0.6,0.65,LightMapColor.a))* AllRamps[_RampArea3]	-eyes;
					float4 metalRamp5 = (smoothstep(0,0.1,LightMapColor.a)-smoothstep(0.4,0.45,LightMapColor.a))* AllRamps[_RampArea4]-eyes;
					float4 metalRamp6 =(1-smoothstep(0,0.1,LightMapColor.a))* AllRamps[_RampArea5]-eyes;

                    float4 allramp =metalRamp2+metalRamp3+metalRamp4+metalRamp5+metalRamp6;
                    


                    float4 oShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.95+rampVmove));
                    float4 oShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.85+rampVmove));
                    float4 oShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.75+rampVmove));
                    float4 oShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.65+rampVmove));
                    float4 oShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.55+rampVmove));

                    float4 oAllRamps[5] = {
                        oShadowRamp1, oShadowRamp2, oShadowRamp3, oShadowRamp4, oShadowRamp5
                    };

                    float4 ometalRamp2 = smoothstep(0.8,0.85,LightMapColor.a) * oAllRamps[_RampArea1]-eyes;
					float4 ometalRamp3 = (smoothstep(0.6,0.65,LightMapColor.a)-smoothstep(0.8,0.85,LightMapColor.a)) * oAllRamps[_RampArea2]-eyes;
					float4 ometalRamp4 = (smoothstep(0.4,0.45,LightMapColor.a)-smoothstep(0.6,0.65,LightMapColor.a))* oAllRamps[_RampArea3]	-eyes;
					float4 ometalRamp5 = (smoothstep(0,0.1,LightMapColor.a)-smoothstep(0.4,0.45,LightMapColor.a))* oAllRamps[_RampArea4]-eyes;
					float4 ometalRamp6 =(1-smoothstep(0,0.1,LightMapColor.a))* oAllRamps[_RampArea5]-eyes;

                    float4 oallramp =ometalRamp2+ometalRamp3+ometalRamp4+ometalRamp5+ometalRamp6;


					float allao =halfLambert*ShadowAO;
                //— — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                float shadow = MainLightRealtimeShadow(i.shadowCoord); 
                //shadow =Light.shadowAttenuation;
                float4 oshadow = float4(shadow,shadow,shadow,1);
                
                oshadow =lerp(oallramp,1,oshadow);
               

                
                

               

                float4 rampColor =lerp(allramp, 1,step(_RampShadowRange, allao));
                float4 rampColor1 =lerp(1, allramp,smoothstep(0,1, shadow)-smoothstep(0.96,1, shadow));
               
                

                //float4 FinalRamp = rampColor * BaseColor*oshadow;
                float4  FinalRamp=0;
                float dishadow=halfLambert;

                if ( shadow<allao &&_IsShadow == 1.0)//若处于阴影中
                FinalRamp =rampColor1*oshadow *BaseColor;
                //FinalRamp =  rampColor *BaseColor * oshadow;
                else
                FinalRamp = rampColor * BaseColor;
                
				FinalRamp=FinalRamp*step(abs(LightMapColor.a * 255 - 255), 39)*_RampColor1+FinalRamp*step(abs(LightMapColor.a * 255 - 178), 39)*_RampColor2+FinalRamp*step(abs(LightMapColor.a * 255 - 128), 39)*_RampColor3+FinalRamp*step(abs(LightMapColor.a * 255 - 77), 39)*_RampColor4+FinalRamp*step(abs(LightMapColor.a * 255 - 0), 39)*_RampColor5;
				FinalRamp=eyes1*FinalRamp+(eyes*BaseColor*_Eyeslight);


                
                

                float lambertStep=smoothstep(0.423,0.450,halfLambert);
                // Blinn-Phong
                float BlinnPhongSpecular =step(0,dot(i.worldNormal, viewDir))*pow(max(0, dot(i.worldNormal, halfDir)),_SpecExpon);
                float3 nonMteallicSpec =step(1.04-BlinnPhongSpecular,LightMapColor.b)*LightMapColor.r*_KsNonMetallic; //非金属部分高光
                float3 metallicSpec = BlinnPhongSpecular*LightMapColor.b*(lambertStep*0.8+0.2)*BaseColor*_KsMetallic;//金属部分高光
                metallicSpec =lerp (metallicSpec*_SpecularColor,metallicSpec,BlinnPhongSpecular);
                
                float isMetal =step(0.85,LightMapColor.r);

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
                    Specular=lerp(FinalRamp,metallic,isMetal)+Specular;
                }
                else
                {
                    Specular=FinalRamp;
                }
                float4 FinalSpecular=float4(Specular,1);
                



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
                float rim=saturate(offsetLinearDepth-linearDepth);
                rim=step(rimThreshold,rim)*clamp(rim*rimStrength,0,rimMax)* _EnableRim;

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

              

                return FinalColor;

                
                
				
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
                return o;
	     }
	     float4 frag(v2f input) :  SV_TARGET
        {
            
                 float4 BaseColorback = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * _MainColor;
                 float4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv);
                 float rampVmove = 0.0;
                 if (_IsNight == 0.0)
                    rampVmove=0;
                 else
                    rampVmove=-0.5;

                    float4 oShadowRamp1 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.95+rampVmove));
                    float4 oShadowRamp2 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.85+rampVmove));
                    float4 oShadowRamp3 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.75+rampVmove));
                    float4 oShadowRamp4 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.65+rampVmove));
                    float4 oShadowRamp5 = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(0.1, 0.55+rampVmove));
                    float4 oAllRamps[5] = {
                        oShadowRamp1, oShadowRamp2, oShadowRamp3, oShadowRamp4, oShadowRamp5
                    };

                    float4 ometalRamp2 = smoothstep(0.8,0.85,LightMapColor.a) * oAllRamps[_RampArea1];
					float4 ometalRamp3 = (smoothstep(0.6,0.65,LightMapColor.a)-smoothstep(0.8,0.85,LightMapColor.a)) * oAllRamps[_RampArea2];
					float4 ometalRamp4 = (smoothstep(0.4,0.45,LightMapColor.a)-smoothstep(0.6,0.65,LightMapColor.a))* oAllRamps[_RampArea3];
					float4 ometalRamp5 = (smoothstep(0,0.1,LightMapColor.a)-smoothstep(0.4,0.45,LightMapColor.a))* oAllRamps[_RampArea4];
					float4 ometalRamp6 =(1-smoothstep(0,0.1,LightMapColor.a))* oAllRamps[_RampArea5];

                    float4 oallramp =ometalRamp2+ometalRamp3+ometalRamp4+ometalRamp5+ometalRamp6;
                    BaseColorback*=oallramp;
                
                 return BaseColorback;
	     }
            ENDHLSL
        }





/*
        
        Pass {
            Name "OutLine"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
	         Cull front
	         HLSLPROGRAM
	        #pragma vertex vert  
	         #pragma fragment frag
			 #pragma fragment FragmentAlphaClip
			 #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING
	          v2f vert(a2v input) {
                float4 scaledScreenParams = GetScaledScreenParams();
                float ScaleX = abs(scaledScreenParams.x / scaledScreenParams.y);//求得X因屏幕比例缩放的倍数
		      v2f output;
		          VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal);
                float3 normalCS = TransformWorldToHClipDir(normalInput.normalWS);//法线转换到裁剪空间
                float2 extendDis = normalize(normalCS.xy) *(_OutlineWidth*0.01);//根据法线和线宽计算偏移量
                extendDis.x /=ScaleX ;//由于屏幕比例可能不是1:1，所以偏移量会被拉伸显示，根据屏幕比例把x进行修正
                output.pos = TransformObjectToHClip(input.vertex);
				float ctrl = clamp(5/output.pos.w,0,1);//最远描边宽度
                #if _OLWVWD_ON
                    //屏幕下描边宽度会变
                    output.pos.xy +=extendDis;
                #else
                    //屏幕下描边宽度不变，则需要顶点偏移的距离在NDC坐标下为固定值
                    //因为后续会转换成NDC坐标，会除w进行缩放，所以先乘一个w，那么该偏移的距离就不会在NDC下有变换
                    output.pos.xy += extendDis * output.pos.w* ctrl*input.color.a;//顶点色控制粗细
                #endif
				
                
		      return output;
	     }
	     float4 frag(v2f input) : SV_Target {
            return float4(_OutlineColor.rgb, 1);
            
	     }
            ENDHLSL
        }
        
*/
        
		Pass
        {         
            Tags {"LightMode" = "ShadowCaster"}

        }

        Pass
        {
            Tags {"LightMode" = "DepthOnly"}
        }
    }
}
