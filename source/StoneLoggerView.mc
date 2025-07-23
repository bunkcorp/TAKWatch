using Toybox.Application.Storage;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class StoneLoggerView extends WatchUi.View {
    
    enum AppState {
        MAIN_SCREEN,
        STONE_SELECTION
    }
    
    var currentState;
    var whiteStoneCount;
    var blackStoneCount;
    var selectedOption; // 0 = white, 1 = black
    
    function initialize() {
        View.initialize();
        currentState = MAIN_SCREEN;
        
        // Load stored counts
        whiteStoneCount = Storage.getValue("white_stones");
        if (whiteStoneCount == null) {
            whiteStoneCount = 0;
        }
        
        blackStoneCount = Storage.getValue("black_stones");
        if (blackStoneCount == null) {
            blackStoneCount = 0;
        }
        
        selectedOption = 0; // Default to white
    }
    
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (currentState == MAIN_SCREEN) {
            drawMainScreen(dc);
        } else if (currentState == STONE_SELECTION) {
            drawSelectionScreen(dc);
        }
    }
    
    function drawMainScreen(dc) {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 30, Graphics.FONT_MEDIUM, "Stone Logger", Graphics.TEXT_JUSTIFY_CENTER);
        
        // White stone count
        dc.drawText(centerX, centerY - 40, Graphics.FONT_SMALL, "White Stones:", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY - 20, Graphics.FONT_NUMBER_HOT, whiteStoneCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Black stone count  
        dc.drawText(centerX, centerY + 10, Graphics.FONT_SMALL, "Black Stones:", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY + 30, Graphics.FONT_NUMBER_HOT, blackStoneCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Instructions
        dc.drawText(centerX, screenHeight - 40, Graphics.FONT_TINY, "Press START to log", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function drawSelectionScreen(dc) {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 30, Graphics.FONT_MEDIUM, "Select Stone", Graphics.TEXT_JUSTIFY_CENTER);
        
        // White stone option
        if (selectedOption == 0) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY - 30, Graphics.FONT_MEDIUM, "> WHITE <", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY - 30, Graphics.FONT_MEDIUM, "WHITE", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Black stone option
        if (selectedOption == 1) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY + 10, Graphics.FONT_MEDIUM, "> BLACK <", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY + 10, Graphics.FONT_MEDIUM, "BLACK", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Instructions
        dc.drawText(centerX, screenHeight - 60, Graphics.FONT_TINY, "UP/DOWN to select", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, screenHeight - 40, Graphics.FONT_TINY, "START to confirm", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, screenHeight - 20, Graphics.FONT_TINY, "BACK to cancel", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function onStartPressed() {
        if (currentState == MAIN_SCREEN) {
            currentState = STONE_SELECTION;
            selectedOption = 0; // Reset to white
        } else if (currentState == STONE_SELECTION) {
            // Log the selected stone
            if (selectedOption == 0) {
                whiteStoneCount++;
                Storage.setValue("white_stones", whiteStoneCount);
            } else {
                blackStoneCount++;
                Storage.setValue("black_stones", blackStoneCount);
            }
            currentState = MAIN_SCREEN;
        }
        WatchUi.requestUpdate();
    }
    
    function onUpPressed() {
        if (currentState == STONE_SELECTION) {
            selectedOption = 0; // Select white
            WatchUi.requestUpdate();
        }
    }
    
    function onDownPressed() {
        if (currentState == STONE_SELECTION) {
            selectedOption = 1; // Select black
            WatchUi.requestUpdate();
        }
    }
    
    function onBackPressed() {
        if (currentState == STONE_SELECTION) {
            currentState = MAIN_SCREEN;
            WatchUi.requestUpdate();
            return true; // Handled
        }
        return false; // Let system handle (exit app)
    }
}