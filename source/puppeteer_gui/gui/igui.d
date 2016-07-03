module puppeteer_gui.gui.igui;

import puppeteer_gui.gui.gtkd.wrapper;

public interface IGUI
{
    static IGUI getInstance(string[] args)
    {
        return new GTKGuiWrapper(args);
    }

    IBuilder buildFromFile(string filename);

    IWindow createMainWindow(string title);
    IWindow createWindow(string title);

    void run();
}

public interface IBuilder
{
}

public interface IObject
{

}

public interface IWindow : IObject
{
    void show();
}
