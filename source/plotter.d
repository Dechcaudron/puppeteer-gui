module plotter;

import ggplotd.ggplotd;
import ggplotd.aes;
import ggplotd.geom;

import std.stdio;


class Plotter
{
    private GGPlotD receivedPlot;
    private GGPlotD adaptedPlot;

    enum plotWidth = 1000;
    enum plotHeight = 800;

    this()
    {

    }

    void savePlots()
    {
        writeln("Saving plots...");

        receivedPlot.save("received.png", plotWidth, plotHeight);
        adaptedPlot.save("adapted.png", plotWidth, plotHeight);

        writeln("Plots have been saved");
    }

    void addAIRead(ubyte pin, float receivedValue, float adaptedValue, long readTimeMSecs)
    {
        enum pinColors = ["a", "b", "c", "d", "e", "f"];

        auto receivedAes = Aes!(long[], "x", float[], "y", string, "colour")
                            ([readTimeMSecs], [receivedValue], pinColors[pin]);

        auto adaptedAes = Aes!(long[], "x", float[], "y", string, "colour")
                            ([readTimeMSecs], [adaptedValue], pinColors[pin]);

        receivedPlot.put(geomPoint(receivedAes));
        adaptedPlot.put(geomPoint(adaptedAes));
    }

    void addVarMonitorRead(T)(ubyte varIndex, T receivedValue, T adaptedValue, long mSecs)
    {

    }
}
