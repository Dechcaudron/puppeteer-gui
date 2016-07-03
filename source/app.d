import std.stdio;
import std.conv;
import std.meta;

import puppeteer_controller;

import gtk.Builder;
import gtk.Main;
import gtk.Button;
import gtk.ApplicationWindow;
import gtk.FileChooserButton;
import gtk.FileChooserDialog;
import gtk.Window;
import gtk.ListBox;
import gtk.Box;
import gtk.ListBoxRow;
import gtk.Label;
import gtk.Entry;
import gtk.SpinButton;

PuppeteerController controller;

ApplicationWindow mainWindow;

Window puppeteerConfigWindow;
Box puppeteerConfigMainBox;
Box AIValueAdapterBox;
Box AIValueAdapterInnerBox;
SpinButton AIValueAdapterSpinButton;
Entry AIValueAdapterEntry;

FileChooserButton devFileChooserButton;

FileChooserDialog loadPuppeteerConfigDialog;
FileChooserDialog savePuppeteerConfigDialog;

ListBox PWMOutputListBox;
ListBoxRow samplePWMOutputListBoxRow;
Box samplePWMOutputBox;
Label samplePWMOutputLabel;
Entry samplePWMOutputEntry;

ListBox AIMonitorsListBox;
ListBox varMonitorsListBox;

Button configPuppeteerButton;
Button loadPuppeteerConfigButton;
Button acceptLoadConfigButton;
Button cancelLoadConfigButton;
Button savePuppeteerConfigButton;
Button acceptSaveConfigButton;
Button cancelSaveConfigButton;
Button start_stopCommunicationButton;

void main(string[] args)
{
	Main.init(args);

    controller = new PuppeteerController;

    initUI();
    configureUI();

    mainWindow.show();
    Main.run();

	controller.disconnect();
}

void initUI()
{
    debug writeln("Loading UI");

    Builder builder = new Builder("resources/puppeteer_gui.glade");

    void mapUI(T)(ref T UIElement, string name)
    {
        debug writefln("Mapping %s to type %s", name, T.stringof);
        UIElement = to!T(builder.getObject(name));

        //Check for correct mapping
        debug writefln("Name is %s", UIElement.getName());
    }

    mapUI(mainWindow, "MainWindow");

    mapUI(puppeteerConfigWindow, "puppeteerConfigWindow");
    mapUI(puppeteerConfigMainBox, "puppeteerConfigMainBox");
    mapUI(AIValueAdapterBox, "AIValueAdapterBox");
    mapUI(AIValueAdapterInnerBox, "AIValueAdapterInnerBox");
    mapUI(AIValueAdapterEntry, "AIValueAdapterEntry");
    mapUI(AIValueAdapterSpinButton, "AIValueAdapterSpinButton");

    mapUI(PWMOutputListBox, "PWMOutputListBox");
    mapUI(samplePWMOutputListBoxRow, "samplePWMOutputListBoxRow");
    mapUI(samplePWMOutputBox, "samplePWMOutputBox");
    mapUI(samplePWMOutputLabel, "samplePWMOutputLabel");
    mapUI(samplePWMOutputEntry, "samplePWMOutputEntry");

    mapUI(AIMonitorsListBox, "AIMonitorsListBox");
    mapUI(varMonitorsListBox, "varMonitorsListBox");

    mapUI(devFileChooserButton, "devFileChooserButton");

    mapUI(loadPuppeteerConfigDialog, "loadPuppeteerConfigDialog");
    mapUI(savePuppeteerConfigDialog, "savePuppeteerConfigDialog");

    mapUI(configPuppeteerButton, "configPuppeteerButton");

    mapUI(loadPuppeteerConfigButton, "loadPuppeteerConfigButton");
    mapUI(acceptLoadConfigButton, "acceptLoadConfigButton");
    mapUI(cancelLoadConfigButton, "cancelLoadConfigButton");

    mapUI(savePuppeteerConfigButton, "savePuppeteerConfigButton");
    mapUI(acceptSaveConfigButton, "acceptSaveConfigButton");
    mapUI(cancelSaveConfigButton, "cancelSaveConfigButton");

    mapUI(start_stopCommunicationButton, "start_stopCommunicationButton");

    debug writeln("Done loading UI");
}

