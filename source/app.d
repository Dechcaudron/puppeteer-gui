import std.stdio;
import puppeteer_gui.gui.igui;

void main(string[] args)
{
	IGUI gui = IGUI.getInstance(args);

    IWindow mainWindow = gui.createMainWindow("Main");
    mainWindow.show();

    gui.run();
}
