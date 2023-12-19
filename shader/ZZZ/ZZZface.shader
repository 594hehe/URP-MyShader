Shader "ZZZ_FACE"
{
    Properties
    {
        [Header(Main Texture Setting)]
        [Space(5)]
        [Toggle] _IsShadow ("外部阴影", int) = 1
         _HBrightness("高光亮度", Range(0, 12)) = 1 
        _Brightness222("亮面强度", Range(1, 2)) = 1	
        [HDR]_lightcolor222("亮面颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        [HDR][MainColor]_BaseColor ("BaseColor", Color) = (1, 0.7519709, 0.6477987, 1)
		[MainTexture]_BaseMap ("BaseMap (Albedo)", 2D) = "black" { }
		_FaceShadowMap ("Face Shadow Map", 2D) = "white" { }
       
        _FXMap ("FX Map", 2D) = "white" { }
        _eyescolor("mask Color", color) = (1, 1, 1, 1) 
        _eyesshadow("眼睛阴影", Color) = (0.06692773, 0.1135293, 0.3018867, 0.3960784)
        _eyesshadowl("眼睛光斑阴影", Color) = (0.06692773, 0.1135293, 0.3018867, 0.3960784)
       
        
	
		//_FaceVAlpha ("顶点Alpha", 2D) = "white" { }
        [HDR]_ShadowMultColor ("Shadow Color", color) = (1, 0.7232704, 0.7232704, 1) 
        _shadowst("阴影平滑", Range(0, 0.1)) = 0.1
		_Brightness("亮度", Range(1, 1.2)) = 1    //调整亮度
		_Saturation("饱和度", Float) = 1 //饱和度
		_Contrast("对比度", Float) = 1		//调整对比度
		
		[Toggle] _EnableRim ("Enable Rim", int) = 1
        //[HDR] _RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimOffset ("边缘光宽度", Range(0, 1)) = 1    //粗细
        _RimLight ("边缘光亮度", Range(0, 3)) = 1    //亮度
        
	

        _faceFrontX("faceFrontX",Float)=0
        _faceFrontY("faceFrontY",Float)=0
        _faceFrontZ("faceFrontZ",Float)=1
        _faceUpX("faceUpX",Float)=0
        _faceUpY("faceUpY",Float)=1
        _faceUpZ("faceUpZ",Float)=0

        
        [Header(Outline Setting)]
        [Space(5)]
         [Toggle]_TANG("是否切线", float) = 0
        _OutlineWidth ("描边宽度", Range(0, 1)) = 0.5
        _OutlineColor ("描边颜色", color) = (0.4811321, 0.1050894, 0, 1.0)
        [HideInInspector]_OutlineZOffset ("_OutlineZOffset (View Space) (increase it if is face!)", Range(0, 1)) = 0.0001

       
       _Cutoff ("_Cutoff (Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "UniversalMaterialType" = "Lit" "Queue" = "Geometry-1" }

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #pragma multi_compile_fog
        #pragma shader_feature _TANG_ON
        #pragma multi_compile _ LOD_FADE_CROSSFADE

        TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);    SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);
        TEXTURE2D(_FaceShadowMap);  SAMPLER(sampler_FaceShadowMap);
		TEXTURE2D(_Outlinemask);    SAMPLER(sampler_Outlinemask);
        
        
        
        TEXTURE2D(_FXMap);       SAMPLER(sampler_FXMap);

		

        int _IsShadow;

        CBUFFER_START(UnityPerMaterial)

        float4 _BaseMap_ST;
        float4 _BaseColor;
        half _WorldLightInfluence;
        float4 _LightMap_ST;
        float4 _FaceShadowMap_ST;
        float _FaceShadowMapPow;
        float _FaceShadowOffset;
        float3 _ShadowMultColor;
        float _ShadowArea;
        half _ShadowSmooth;
        float _DarkShadowArea;
        float3 _DarkShadowMultColor;
        half _DarkShadowSmooth;
		half _Brightness;
		half _Saturation;
		half _Contrast;
		half _FaceVAlpha;
		int _EnableRim;
        half4 _RimColor;
        half _RimOffset;
        half _RimLight;
		float _faceFrontX,_faceFrontY, _faceFrontZ;
        float _faceUpX,_faceUpY,_faceUpZ;
        half4 _RampArea12;
        half4 _RampArea34;
        half2 _RampArea5;
        float _RampShadowRange;
        float _EnableSpecular;
        float4 _LightSpecColor;
        float _Shininess;
        float _SpecMulti;
        float _FixDarkShadow;
        float _IgnoreLightY;
        float _FixLightY;
        float _EnableLambert;
        float _RimSmooth;
        float _RimPow;
        float _EnableRimDS;
        half4 _DarkSideRimColor;
        float _DarkSideRimSmooth;
        float _DarkSideRimPow;
        float _EnableRimOther;
        half4 _OtherRimColor;
        float _OtherRimSmooth;
        float _OtherRimPow;
        
        float4 _BloomMap_ST;
        float _BloomFactor;
        float _EnableEmission;
        half3 _EmissionColor;
        float _Emission;
        float _EmissionBloomFactor;
        half _EmissionMulByBaseColor;
        half3 _EmissionMapChannelMask;

        half _ReceiveShadowMappingAmount;
        float _ReceiveShadowMappingPosOffset;

        float _OutlineWidth;
        half4 _OutlineColor;
        float _OutlineZOffset;

        float _HBrightness;
        float _Brightness222;
        half4 _lightcolor222;
        float _shadowst;
        half4 _eyescolor;
        half4 _eyesshadow;
        half4 _eyesshadowl;

        half _Cutoff;
        CBUFFER_END

        struct Attributes
        {
            float4 positionOS: POSITION;
            half4 color: COLOR0;
            half3 normalOS: NORMAL;
            half4 tangentOS: TANGENT;
            float4 texcoord: TEXCOORD0;
        };

        struct Varyings
        {
            float4 positionCS: POSITION;
            float4 color: COLOR0;
            float4 uv: TEXCOORD0;
            float3 positionWS: TEXCOORD1;
            float3 positionVS: TEXCOORD2;
            float3 normalWS: TEXCOORD3;
            float lambert: TEXCOORD4;
            float4 shadowCoord: TEXCOORD5;
			float3 worldTangent : TEXCOORD7;    //世界空间切线
            float3 worldBiTangent : TEXCOORD9;  //世界空间副切线
			float3 facevalpha      : TEXCOORD8;
            float4 positionNDC:TEXCOORD6;
            float fogCoord : TEXCOORD11;
        };

        

        Varyings ToonPassVertex(Attributes input)
        {
            Varyings output = (Varyings)0;
            output.color = input.color;
            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.normalWS = vertexNormalInput.normalWS;
			output.worldTangent = vertexNormalInput.tangentWS;
            output.worldBiTangent = vertexNormalInput.bitangentWS;
            VertexPositionInputs vertexInput =GetVertexPositionInputs(input.positionOS.xyz);
            output.positionNDC = vertexInput.positionNDC;
            output.positionWS = TransformObjectToWorld(input.positionOS);
            output.positionVS = TransformWorldToView(output.positionWS);
            output.positionCS = TransformWorldToHClip(output.positionWS);
            float3 lightDirWS = normalize(_MainLightPosition.xyz);
            float3 fixedlightDirWS = normalize(float3(lightDirWS.x, _FixLightY, lightDirWS.z));
            lightDirWS = _IgnoreLightY ? fixedlightDirWS: lightDirWS;
            float lambert = dot(output.normalWS, lightDirWS);
            output.lambert = lambert * 0.5f + 0.5f;

            output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
           


            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
            output.fogCoord = ComputeFogFactor(output.positionCS.z);
            return output;
        }

        half4 FragmentAlphaClip(Varyings input): SV_TARGET
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            #if ENABLE_ALPHA_CLIPPING
                clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).b - _Cutoff);
            #endif
            return 0;
        }
        ENDHLSL

        Pass
        {
            NAME "CHARACTER_BASE"

            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZTest LEqual
            ZWrite On
            Blend One Zero

            
            

            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            
            // #pragma shader_feature_local ENABLE_AUTOCOLOR

            #pragma vertex ToonPassVertex
            #pragma fragment ToonPassFragment

            half4 ToonPassFragment(Varyings input): COLOR
            {

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
                
				
			
				
                Light mainLight = GetMainLight();

                float3 shadowTestPosWS = input.positionWS + mainLight.direction * _ReceiveShadowMappingPosOffset;

                float hang=0.125*8;


                half4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv.xy);
				float2 ColorUV = float2(0.5, hang);
				
                

                    float sinx = sin(_FaceShadowOffset);
                    float cosx = cos(_FaceShadowOffset);
                    float2x2 rotationOffset = float2x2(cosx, -sinx, sinx, cosx);
                    
                    float3 Front = unity_ObjectToWorld._12_22_32;
                    float3 Right = unity_ObjectToWorld._13_23_33;
                    float2 lightDir = mul(rotationOffset, mainLight.direction.xz);

                    //计算xz平面下的光照角度
                    float FrontL = dot(normalize(Front.xz), normalize(lightDir));
                    float RightL = dot(normalize(Right.xz), normalize(lightDir));
                    RightL = - (acos(RightL) / PI - 0.5) * 2;

                    //左右各采样一次FaceLightMap的阴影数据存于lightData
					float3 rfaceLightMap = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(input.uv.x, input.uv.y)).r;
				    float3 faceLightMap = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(1-input.uv.x, input.uv.y)).r;
					float3 _Up = float3(_faceUpX,_faceUpY,_faceUpZ);
                    float3 _Front = float3(_faceFrontX,_faceFrontY,_faceFrontZ);
				    float4  c =SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(input.uv.x, input.uv.y));
                    float4  rc =SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(1-input.uv.x, input.uv.y));
                   
                    
                    float4  FXMap =SAMPLE_TEXTURE2D(_FXMap, sampler_FXMap, input.uv);
                    

					  float3 _Left = cross(_Up,_Front);
                    float3 _Right = -_Left;
				    //光线与模型正前的夹角余弦
                    float FL = dot(normalize(_Front.xz), normalize(lightDir)) * 0.5 + 0.5;
                    //光线与模型正左的夹角余弦
                    float LL = dot(normalize(_Left.xz), normalize(lightDir)) * 0.5 + 0.5;
                    //光线与模型正右的夹角余弦
                    float RL = dot(normalize(_Right.xz), normalize(lightDir)) * 0.5 + 0.5;
					float faceLightRightFace =faceLightMap;
                    float faceLightLeftFace = rfaceLightMap;
					
					float valueToSample =RL-LL<0?faceLightRightFace:faceLightLeftFace;

                    valueToSample+=0.01;


                    //将阈值图上的值和1-FL比较,
                    float shadowth=1-FL;
                    
              	    //FL<0即光线射向背面的情况，这种情况下result为0.
                    float result =smoothstep(shadowth-_shadowst,shadowth+_shadowst,valueToSample);



                
				

                    float3 Diffuse = lerp( _ShadowMultColor*baseColor,baseColor,result);


                    float2 lightData = float2(LL,RL);

                    float shadow = MainLightRealtimeShadow(input.shadowCoord); 
                
                    float3 oshadow = float3(shadow,shadow,shadow);
                
                    oshadow =lerp(_ShadowMultColor,1,oshadow);

                    float3 FinalRamp;


                    if ( shadow<result &&_IsShadow == 1.0)//若处于阴影中
                    FinalRamp =oshadow *Diffuse;
                    else
                    FinalRamp = Diffuse;

                half3 viewDir = normalize(_WorldSpaceCameraPos - input.positionWS);
                float3 V=viewDir;
                float3 N=normalize(input.normalWS);
                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V,N));
                float NoV=dot(N,V);

                float rimOffset=_RimOffset*6;//宽度
                float rimThreshold=0.03;
                float rimStrength=0.6;
                float rimMax=0.3;

                float2 screenUV=input.positionNDC.xy/input.positionNDC.w;
                float rawDepth=SampleSceneDepth(screenUV);
                float linearDepth=LinearEyeDepth(rawDepth,_ZBufferParams);
                float2 screenOffset= float2(lerp(-1,1,step(0,normalVS.x))*rimOffset/_ScreenParams.x/max(1,pow(linearDepth,2)),0);
                float offsetDepth=SampleSceneDepth(screenUV+screenOffset);
                float offsetLinearDepth=LinearEyeDepth(offsetDepth,_ZBufferParams);
                float rim=saturate(offsetLinearDepth-linearDepth);
                rim=step(rimThreshold,rim)*clamp(rim*rimStrength,0,rimMax)* _EnableRim;


                float3 FinalColor1 = rim*_RimLight+FinalRamp;

                float fakeoutline=c.b;
                float3 headForward=normalize(_Front);              
                float fakeoutlineeffect=smoothstep(0,0.25,pow(saturate(dot(headForward,viewDir)),20)*fakeoutline*_OutlineColor);
                
                
                 float4   FinalColor = float4(FinalColor1,1);

                // float elsemap =saturate(step(0.33,input.uv.x)+step(input.uv.x,0.22));
                float2 mask233=input.uv;
                float4 elsemap=float4(mask233.x, mask233.y, 0.0, 1.0);


                float4 elsemap0=saturate(step(0.33,elsemap.g)+step(elsemap.g,0.22)+step(0.1,elsemap.r)+step(elsemap.r,0));//眼珠高光部分
                float4 elsemap1=saturate(step(0.28,elsemap.g)+step(elsemap.g,0.22)+step(1,elsemap.r)+step(elsemap.r,0.87));//眼睛阴影
                float4 elsemap2=saturate(step(0.388,elsemap.g)+step(elsemap.g,0.308)+step(1,elsemap.r)+step(elsemap.r,0.87));//眼内半透

                float mask=saturate(elsemap1*elsemap2);

                

                 FinalColor =lerp(FinalColor,FinalColor*_lightcolor222*_Brightness222,result);//亮面颜色
                 
					FinalColor=FinalColor*_BaseColor*_Brightness;

				    half gray = 0.2125 * _BaseColor.r + 0.7154 * _BaseColor.g + 0.0721 * _BaseColor.b;
                    
			        half3 grayColor = half3(gray, gray, gray);
				    //根据Saturation在饱和度最低的图像和原图之间差值
			        FinalColor.rgb = lerp(grayColor, FinalColor, _Saturation);
                     FinalColor=lerp(float4(oshadow,1) *baseColor*_eyescolor,FinalColor,FXMap.a);//A通道排除眼睛

				     //contrast对比度：首先计算对比度最低的值
			        half3 avgColor = half3(0.5, 0.5, 0.5);
			         //根据Contrast在对比度最低的图像和原图之间差值
			        FinalColor.rgb = lerp(avgColor, FinalColor, _Contrast);

               //     FinalColor=lerp(FinalColor,fakeoutlineeffect,fakeoutline);//鼻子勾线
                    FinalColor.rgb = MixFog(FinalColor.rgb, input.fogCoord);//混合fog

                    clip(mask-0.5);
                
					
			

                return FinalColor;
                //return  elsemap2;
                
                
            }
            ENDHLSL

        }

          Pass {
            Name "eyeshadow"
            Tags{ "LightMode" = "UniversalForwardOnly" }
            Cull back
            ZTest on
            Blend SrcAlpha OneMinusSrcAlpha
            zwrite off
        Stencil{
                Ref 222
                Comp gEqual
                Pass replace
            }
	    HLSLPROGRAM
	    #pragma vertex vert  
	    #pragma fragment frag
	    Varyings vert(Attributes input) 
        {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
                return output;
	     }
	     float4 frag(Varyings input) : SV_Target {

            
               float2 mask233=input.uv;
                float4 elsemap=float4(mask233.x, mask233.y, 0.0, 1.0);
                float4 elsemap1=1-saturate(step(0.28,elsemap.g)+step(elsemap.g,0.22)+step(1,elsemap.r)+step(elsemap.r,0.87));//眼睛阴影
                float4 elsemap2=1-saturate(step(0.388,elsemap.g)+step(elsemap.g,0.308)+step(1,elsemap.r)+step(elsemap.r,0.87));//眼内半透阴影
                float4 final=elsemap1*_eyesshadow+elsemap2*_eyesshadowl;
               return final;
	     }
	     ENDHLSL

        }
