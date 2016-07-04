module puppeteer_listener;

import plotter;

import std.concurrency;
import std.stdio;

public shared class PuppeteerListener
{
    __gshared Tid drawer;

    this()
    {
        drawer = spawn(&drawLoop);
    }

    public void finish()
    {
        drawer.send(cast(int)0);
    }

    public void AIListener(ubyte pin, float realValue, float adaptedValue, long mSecs)
    {
        drawer.send(DrawAIMessage(pin, realValue, adaptedValue, mSecs));
    }

    public void varListener(T)(ubyte varIndex, T realValue, T adaptedValue, long mSecs)
    {
        drawer.send(DrawVarMonitorMessage!T(varIndex, realValue, adaptedValue, mSecs));
    }
}

void drawLoop()
{
    Plotter plotter;

    bool shouldLoop = true;
    while(shouldLoop)
    {
        receive(
            (DrawAIMessage msg) {plotter.addAIRead(msg.pin, msg.realValue, msg.adaptedValue, msg.mSecs);},
            (DrawVarMonitorMessage!short msg) {plotter.addVarMonitorRead(msg.varIndex, msg.realValue, msg.adaptedValue, msg.mSecs);},
            (int i) {if (i==0) shouldLoop = false;}
        );
    }

    writeln("Finishing drawLoop");
    plotter.savePlots();
}

private struct DrawAIMessage
{
    ubyte pin;
    float realValue;
    float adaptedValue;
    long mSecs;
}

private struct DrawVarMonitorMessage(T)
{
    ubyte varIndex;
    T realValue;
    T adaptedValue;
    long mSecs;
}
