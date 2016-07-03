module puppeteer_controller;

import std.meta;

import puppeteer_listener;

import puppeteer.puppeteer;

public alias supportedVarTypes = immutable AliasSeq!short;

public class PuppeteerController
{
    private Puppeteer!supportedVarTypes puppeteer;
    private shared PuppeteerListener listener;

    this()
    {
        puppeteer = new Puppeteer!supportedVarTypes;
        listener = new shared PuppeteerListener;
    }

    void loadConfiguration(string filePath)
    {
        puppeteer.loadConfig(filePath);
    }

    void saveConfiguration(string filePath)
    {
        puppeteer.saveConfig(filePath);
    }

    bool connect(string devFilename, BaudRate baudRate = BaudRate.B9600, Parity parity = Parity.none, string logFilePath = "puppeteerLog.txt")
    {
        return puppeteer.startCommunication(devFilename, baudRate, parity, logFilePath);
    }

    void disconnect()
    {
        puppeteer.endCommunication();
    }

    void setPWM(ubyte pin, ubyte value)
    {
        puppeteer.setPWM(pin, value);
    }

    void monitorAI(ubyte pin, bool monitor)
    {
        if(monitor)
            puppeteer.addPinListener(pin, &listener.AIListener);
        else
            puppeteer.removePinListener(pin, &listener.AIListener);
    }

    void monitorVar(VarType)(ubyte varIndex, bool monitor)
    if(isVarMonitorTypeSupported!VarType)
    {
        if(monitor)
            puppeteer.addVariableListener!VarType(varIndex, &listener.varListener!VarType);
        else
            puppeteer.removeVariableListener!VarType(varIndex, &listener.varListener!VarType);
    }

    string getAIValueAdapter(ubyte pin)
    {
        return puppeteer.getAIValueAdapter(pin);
    }

    void setAIValueAdapter(ubyte pin, string expr)
    {
        puppeteer.setAIValueAdapter(pin, expr);
    }

    string getVarMonitorValueAdapter(VarType)(ubyte varIndex)
    {
        return puppeteer.getVarMonitorValueAdapter!VarType(varIndex);
    }

    void setVarMonitorValueAdapter(VarType)(ubyte varIndex, string expr)
    {
        puppeteer.setVarMonitorValueAdapter!VarType(varIndex, expr);
    }

    @property
    bool isPuppeteerConnected()
    {
        return puppeteer.isCommunicationEstablished;
    }
}