/*
         Pass {
            Name "eyeshighlight"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            Cull back
            ZTest on
            Blend SrcAlpha OneMinusSrcAlpha
            zwrite on
        Stencil{
                Ref 221
                Comp gEqual
                Pass replace
            }
	    HLSLPROGRAM
	    #pragma vertex vert  
	    #pragma fragment frag
	    Varyings vert(Attributes input) 
        {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
                return output;
	     }
	     float4 frag(Varyings input) : SV_Target {

          
               float2 mask233=input.uv;
                float4 elsemap=float4(mask233.x, mask233.y, 0.0, 1.0);
                float4 elsemap2=saturate(step(0.388,elsemap.g)+step(elsemap.g,0.308)+step(1,elsemap.r)+step(elsemap.r,0.87));//眼内半透
                    

               return elsemap2*_eyesshadowl;
	     }
	     ENDHLSL

        }

*/



       
       

      

        Pass {
            Name "OutLine"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
	    Cull front
        ZTest on
        //Offset [_OffsetFactor], [_OffsetUnits]
        zwrite on
        Stencil{
                Ref 222
                Comp always
                Pass replace
            }
	    HLSLPROGRAM
	    #pragma vertex vert  
	    #pragma fragment frag
	    Varyings vert(Attributes input) 
        {
             //   float4 scaledScreenParams = GetScaledScreenParams();
             //   float ScaleX = abs(scaledScreenParams.x / scaledScreenParams.y);//求得X因屏幕比例缩放的倍数
		Varyings output;
		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
              
                
                output.positionCS = vertexInput.positionCS;
      

                float3 fixedVerterxNormal ;
                #if _TANG_ON
                fixedVerterxNormal= input.tangentOS;
                #else
                fixedVerterxNormal= input.normalOS;
                #endif
                
                float3 positionVS = mul(UNITY_MATRIX_MV, input.positionOS).xyz;
                float viewDepth = abs(positionVS.z);
                float4 viewPos = mul(UNITY_MATRIX_MV,  input.positionOS);
                float4 vert = viewPos / viewPos.w;
                float s = -(viewPos.z / unity_CameraProjection[1].y);
                float power = pow(s, 0.5);
                float3 viewSpaceNormal = mul(UNITY_MATRIX_IT_MV, fixedVerterxNormal);
                viewSpaceNormal.z = 0.01;
	            viewSpaceNormal = normalize(viewSpaceNormal);
                float width;

                output.uv=input.texcoord;
                float2 Set_UV0 = output.uv;
                float4 _OutlineWTEX = _FaceShadowMap.SampleLevel(sampler_FaceShadowMap,TRANSFORM_TEX(Set_UV0, _FaceShadowMap),0.0);//贴图决定描边宽度


            
	            //width = power*(_OutlineWidth/100)*input.color.a*otl2;
                width = power*(_OutlineWidth/100)*_OutlineWTEX.b;
               

                vert.xy += viewSpaceNormal.xy *width;
                vert = mul(UNITY_MATRIX_P, vert);

                

         
                output.positionCS.xy = vert;
                return output;
	     }
	     float4 frag(Varyings input) : SV_Target {
            
           // float c=SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, input.uv).b;

            return float4(_OutlineColor.rgb, 1);
	     }
	     ENDHLSL

        }
        

        Pass
        {
            
            Tags { "LightMode" = "ShadowCaster" }

        }
         Pass
        {
            Tags{"LightMode"="DepthNormals" }
        }

        UsePass "Universal Render Pipeline/Unlit/DepthOnly"
   
    }
}
