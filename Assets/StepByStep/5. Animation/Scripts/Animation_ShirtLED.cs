using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Animation_ShirtLED : MonoBehaviour
{
    public float textureSpeed = 1.0f;
    public List<Texture2D> m_Textures = new List<Texture2D>();

    public float colorSpeed = 1.0f;
    public Gradient m_ColorGradient = new Gradient();

    private MaterialPropertyBlock m_PropertyBlock = null;
    private SkinnedMeshRenderer m_MeshRenderer = null;
    
    // Start is called before the first frame update
    void Start()
    {
        m_PropertyBlock = new MaterialPropertyBlock();
        m_MeshRenderer = GetComponent<SkinnedMeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        // Animate the texture
        float textureTime = Mathf.Sin(Time.time * textureSpeed) * 0.5f + 0.5f;
        float textureStep = 1.0f / m_Textures.Count;

        Texture2D texture = null;
        for (int i = 0; i < m_Textures.Count; i++)
        {
            if (textureTime < textureStep * (i + 1))
            {
                texture = m_Textures[i];
                break;
            }
        }

        texture = texture ? texture : Texture2D.blackTexture;
        m_PropertyBlock.SetTexture("_MainTex", texture);
        m_PropertyBlock.SetTexture("_ShadowColor1st", texture);
        m_PropertyBlock.SetTexture("_ShadowColor2nd", texture);

        // Animate the color
        float colorTime = Mathf.Sin(Time.time * colorSpeed) * 0.5f + 0.5f;

        Color color = m_ColorGradient.Evaluate(colorTime);
        m_PropertyBlock.SetColor("_Color", color);
        m_PropertyBlock.SetColor("_ShadowColor1st", color);
        m_PropertyBlock.SetColor("_ShadowColor2nd", color);

        if (m_MeshRenderer)
        {
            m_MeshRenderer.SetPropertyBlock(m_PropertyBlock);
        }
    }
}
