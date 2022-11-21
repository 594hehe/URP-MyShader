Shader "URP_FACE"
{
    Properties
    {
        [Header(Main Texture Setting)]
        [Space(5)]
        [Toggle] _IsShadow ("外部阴影", int) = 1
        [HDR][MainColor]_BaseColor ("BaseColor", Color) = (1, 0.7519709, 0.6477987, 1)
		[MainTexture]_BaseMap ("BaseMap (Albedo)", 2D) = "black" { }
		_FaceShadowMap ("Face Shadow Map", 2D) = "white" { }
		_Ramp2 ("Ramp2color", 2D) = "white" { }
		//_FaceVAlpha ("顶点Alpha", 2D) = "white" { }
        [HDR]_ShadowMultColor ("Shadow Color", color) = (1, 0.7232704, 0.7232704, 1) 
		_Brightness("亮度", Float) = 1.5    //调整亮度
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
        _OutlineWidth ("描边宽度", Range(0, 1)) = 0.5
        _OutlineColor ("描边颜色", color) = (0.5283019, 0.3737931, 0, 1)
        [HideInInspector]_OutlineZOffset ("_OutlineZOffset (View Space) (increase it if is face!)", Range(0, 1)) = 0.0001

       [HideInInspector] [Toggle(ENABLE_ALPHA_CLIPPING)]_EnableAlphaClipping ("_EnableAlphaClipping", Float) = 0
       [HideInInspector]_Cutoff ("_Cutoff (Alpha Cutoff)", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "UniversalMaterialType" = "Lit" "Queue" = "Geometry" }

        HLSLINCLUDE

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

        TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
		TEXTURE2D(_Ramp2);          SAMPLER(sampler_Ramp2);
        TEXTURE2D(_EmissionMap);    SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);
        TEXTURE2D(_FaceShadowMap);  SAMPLER(sampler_FaceShadowMap);
		//TEXTURE2D(_FaceVAlpha);     SAMPLER(sampler_FaceVAlpha);
		TEXTURE2D(_Outlinemask);    SAMPLER(sampler_Outlinemask);
        TEXTURE2D(_RampMap);        SAMPLER(sampler_RampMap);
        TEXTURE2D(_BloomMap);       SAMPLER(sampler_BloomMap);
        TEXTURE2D(_MetalMap);       SAMPLER(sampler_MetalMap);
		

        int _IsShadow;

        CBUFFER_START(UnityPerMaterial)

        float4 _BaseMap_ST;
		//float4 _Ramp2_ST;
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

        half _Cutoff;
        CBUFFER_END

        struct Attributes
        {
            float3 positionOS: POSITION;
            half4 color: COLOR0;
            half3 normalOS: NORMAL;
            half4 tangentOS: TANGENT;
            float2 texcoord: TEXCOORD0;
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
        };

        float GetCameraFOV()
        {
            float t = unity_CameraProjection._m11;
            float Rad2Deg = 180 / 3.1415;
            float fov = atan(1.0f / t) * 2.0 * Rad2Deg;
            return fov;
        }
        float ApplyOutlineDistanceFadeOut(float inputMulFix)
        {
            return saturate(inputMulFix);
        }
        float GetOutlineCameraFovAndDistanceFixMultiplier(float positionVS_Z)
        {
            float cameraMulFix;
            if (unity_OrthoParams.w == 0)
            {
                cameraMulFix = abs(positionVS_Z);
                cameraMulFix = ApplyOutlineDistanceFadeOut(cameraMulFix);
                cameraMulFix *= GetCameraFOV();
            }
            else
            {
                float orthoSize = abs(unity_OrthoParams.y);
                orthoSize = ApplyOutlineDistanceFadeOut(orthoSize);
                cameraMulFix = orthoSize * 50;
            }

            return cameraMulFix * 0.0001;
        }
		

        float3 TransformPositionWSToOutlinePositionWS(half vertexColorAlpha, float3 positionWS, float positionVS_Z, float3 normalWS)
        {
			//float3 facevalpha = SAMPLE_TEXTURE2D(_FaceVAlpha, sampler_FaceVAlpha, float2(input.uv.x, input.uv.y));
			
            float outlineExpandAmount = vertexColorAlpha * _OutlineWidth * GetOutlineCameraFovAndDistanceFixMultiplier(positionVS_Z);
            return positionWS + normalWS * outlineExpandAmount;
        }


        Varyings OutlinePassVertex(Attributes input)
        {
            Varyings output = (Varyings)0;
            output.color = input.color;

            VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
            output.normalWS = vertexNormalInput.normalWS;

            output.positionWS = TransformObjectToWorld(input.positionOS);
            output.positionVS = TransformWorldToView(output.positionWS);
            output.positionCS = TransformWorldToHClip(output.positionWS);

            // #ifdef ToonShaderIsOutline
            output.positionWS = TransformPositionWSToOutlinePositionWS(input.color.a, output.positionWS, output.positionVS.z, output.normalWS);
            // #endif
            output.positionCS = TransformWorldToHClip(output.positionWS);
            
            float3 lightDirWS = normalize(_MainLightPosition.xyz);
            float3 fixedlightDirWS = normalize(float3(lightDirWS.x, _FixLightY, lightDirWS.z));
            lightDirWS = _IgnoreLightY ? fixedlightDirWS: lightDirWS;

            float lambert = dot(output.normalWS, lightDirWS);
            output.lambert = lambert * 0.5f + 0.5f;

            output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
            output.uv.zw = TRANSFORM_TEX(input.texcoord, _BloomMap);

            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
            return output;
        }

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
            output.uv.zw = TRANSFORM_TEX(input.texcoord, _BloomMap);

            output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
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


                half4 LightMapColor = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv.xy);
				float2 ColorUV = float2(0.35, 0.85);
				half3 rampColor = SAMPLE_TEXTURE2D(_Ramp2, sampler_Ramp2, ColorUV).rgb;
                

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
					float3 rfaceLightMap = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(input.uv.x, input.uv.y));
				    float3 faceLightMap = SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, float2(1-input.uv.x, input.uv.y));
					float3 _Up = float3(_faceUpX,_faceUpY,_faceUpZ);
                    float3 _Front = float3(_faceFrontX,_faceFrontY,_faceFrontZ);
				    float4  c =SAMPLE_TEXTURE2D(_FaceShadowMap, sampler_FaceShadowMap, input.uv);
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
                    //将阈值图上的值和1-FL比较,
                    bool isShadow=(valueToSample>1-FL);
                    //三目运算符  判断FL是否大于0
              	    //FL<0即光线射向背面的情况，这种情况下result为0.
                    bool result =FL>0?isShadow:0;
				

                    float3 Diffuse = lerp( _ShadowMultColor*baseColor*rampColor,baseColor,result);
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
                
                
                 float4   FinalColor = float4(FinalColor1,1);
					FinalColor=FinalColor*_BaseColor*_Brightness;

				    half gray = 0.2125 * _BaseColor.r + 0.7154 * _BaseColor.g + 0.0721 * _BaseColor.b;
			        half3 grayColor = half3(gray, gray, gray);
				    //根据Saturation在饱和度最低的图像和原图之间差值
			        FinalColor.rgb = lerp(grayColor, FinalColor, _Saturation);
				     //contrast对比度：首先计算对比度最低的值
			        half3 avgColor = half3(0.5, 0.5, 0.5);
			         //根据Contrast在对比度最低的图像和原图之间差值
			        FinalColor.rgb = lerp(avgColor, FinalColor, _Contrast);
					
			

                return FinalColor;
                
                
            }
            ENDHLSL

        }
        Pass
        {
            Name "CHARACTER_OUTLINE"
            Tags {  }
            Cull Front
            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            // #pragma shader_feature_local ENABLE_AUTOCOLOR
            #pragma shader_feature_local_fragment ENABLE_ALPHA_CLIPPING

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment
			

            float4 OutlinePassFragment(Varyings input): COLOR
            {
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
                half4 FinalColor = _OutlineColor * baseColor;

                return FinalColor;
            }

            ENDHLSL

        }
        Pass
        {
            //Name "ShadowCaster"
            //Tags { "LightMode" = "ShadowCaster" }

            //ZWrite On
            //ZTest LEqual
            //ColorMask 0
            //Cull Off

           // HLSLPROGRAM

           // #pragma vertex OutlinePassVertex
           // #pragma fragment FragmentAlphaClip

           // ENDHLSL

        }
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment FragmentAlphaClip
            
            ENDHLSL

        }
    }
}
