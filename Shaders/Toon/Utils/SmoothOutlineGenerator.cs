using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

// This class will use UV to generate a object-space normal mapping which has smooth normal and later used for outline extrusion.
public class SmoothOutlineGenerator : MonoBehaviour
{
    private static Material SmoothMat;

    public Mesh m_mesh;
    void Start()
    {
        Texture2D smoothedNorm = new Texture2D(1024, 1024, TextureFormat.RGB24, false);
        CalculateSmoothNormalMap(m_mesh, smoothedNorm);
        File.WriteAllBytes(m_mesh.name + "_Smooth.png", smoothedNorm.EncodeToPNG());
        Debug.Log("Exported");
    }

    public static void CalculateSmoothNormalMap(Mesh mesh, Texture2D outputValue) {       
        if (SmoothMat == null && !SetupMaterial()) {
            return;
        }

        // Run and get texture
        if (SmoothMat.SetPass(0)) {
            RenderTexture renderTex = new RenderTexture(outputValue.width, outputValue.height, 24, RenderTextureFormat.ARGBFloat);
            RenderTexture tmp = RenderTexture.active;
            RenderTexture.active = renderTex;

            Graphics.DrawMeshNow(mesh, Matrix4x4.identity);

            outputValue.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
            outputValue.Apply();
            RenderTexture.active = tmp;
        }
        else {
            Debug.LogError("Smooth Normal Generator: Failed to set pass 0");
            return;
        }

        // reset alpha to 1
        //Color[] colors = outputValue.GetPixels();
        //for (int i = 0; i < colors.Length; ++i) {
        //    colors[i].a = 1.0f;
        //}

        //outputValue.Apply();
    }

    private static bool SetupMaterial() {
        if (SmoothMat == null) {
            Shader shd = Shader.Find("ToonShading/Utils/SmoothNormalDrawer");
            if (shd == null) {
                Debug.LogError("Cannot find shader:ToonShading/Utils/SmoothNormalDrawer");
                return false;
            }
            SmoothMat = new Material(shd);
            return true;
        }
        return true;
    }
}
