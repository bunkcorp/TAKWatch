using Toybox.WatchUi;

class StoneLoggerDelegate extends WatchUi.BehaviorDelegate {
    var view;
    
    function initialize(viewRef) {
        BehaviorDelegate.initialize();
        view = viewRef;
    }
    
    function onMenu() {
        return view.onStartPressed();
    }
    
    function onSelect() {
        return view.onStartPressed();
    }
    
    function onNextPage() {
        return view.onDownPressed();
    }
    
    function onPreviousPage() {
        return view.onUpPressed();
    }
    
    function onBack() {
        return view.onBackPressed();
    }
}