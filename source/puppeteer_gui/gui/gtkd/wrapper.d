module puppeteer_gui.gui.gtkd.wrapper;

import puppeteer_gui.gui.igui;

import gtk.Main;

public class GTKGuiWrapper : IGUI
{
    this(string[] args)
    {
        Main.init(args);
    }

    public IBuilder buildFromFile(string filename)
    {
        return new GTKBuilder(filename);
    }

    public IWindow createMainWindow(string title)
    {
        return new GTKMainWindow(title);
    }

    public IWindow createWindow(string title)
    {
        return new GTKWindow(title);
    }

    public void run()
    {
        Main.run();
    }
}

private class GTKBuilder : IBuilder
{
    import gtk.Builder;

    Builder builder;

    this(string filename)
    {
        builder = new Builder(filename);
    }
}

private class GTKWindow : IWindow
{
    import gtk.Window;

    Window window;

    this(string title)
    {
        generateWindow(title);
    }

    void generateWindow(string title)
    {
        window = new Window(title);
    }

    void show()
    {
        window.show();
    }
}

private class GTKMainWindow : GTKWindow
{
    import gtk.MainWindow;

    this(string title)
    {
        super(title);
    }

    override void generateWindow(string title)
    {
        window = new MainWindow(title);
    }
}
