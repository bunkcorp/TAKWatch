using Toybox.Application;
using Toybox.WatchUi;

// This is the primary entry point of the application.
class Wf01 extends Application.AppBase
{
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }
    
    function getInitialView() {
        var view = new StoneLoggerView();
        var delegate = new StoneLoggerDelegate(view);
        return [view, delegate];
    }
}
