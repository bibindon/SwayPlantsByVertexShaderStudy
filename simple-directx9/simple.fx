float4x4 g_matWorldViewProj;
float4 g_lightNormal = { 0.3f, 1.0f, 0.5f, 0.0f };

// �h�炵�G�t�F�N�g�p�p�����[�^
float g_time = 0.0f;
float g_swayAmount = 0.5f;
float g_swaySpeed = 2.0f;

texture texture1;
sampler textureSampler = sampler_state
{
    Texture = (texture1);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

void VertexShader1(in float4 inPosition : POSITION,
                   in float4 inNormal : NORMAL0,
                   in float4 inTexCood : TEXCOORD0,

                   out float4 outPosition : POSITION,
                   out float4 outDiffuse : COLOR0,
                   out float4 outTexCood : TEXCOORD0)
{
    float4 pos = inPosition;
    
    // �h�炵�G�t�F�N�g��K�p
    // Y���W�̍����Ɋ�Â��ėh�炵�̋��x��ς���i��ɂ����قǑ傫���h���j
    float heightFactor = (pos.y + 2.5) / 5.0; // �~���̍����ɍ��킹�Ē���
    heightFactor = pow(heightFactor, 4.0);
    heightFactor = clamp(heightFactor, 0.0, 1.0);
    
    // �����̔g��g�ݍ��킹�Ď��R�ȗh�炵���쐬
    float wave1 = sin(g_time * g_swaySpeed) * g_swayAmount;
    float wave2 = sin(g_time * g_swaySpeed * 0.7 + 1.5) * g_swayAmount * 0.5;
    float wave3 = cos(g_time * g_swaySpeed * 1.3 + 2.0) * g_swayAmount * 0.3;
    
    // X����Z���̗������ɗh�炵��K�p
    float swayX = (wave1 + wave2 + wave3) * heightFactor;
    float swayZ = (sin(g_time * g_swaySpeed * 0.8 + 0.5) * g_swayAmount * 0.7 +
                   cos(g_time * g_swaySpeed * 1.1 + 1.0) * g_swayAmount * 0.4) * heightFactor;
    
    pos.x += swayX;
    pos.z += swayZ;
    
    outPosition = mul(pos, g_matWorldViewProj);

    // ���C�e�B���O�v�Z�i�@�����h�炵�ɍ��킹�Ē����j
    float4 normal = inNormal;
    
    // �h�炵�ɂ��@���̕ω����ߎ��i�ȒP�ȕ��@�j
    float normalOffsetX = (wave1 + wave2 * 0.5) * heightFactor * 0.1;
    float normalOffsetZ = (swayZ / g_swayAmount) * heightFactor * 0.1;
    normal.x += normalOffsetX;
    normal.z += normalOffsetZ;
    normal = normalize(normal);
    
    float lightIntensity = dot(normal, g_lightNormal);
    outDiffuse.rgb = max(0.3, lightIntensity); // �Œ���̖��邳���m��
    outDiffuse.a = 1.0f;

    outTexCood = inTexCood;
}

void PixelShader1(in float4 inScreenColor : COLOR0,
                  in float2 inTexCood : TEXCOORD0,

                  out float4 outColor : COLOR)
{
    float4 workColor = (float4) 0;
    workColor = tex2D(textureSampler, inTexCood);
    outColor = inScreenColor * workColor;
}

technique Technique1
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 VertexShader1();
        PixelShader = compile ps_2_0 PixelShader1();
    }
}