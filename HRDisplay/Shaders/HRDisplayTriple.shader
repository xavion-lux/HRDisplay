Shader "xavion-lux/HRDisplayTriple"
{
    Properties
    {
        _HeartCutoff("Heart Cutoff", Range(0, 1)) = 0.5
        [NoscaleOffset] _HeartTex ("Heart Texture", 2D) = "" {}
        _NumberCutoff("Number Cutoff", Range(0, 1)) = 0.5
        [NoscaleOffset] _NumberTex ("Number Texture", 2D) = "" {}
        [NoscaleOffset] _NumberMaskTex ("Number Mask", 2D) = "white" {}
        _Units ("Units", Range(0, 9)) = 0
        _Tens ("Tens", Range(0, 9)) = 0
        _Hundreds ("Hundreds", Range(0, 9)) = 0
        [Toggle] _HideLeadingZeros ("Hide Leading Zeros", Float) = 0
    }

    SubShader
    {
        ZWrite off

        Tags
        { 
            "Queue" = "Transparent"
            "RenderType" = "TransparentCutout"
            "DisableBatching" = "False"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
            "VRCFallback"="Hidden"
        }

		CGINCLUDE
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;   // used for the number
            float2 uv1 : TEXCOORD1;  // used for the alpha mask
            float place : TEXCOORD2;  // used to pass the place (0: hundreds, 1: tens, 2: units) we want to draw and avoid calculating it twice
            float bpm : TEXCOORD3;   // used to pass the bpm to the pixel shader for the heart pass
        };

        // scale the UV to the desired size
        float2 scale(float2 uv, float scale)
        {
            return (uv - 0.5) * scale + 0.5;
        }

        // offset the UV for the number texture for the desired decimal place (0: hundreds, 1: tens, 2: units)
        float2 offsetNumber(float2 uv, uint place, uint digit)
        {
            uv.x += 0.11 - 0.063 * place + digit / 10.0;
            return uv;
        }

        // offset the UV for the alpha mask for the desired decimal place (0: hundreds, 1: tens, 2: units)
        float2 offsetMask(float2 uv, float place)
        {
            uv.x += 0.4 - place * 0.20;
            return uv;
        }

        // legacy code
        // returns the value for the desired decimal place (0: hundreds, 1: tens, 2: units)
        float getDigit(uint bpm, float place)
        {
            uint div = 100;
            for (float i = 0; i < place; i++)
            {
                div /= 10;
            }
            return (bpm / div) % 10;
		}

        float _Units;
        float _Tens;
        float _Hundreds;

        // manipulate the UV for the vert shader to select the desired digit
        v2f vertNumber(appdata v, uint place, uint digit)
        {
            v2f o;
            o.uv1 = offsetMask(v.uv, place);
            o.place = place;
            o.vertex = UnityObjectToClipPos(v.vertex);
            v.uv = scale(v.uv, 3);
            v.uv.x *= 0.1; // Tiling
            o.uv = offsetNumber(v.uv, place, digit);
            return o;
        }

        UNITY_DECLARE_TEX2D(_NumberTex);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_NumberMaskTex);
        float _HideLeadingZeros;
        float _NumberCutoff;

        // draw the number in the frag shader
        float4 fragNumber(v2f i)
        {
            float4 col = UNITY_SAMPLE_TEX2D(_NumberTex, i.uv);
            col.r *= 0.5;
            col.g *= 0.5;
            col.b *= 0.5;
            col.a *= _HideLeadingZeros == 1 && ((i.place == 0 && _Hundreds < 1) || (i.place == 1 && _Tens < 1)) ? 0 : 1;
            col.a *= UNITY_SAMPLE_TEX2D_SAMPLER(_NumberMaskTex, _NumberTex, i.uv1).a < _NumberCutoff ? 0 : 1;
            return col;
        }
        ENDCG

        // draw the hundreds
        Pass
        {
            Name "Hundreds"
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add
            Cull Back

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                return vertNumber(v, 0, _Hundreds);
            }

            float4 frag(v2f i) : SV_Target
            {
                return fragNumber(i);
            }
            ENDCG
        }

        // draw the tens
        Pass
        {
            Name "Tens"
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add
            Cull Back

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata v)
            {
                return vertNumber(v, 1, _Tens);
            }

            float4 frag(v2f i) : SV_Target
            {
                return fragNumber(i);
            }
            ENDCG
        }

        // draw the units
        Pass
        {
            Name "Units"
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add
            Cull Back

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata v)
            {
                return vertNumber(v, 2, _Units);
            }

            float4 frag(v2f i) : SV_Target
            {
                return fragNumber(i);
            }
            ENDCG
        }
		
        // draw the heart
        Pass
        {
            Name "Heart"
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add
            Cull Back

            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            UNITY_DECLARE_TEX2D(_HeartTex);

            uint bpm = 0;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				
                o.bpm = _Hundreds * 100 + _Tens * 10 + _Units;

                float targetscale = 4 - (pow(abs(sin(_Time * o.bpm)), 20) + pow(abs(sin(_Time * o.bpm - 1.1)), 10) * 0.5);

				
                v.uv += float2(-0.325, -0.015);
                o.uv = scale(v.uv, targetscale);
                
                return o;
            }

            float _HeartCutoff;

            float4 frag(v2f i) : SV_Target
            {
                float m = (pow(abs(sin(_Time * i.bpm + 3.14)), 15) + pow(abs(sin(_Time * i.bpm + 3.14 - 1.1)), 10) * 0.5)*0.7 + 0.35;
                float4 col = UNITY_SAMPLE_TEX2D(_HeartTex, i.uv);
                col.r *= m;
                col.g *= m;
                col.b *= m;
                col.a = UNITY_SAMPLE_TEX2D(_HeartTex, i.uv).a < _HeartCutoff ? 0 : 1;
                return col;
            }
            ENDCG
        }
    }
}
