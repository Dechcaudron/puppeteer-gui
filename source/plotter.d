module plotter;

import ggplotd.ggplotd;
import ggplotd.aes;
import ggplotd.geom;

import std.stdio;


struct Plotter
{
    private GGPlotD receivedAIPlot;
    private GGPlotD adaptedAIPlot;

    private GGPlotD receivedVarMonitorsPlot;
    private GGPlotD adaptedVarMonitorsPlot;

    enum plotWidth = 1000;
    enum plotHeight = 800;

    void savePlots()
    {
        writeln("Saving plots...");

        receivedAIPlot.save("receivedAI.png", plotWidth, plotHeight);
        adaptedAIPlot.save("adaptedAI.png", plotWidth, plotHeight);

        receivedVarMonitorsPlot.save("receivedVarMonitors.png", plotWidth, plotHeight);
        adaptedVarMonitorsPlot.save("adaptedVarMonitors.png", plotWidth, plotHeight);

        writeln("Plots have been saved");
    }

    void addAIRead(ubyte pin, float receivedValue, float adaptedValue, long readTimeMSecs)
    {
        enum pinColors = ["a", "b", "c", "d", "e", "f"];

        auto receivedAes = Aes!(long[], "x", float[], "y", string, "colour")
                            ([readTimeMSecs], [receivedValue], pinColors[pin]);

        auto adaptedAes = Aes!(long[], "x", float[], "y", string, "colour")
                            ([readTimeMSecs], [adaptedValue], pinColors[pin]);

        receivedAIPlot.put(geomPoint(receivedAes));
        adaptedAIPlot.put(geomPoint(adaptedAes));
    }

    void addVarMonitorRead(T : short)(ubyte varIndex, T receivedValue, T adaptedValue, long readTimeMSecs)
    {
        enum pinColors = ["a", "b", "c", "d", "e", "f"];

        auto receivedAes = Aes!(long[], "x", T[], "y", string, "colour")
                            ([readTimeMSecs], [receivedValue], pinColors[varIndex]);

        auto adaptedAes = Aes!(long[], "x", T[], "y", string, "colour")
                            ([readTimeMSecs], [adaptedValue], pinColors[varIndex]);

        receivedVarMonitorsPlot.put(geomPoint(receivedAes));
        adaptedVarMonitorsPlot.put(geomPoint(adaptedAes));
    }
}