void configureUI()
{
    debug writeln("Configuring UI");

    loadPuppeteerConfigDialog.hideOnDelete();

    devFileChooserButton.addOnFileSet(
        (FileChooserButton btn)
        {
            checkSelectedDevFile();
        }
    );

    configPuppeteerButton.addOnClicked(
        (Button btn)
        {
            puppeteerConfigWindow.show();
        }
    );

    loadPuppeteerConfigButton.addOnClicked(
        (Button btn)
        {
            loadPuppeteerConfigDialog.show();
        }
    );

    acceptLoadConfigButton.addOnClicked(
        (Button btn)
        {
            loadPuppeteerConfigDialog.hide();
            controller.loadConfiguration(loadPuppeteerConfigDialog.getFilename());
        }
    );

    cancelLoadConfigButton.addOnClicked(
        (Button btn)
        {
            loadPuppeteerConfigDialog.hide();
        }
    );

    savePuppeteerConfigButton.addOnClicked(
        (Button btn)
        {
            savePuppeteerConfigDialog.show();
        }
    );

    acceptSaveConfigButton.addOnClicked(
        (Button btn)
        {
            savePuppeteerConfigDialog.hide();
            controller.saveConfiguration(savePuppeteerConfigDialog.getFilename());
        }
    );

    cancelSaveConfigButton.addOnClicked(
        (Button btn)
        {
            savePuppeteerConfigDialog.hide();
        }
    );

    start_stopCommunicationButton.addOnClicked(
        (Button btn)
        {
            btn.setSensitive(false);

            if(!controller.isPuppeteerConnected)
                controller.connect(devFileChooserButton.getFilename());
            else
                controller.disconnect();

            checkPuppeteerConnection();

            btn.setSensitive(true);
        }
    );

	configureWindows();
    configurePuppeteerConfigWindow();
    //TODO: these default values will have to do by now
    configurePWMOutputListBox(10);
    configureAIMonitorsListBox(10);
    configureVarMonitorsListBox([10]);

    checkSelectedDevFile();
    checkPuppeteerConnection();

    debug writeln("Done configuring UI");
}

void configureWindows()
{
	import gdk.Event;
	import gtk.Widget;

	mainWindow.addOnDelete(
	(Event e, Widget w)
		{
			Main.quit();
			return false;
		}
	);

	auto hideWindowDelegate = delegate bool(Event e, Widget w)
	{
		w.hide();
		return true;
	};

	puppeteerConfigWindow.addOnDelete(hideWindowDelegate);
	loadPuppeteerConfigDialog.addOnDelete(hideWindowDelegate);
	savePuppeteerConfigDialog.addOnDelete(hideWindowDelegate);
}

void configurePWMOutputListBox(int entries)
{
    PWMOutputListBox.removeAll();

    for(int i=0; i<entries; i++)
    {
        auto listBoxRow = new ListBoxRow();
        listBoxRow.show();

        auto box = new Box(Orientation.HORIZONTAL, samplePWMOutputBox.getSpacing());
        box.show();

        auto label = new Label("PWM " ~ to!string(i));
        label.show();

        auto entry = new Entry("0", 3);
        entry.show();
        entry.setInputPurpose(samplePWMOutputEntry.getInputPurpose());
        entry.setWidthChars(samplePWMOutputEntry.getWidthChars());

        void setAction(ubyte pwmPin)
        {
            entry.addOnActivate(
                (Entry entry)
                {
                    import std.conv;
                    string text = entry.getText();
                    ubyte value = 0;
                    try
                    {
                        size_t aux = to!size_t(text);
                        if (aux > ubyte.max)
                        {
                            debug writeln("Wrapping value to 255");
                            entry.setText("255");
                            value = ubyte.max;
                        }
                        else
                        {
                            value = to!ubyte(aux);
                        }
                    }
                    catch(ConvException e)
                    {
                        debug writeln("User wrote a non-convertible value. Setting to 0");
                        entry.setText("0");
                    }

                    controller.setPWM(pwmPin, value);
                }
            );
        }

        setAction(to!ubyte(i));

        listBoxRow.add(box);

        box.add(label);
        box.add(entry);

        PWMOutputListBox.insert(listBoxRow, i);
    }
}

void configureAIMonitorsListBox(int entries)
{
    AIMonitorsListBox.removeAll();

    for(int i=0; i<entries; i++)
    {
        import gtk.CheckButton;
        import gtk.ToggleButton;

        auto listBoxRow = new ListBoxRow();
        listBoxRow.show();

        auto checkButton = new CheckButton("AI " ~ to!string(i));
        checkButton.show();

        void setAction(ubyte pin)
        {
            checkButton.addOnToggled(
                (ToggleButton btn)
                {
                    controller.monitorAI(pin, btn.getActive());
                }
            );
        }

        setAction(to!ubyte(i));

        listBoxRow.add(checkButton);

        AIMonitorsListBox.insert(listBoxRow, i);
    }
}

enum stringForType(T : short) = "Int16";
alias typeStrings = staticMap!(stringForType, supportedVarTypes);

