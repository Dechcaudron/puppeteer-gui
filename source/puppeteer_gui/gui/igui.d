module puppeteer_gui.gui.igui;

import puppeteer_gui.gui.gtkd.wrapper;

public interface IGUI
{
    static IGUI getInstance(string[] args)
    {
        return new GTKGuiWrapper(args);
    }

    IWindow createMainWindow(string title);
    IWindow createWindow(string title);

    void run();
}

public interface IWindow
{
    void show();
}
