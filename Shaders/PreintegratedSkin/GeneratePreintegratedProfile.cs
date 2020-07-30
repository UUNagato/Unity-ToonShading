using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;


public class GeneratePreintegratedProfile : MonoBehaviour
{
    public ComputeShader m_ComputeShader;
    private bool m_Once = false;
    // Start is called before the first frame update

    private void Start() {
        Debug.Log(SystemInfo.supportsComputeShaders);
    }

    private void Update() {
        if (Input.GetKeyUp(KeyCode.K)) {
            if (m_ComputeShader != null && !m_Once) {
                Debug.Log("Start compute shader");
                int width = 256, height = 256;
                int kernalHandle = m_ComputeShader.FindKernel("CSMain");
                RenderTexture tex = new RenderTexture(width, height, 24, RenderTextureFormat.ARGBFloat);
                tex.enableRandomWrite = true;
                tex.Create();

                m_ComputeShader.SetTexture(kernalHandle, "Result", tex);
                m_ComputeShader.Dispatch(kernalHandle, width / 8, height / 8, 1);
                RenderTexture tmp = RenderTexture.active;

                Texture2D export = new Texture2D(width, height, TextureFormat.RGBAFloat, false);
                RenderTexture.active = tex;
                export.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
                export.Apply();

                RenderTexture.active = tmp;
                File.WriteAllBytes("LUT.exr", export.EncodeToEXR(Texture2D.EXRFlags.CompressZIP));
                Debug.Log("Finished LUT");
                m_Once = true;
            }
        }
    }
}
