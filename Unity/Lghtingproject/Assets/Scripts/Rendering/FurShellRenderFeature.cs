using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[DisallowMultipleRendererFeature] //! non public for urp version 10.0
public class FurShellRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]public struct FurshellSettings {
        public int layercount;
        public LayerMask layermask;
        public RenderPassEvent renderpassevent;
        public ShaderTagId shaderTagId;

        //public FurshellSettings()
        //{
        //    layercount = 10;
        //    layermask = ~0;
        //    renderpassevent = RenderPassEvent.AfterRenderingSkybox;
        //    shaderTagId = new ShaderTagId("FurShellPass");
        //}
    }
    public FurshellSettings settings;

    private FurShellRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new FurShellRenderPass(this);
        m_ScriptablePass.renderPassEvent = settings.renderpassevent;
    }
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}

public class FurShellRenderPass : ScriptableRenderPass
{
    FurShellRenderFeature.FurshellSettings settings;

    public FurShellRenderPass(FurShellRenderFeature furShellRenderFeature)
    {
        settings = furShellRenderFeature.settings;
    }
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {

    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        int layerCount = settings.layercount;



        ShaderTagId passName = new ShaderTagId("FurShellPass");

        DrawingSettings drawingSettings = CreateDrawingSettings(passName, ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);

        RenderQueueRange queue = new RenderQueueRange();

        queue.lowerBound = 2000;
        queue.upperBound = 5000;

        FilteringSettings filteringSettings = new FilteringSettings(queue, settings.layermask);

        CommandBuffer cmd = CommandBufferPool.Get("FurShellCmd");

        //using (new ProfilingScope(cmd,ProfilingSampler.Get(profileId))
        //{

        //}


        // ..todo profiler
        float step = 1 / (float)layerCount;

        for (int i = 0; i < layerCount; i++)
        {

            cmd.Clear();
            cmd.SetGlobalFloat("FUR_LAYER_OFFSET", i * step);

            context.ExecuteCommandBuffer(cmd);


            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
        }

        CommandBufferPool.Release(cmd);
    }

    // Cleanup any allocated resources that were created during the execution of this render pass.
    public override void OnCameraCleanup(CommandBuffer cmd)
    {

    }
}