void configureVarMonitorsListBox(int[supportedVarTypes.length] entries)
{
    varMonitorsListBox.removeAll();

    int rowCounter = 0;

    foreach(a, str; typeStrings)
    {
        for(int i = 0; i < entries[a]; i++)
        {
            import gtk.CheckButton;
            import gtk.ToggleButton;

            import std.format : format;

            auto listBoxRow = new ListBoxRow();
            listBoxRow.show();

            auto checkButton = new CheckButton(format("%s [%s]", str, i));
            checkButton.show();

            listBoxRow.add(checkButton);

            void setAction(VarType)(ubyte varIndex)
            {
                checkButton.addOnToggled(
                    (ToggleButton btn)
                    {
                        controller.monitorVar!VarType(varIndex, btn.getActive());
                    }
                );
            }

            setAction!(supportedVarTypes[a])(to!ubyte(i));

            varMonitorsListBox.insert(listBoxRow, rowCounter++);
        }
    }
}

void configurePuppeteerConfigWindow()
{
    import gtk.Widget;

    AIValueAdapterSpinButton.setRange(0, 255);
    AIValueAdapterSpinButton.setIncrements(1, 2);
    AIValueAdapterSpinButton.setWrap(false);
    AIValueAdapterSpinButton.setValue(0);
    AIValueAdapterSpinButton.addOnValueChanged(
        (SpinButton btn)
        {
            AIValueAdapterEntry.setText(controller.getAIValueAdapter(to!ubyte(btn.getValue())));
        }
    );

    AIValueAdapterEntry.addOnActivate(
        (Entry entry)
        {
            controller.setAIValueAdapter(to!ubyte(AIValueAdapterSpinButton.getValue()), entry.getText());
        }
    );

    puppeteerConfigWindow.addOnShow(
        (Widget wid)
        {
            AIValueAdapterEntry.setText(controller.getAIValueAdapter(0));
        }
    );

    foreach(type; supportedVarTypes)
    {
        Box box = new Box(Orientation.HORIZONTAL, AIValueAdapterBox.getSpacing());
        box.show();

        Label label = new Label("Value adapter");
        label.show();

        Box innerBox = new Box(Orientation.HORIZONTAL, AIValueAdapterInnerBox.getSpacing());
        innerBox.show();

        Label innerLabel = new Label(stringForType!type);
        innerLabel.show();

        SpinButton spinButton = new SpinButton(0, 255, 1);
        spinButton.show();
        spinButton.setValue(0);
        spinButton.setWrap(false);

        Entry entry = new Entry();
        entry.show();
        entry.setPlaceholderText("f(x)");
        entry.setText(controller.getAIValueAdapter(0));

        void setSpinButtonAction(Entry entry)
        {
            spinButton.addOnValueChanged(
                (SpinButton btn)
                {
                    entry.setText(controller.getVarMonitorValueAdapter!type(to!ubyte(btn.getValue())));
                }
            );
        }

        setSpinButtonAction(entry);

        void setEntryAction(SpinButton spinButton)
        {
            entry.addOnActivate(
                (Entry entry)
                {
                    controller.setVarMonitorValueAdapter!type(to!ubyte(spinButton.getValue()), entry.getText());
                }
            );
        }

        setEntryAction(spinButton);

        void setWindowAction(SpinButton btn, Entry entry)
        {
            puppeteerConfigWindow.addOnShow(
                (Widget wid)
                {
                    btn.setValue(0);
                    entry.setText(controller.getVarMonitorValueAdapter!type(0));
                }
            );
        }

        setWindowAction(spinButton, entry);

        innerBox.add(innerLabel);
        innerBox.add(spinButton);

        box.add(label);
        box.add(innerBox);
        box.add(entry);

        puppeteerConfigMainBox.add(box);
    }
}

void checkSelectedDevFile()
{
    string path = devFileChooserButton.getFilename();

    start_stopCommunicationButton.setSensitive(path != "");
}

void checkPuppeteerConnection()
{
    bool connected = controller.isPuppeteerConnected;

    start_stopCommunicationButton.setLabel(connected ? "Stop communication" : "Start communication");

    foreach(i; 0..PWMOutputListBox.getChildren().length)
        PWMOutputListBox.getRowAtIndex(i).setSensitive(connected);

    foreach(i; 0..AIMonitorsListBox.getChildren().length)
        AIMonitorsListBox.getRowAtIndex(i).setSensitive(connected);

    foreach(i; 0..varMonitorsListBox.getChildren().length)
        varMonitorsListBox.getRowAtIndex(i).setSensitive(connected);

}
