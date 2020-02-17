using Toybox.Application;

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
        return [new Wf01View()];
    }
}
