Shader "ToonLit/Outline"
{
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" {}
        [Toggle]_ENABLE_ALPHA_TEST("Enable AlphaTest",float)=0
        _Cutoff("Cutoff", Range(0,1)) = 0.5
        _OutlineWidth("OutlineWidth", Range(0, 1)) = 0.4
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)

        [Toggle]_TANG("是否切线", float) = 0
    

        [Toggle]_FACE("FACE", float) = 0
        
    }
    SubShader
    {
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"         
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
            #pragma shader_feature _ENABLE_ALPHA_TEST_ON
           #pragma shader_feature _TANG_ON
            #pragma shader_feature _FACE_ON
            CBUFFER_START(UnityPerMaterial)
                float _Cutoff;
                float _OutlineWidth;
                float4 _OutlineColor;
                float _Outlinenear;
                float _Outlinefar;
                float _OffsetX;
                float _OffsetY;
            CBUFFER_END
            TEXTURE2D(_BaseMap);                 SAMPLER(sampler_BaseMap);
            struct Attributes{
                float4 positionOS : POSITION;
                float4 normalOS : NORMAL;
                float4 texcoord : TEXCOORD;
                float4 vertColor : COLOR;
                float4 tangent : TANGENT;
            };
            struct Varyings{
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD1;
            };
        ENDHLSL
        Pass 
        {
            Tags{"LightMode" = "UniversalForward"} 
            Cull off
            Stencil{
                Ref 223
                Comp always
                Pass replace
            }
            HLSLPROGRAM
	    #pragma target 3.0
            #pragma vertex Vertex
            #pragma fragment Frag
            Varyings Vertex(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.uv = input.texcoord.xy;
                return output;
            }
            float4 Frag(Varyings input):SV_Target
            {
                float4 BaseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv);
                #if _ENABLE_ALPHA_TEST_ON
                    clip(BaseMap.a-_Cutoff);
                #endif
                return BaseMap;
            }
            ENDHLSL
        }
        Pass {
            Name "OutLine"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
	    Cull front
        Stencil{
                Ref 222
                Comp always
                Pass replace
            }
	    HLSLPROGRAM
	    #pragma vertex vert  
	    #pragma fragment frag
	    Varyings vert(Attributes input) {
                float4 scaledScreenParams = GetScaledScreenParams();
                float ScaleX = abs(scaledScreenParams.x / scaledScreenParams.y);//求得X因屏幕比例缩放的倍数
		Varyings output;
		VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                float3 normalCS = TransformWorldToHClipDir(normalInput.normalWS);//法线转换到裁剪空间
                
                
                
                output.positionCS = vertexInput.positionCS;
      

                float3 fixedVerterxNormal ;
                #if _TANG_ON
                fixedVerterxNormal= input.tangent;
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

                #if _FACE_ON
	            width = power*(_OutlineWidth/100)*input.vertColor.a*(1-saturate(input.vertColor.b*2));
                #else
                width = power*(_OutlineWidth/100)*input.vertColor.a;
                #endif

                vert.xy += viewSpaceNormal.xy *width;
                vert = mul(UNITY_MATRIX_P, vert);

                

         
                    output.positionCS.xy = vert;
              
		return output;
	     }
	     float4 frag(Varyings input) : SV_Target {
                 return float4(_OutlineColor.rgb, 1);
	     }
	     ENDHLSL
         }
    }
    Fallback "Universal Render Pipeline/Lit"
}
