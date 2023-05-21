Shader "xavion-lux/HRDisplaySingle"
{
    Properties
    {
        _HeartCutoff("Heart Cutoff", Range(0, 1)) = 0.5
        [NoscaleOffset] _HeartTex ("Heart Texture", 2D) = "" {}
        _NumberCutoff("Number Cutoff", Range(0, 1)) = 0.5
        [NoscaleOffset] _NumberTex ("Number Texture", 2D) = "" {}
        [NoscaleOffset] _NumberMaskTex ("Number Mask", 2D) = "white" {}
        _BPM ("BPM", Range(0, 255)) = 0
    }

    SubShader
    {
        Tags
        { 
            "Queue" = "Transparent"
            "RenderType" = "TransparentCutout"
            "DisableBatching" = "False"
            "IgnoreProjector" = "True"
            "PreviewType" = "Plane"
        }

		CGINCLUDE
        struct appdata
        {
            half4 vertex : POSITION;
            half2 uv : TEXCOORD0;
        };

        struct v2f
        {
            half4 vertex : SV_POSITION;
            half2 uv : TEXCOORD0;   // used for the number
            half2 uv1 : TEXCOORD1;  // used for the alpha mask
            int place : TEXCOORD2;  // used to pass the place (0: hundreds, 1: tens, 2: units) we want to draw and avoid calculating it twice
        };

        // scale the UV to the desired size
        half2 scale(half2 uv, half scale)
        {
            return (uv - half(0.5)) * scale + half(0.5);
        }

        // offset the UV for the number texture for the desired decimal place (0: hundreds, 1: tens, 2: units)
        half2 offsetNumber(half2 uv, uint place, half digit)
        {
            uv.x += half(0.11) - half(0.063) * place + digit / 10;
            return uv;
        }

        // offset the UV for the alpha mask for the desired decimal place (0: hundreds, 1: tens, 2: units)
        half2 offsetMask(half2 uv, uint place)
        {
            uv.x += half(0.4) - place * half(0.20);
            return uv;
        }

        // returns the value for the desired decimal place (0: hundreds, 1: tens, 2: units)
        uint getDigit(uint bpm, uint place)
        {
            uint div = 100;
            for (uint i = 0; i < place; i++)
            {
                div /= 10;
            }
            return (bpm / div) % 10;
		}

        uint _BPM;

        // manipulate the UV for the vert shader to select the desired digit
        v2f vertNumber(appdata v, uint place)
        {
            v2f o;
            o.uv1 = offsetMask(v.uv, place);
            o.place = place;
            o.vertex = UnityObjectToClipPos(v.vertex);
            v.uv = scale(v.uv, 3);
            v.uv.x *= half(0.1); // Tiling
            o.uv = offsetNumber(v.uv, place, getDigit(_BPM, place));
            return o;
        }

        UNITY_DECLARE_TEX2D(_NumberTex);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_NumberMaskTex);
        fixed _NumberCutoff;

        // draw the number in the frag shader
        fixed4 fragNumber(v2f i)
        {
            fixed4 col = UNITY_SAMPLE_TEX2D(_NumberTex, i.uv);
            col.r *= half(0.5);
            col.g *= half(0.5);
            col.b *= half(0.5);
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
                return vertNumber(v, 0);
            }

            fixed4 frag(v2f i) : SV_Target
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
                return vertNumber(v, 1);
            }

            fixed4 frag(v2f i) : SV_Target
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
                return vertNumber(v, 2);
            }

            fixed4 frag(v2f i) : SV_Target
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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				
                half targetscale = sin(_Time * _BPM * 2) * half(0.8) + 4;

				
                v.uv += half2(-0.325, -0.015);
                o.uv = scale(v.uv, targetscale);
                
                return o;
            }

            half _HeartCutoff;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed m = sin(_Time * _BPM * 2 + fixed(3.14))/2 + fixed(0.7);
                fixed4 col = UNITY_SAMPLE_TEX2D(_HeartTex, i.uv);
                col.r *= m;
                col.g *= m;
                col.b *= m;
                col.a = UNITY_SAMPLE_TEX2D(_HeartTex, i.uv).a < _HeartCutoff ? 0 : 1;
                return col;
            }
            ENDCG
        }
    }

    // this isn't working????
    Fallback "Transparent/Diffuse"
}
