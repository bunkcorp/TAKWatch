using Toybox.Application.Storage;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class StoneLoggerView extends WatchUi.View {
    
    enum AppState {
        MAIN_SCREEN,
        STONE_SELECTION,
        VIRTUE_SELECTION,
        NON_VIRTUE_SELECTION
    }
    
    var currentState;
    var whiteStoneCount;
    var blackStoneCount;
    var selectedOption; // 0 = white, 1 = black
    var selectedVirtueIndex;
    
    // 10 Virtues (for white stones)
    var virtues = [
        "Insight",
        "Love",
        "Content",
        "Meaning",
        "Kindness",
        "Harmony",
        "Truth",
        "Conduct",
        "Give",
        "Protect"
    ];
    
    // 10 Non-virtues (for black stones) 
    var nonVirtues = [
        "Error",
        "Ill Will",
        "Covet",
        "Idle",
        "Harsh",
        "Divide",
        "Lie",
        "Lust",
        "Steal",
        "Kill"
    ];
    
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
        selectedVirtueIndex = 0; // Default to first virtue/non-virtue
    }
    
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (currentState == MAIN_SCREEN) {
            drawMainScreen(dc);
        } else if (currentState == STONE_SELECTION) {
            drawSelectionScreen(dc);
        } else if (currentState == VIRTUE_SELECTION) {
            drawVirtueSelectionScreen(dc);
        } else if (currentState == NON_VIRTUE_SELECTION) {
            drawNonVirtueSelectionScreen(dc);
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
        dc.drawText(centerX, centerY - 50, Graphics.FONT_SMALL, "White Stones:", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY - 25, Graphics.FONT_MEDIUM, whiteStoneCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Black stone count  
        dc.drawText(centerX, centerY + 5, Graphics.FONT_SMALL, "Black Stones:", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY + 30, Graphics.FONT_MEDIUM, blackStoneCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
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
        
    }
    
    function drawVirtueSelectionScreen(dc) {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 15, Graphics.FONT_SMALL, "Select Virtue", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 40, Graphics.FONT_TINY, "(" + (selectedVirtueIndex + 1) + " of 10)", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current virtue (highlighted)
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 10, Graphics.FONT_MEDIUM, "> " + virtues[selectedVirtueIndex] + " <", Graphics.TEXT_JUSTIFY_CENTER);
        
    }
    
    function drawNonVirtueSelectionScreen(dc) {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 15, Graphics.FONT_TINY, "Select Non-Virtue", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 40, Graphics.FONT_TINY, "(" + (selectedVirtueIndex + 1) + " of 10)", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Current non-virtue (highlighted)
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 10, Graphics.FONT_MEDIUM, "> " + nonVirtues[selectedVirtueIndex] + " <", Graphics.TEXT_JUSTIFY_CENTER);
        
    }
    
    function onStartPressed() {
        if (currentState == MAIN_SCREEN) {
            currentState = STONE_SELECTION;
            selectedOption = 0; // Reset to white
        } else if (currentState == STONE_SELECTION) {
            // Go to virtue or non-virtue selection
            selectedVirtueIndex = 0; // Reset to first item
            if (selectedOption == 0) {
                currentState = VIRTUE_SELECTION;
            } else {
                currentState = NON_VIRTUE_SELECTION;
            }
        } else if (currentState == VIRTUE_SELECTION) {
            // Log the selected virtue
            whiteStoneCount++;
            Storage.setValue("white_stones", whiteStoneCount);
            
            // Store the specific virtue selected (for future detailed tracking)
            var virtueKey = "virtue_" + selectedVirtueIndex;
            var virtueCount = Storage.getValue(virtueKey);
            if (virtueCount == null) {
                virtueCount = 0;
            }
            virtueCount++;
            Storage.setValue(virtueKey, virtueCount);
            
            currentState = MAIN_SCREEN;
        } else if (currentState == NON_VIRTUE_SELECTION) {
            // Log the selected non-virtue
            blackStoneCount++;
            Storage.setValue("black_stones", blackStoneCount);
            
            // Store the specific non-virtue selected (for future detailed tracking)
            var nonVirtueKey = "nonvirtue_" + selectedVirtueIndex;
            var nonVirtueCount = Storage.getValue(nonVirtueKey);
            if (nonVirtueCount == null) {
                nonVirtueCount = 0;
            }
            nonVirtueCount++;
            Storage.setValue(nonVirtueKey, nonVirtueCount);
            
            currentState = MAIN_SCREEN;
        }
        WatchUi.requestUpdate();
    }
    
    function onUpPressed() {
        if (currentState == STONE_SELECTION) {
            selectedOption = 0; // Select white
        } else if (currentState == VIRTUE_SELECTION || currentState == NON_VIRTUE_SELECTION) {
            // Navigate up through the list
            selectedVirtueIndex--;
            if (selectedVirtueIndex < 0) {
                selectedVirtueIndex = 9; // Wrap to bottom
            }
        }
        WatchUi.requestUpdate();
    }
    
    function onDownPressed() {
        if (currentState == STONE_SELECTION) {
            selectedOption = 1; // Select black
        } else if (currentState == VIRTUE_SELECTION || currentState == NON_VIRTUE_SELECTION) {
            // Navigate down through the list
            selectedVirtueIndex++;
            if (selectedVirtueIndex > 9) {
                selectedVirtueIndex = 0; // Wrap to top
            }
        }
        WatchUi.requestUpdate();
    }
    
    function onBackPressed() {
        if (currentState == STONE_SELECTION) {
            currentState = MAIN_SCREEN;
            WatchUi.requestUpdate();
            return true; // Handled
        } else if (currentState == VIRTUE_SELECTION || currentState == NON_VIRTUE_SELECTION) {
            currentState = STONE_SELECTION;
            WatchUi.requestUpdate();
            return true; // Handled
        }
        return false; // Let system handle (exit app)
    }
}