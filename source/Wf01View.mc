using Toybox.Application.Storage;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.Weather;
using Toybox.WatchUi;

const COLOR_DND = 0xaaaaaa;
const COLOR_LINE = 0x000000;
const BAND_SIZE = 90;
const MARGIN = 4;
const DIVIDER = 1;
const DATA_ROW_HEIGHT = 22;

class Wf01View extends WatchUi.WatchFace
{
    var font;
    var offscreenBuffer;
    var offscreenDc;
    var screenCenterPoint;
    var lineStart;

    var lastDate = null;
    var lastConnectionState = false;

    var leftBandColor;
    var rightBandColor;

    var sunCalc;
    var colors;

    var color_accent = 0xff873c;

    function drawBandLeft(dc) {
        var settings = System.getDeviceSettings();
        var doNotDisturb = settings.doNotDisturb;

        leftBandColor = doNotDisturb ? COLOR_DND : color_accent;

        /* dc.setColor(leftBandColor, 0x00ff00); */
        dc.setColor(leftBandColor, 0x00ff00);
        dc.fillRectangle(0.5 * BAND_SIZE, dc.getHeight() - BAND_SIZE, BAND_SIZE, BAND_SIZE);

        dc.setColor(COLOR_LINE, 0x00ff00);
        dc.fillRectangle(dc.getWidth() / 2 - DIVIDER, dc.getHeight() - BAND_SIZE, 2 * DIVIDER, BAND_SIZE);
    }

    function drawBandRight(dc, forceRedraw) {
        var settings = System.getDeviceSettings();
        var isConnected = settings.connectionAvailable;

        rightBandColor = isConnected ? color_accent : COLOR_DND;

        if (isConnected == lastConnectionState && !forceRedraw) {
            return false;
        }
        lastConnectionState = isConnected;

        dc.setColor(rightBandColor, 0x00ff00);
        dc.fillRectangle(screenCenterPoint[0] + DIVIDER, dc.getHeight() - BAND_SIZE, BAND_SIZE, BAND_SIZE);
        return true;
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(screenCenterPoint[0] - DIVIDER, 45, font, clockTime.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(screenCenterPoint[0] + DIVIDER, 45, font, clockTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawSteps(dc, y, draw_goal) {
        var activityInfo = ActivityMonitor.getInfo();
        dc.setColor(Graphics.COLOR_BLACK, leftBandColor);
        dc.drawText(
                screenCenterPoint[0] - MARGIN,
                lineStart + y,
                Graphics.FONT_SYSTEM_TINY,
                activityInfo.steps,
                Graphics.TEXT_JUSTIFY_RIGHT);
        if (draw_goal) {
            dc.setColor(Graphics.COLOR_BLACK, rightBandColor);
            dc.drawText(
                    screenCenterPoint[0] + MARGIN,
                    lineStart + y,
                    Graphics.FONT_SYSTEM_TINY,
                    activityInfo.stepGoal,
                    Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawDate(dc, y, today) {
        var dateString = Lang.format(
                "$1$$2$",
                [
                    today.day.format("%02d"),
                    today.month.format("%02d")
                ]
            );
        dc.setColor(Graphics.COLOR_BLACK, leftBandColor);
        dc.drawText(
                screenCenterPoint[0] - MARGIN,
                lineStart + DIVIDER + y,
                Graphics.FONT_SYSTEM_TINY,
                dateString,
                Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawSun(dc, y) {
        var loc = null;

        // get from position api
        var info = Position.getInfo();
        if (info.position != null) {
            loc = info.position.toRadians();
        }

        // get from weather
        if (loc == null || (loc[0] == 0 && loc[1] == 0)) {
            var curConds = Weather.getCurrentConditions();
            if (curConds != null) {
                var obsLoc = curConds.observationLocationPosition;
                if (obsLoc != null) {
                    loc = obsLoc.toRadians();
                }
            }
        }

        // get from storage
        if (loc == null || (loc[0] == 0 && loc[1] == 0)) {
            loc = Storage.getValue("wf01_sun_location");
            // draw it in gray to show that we're using a saved, possibly
            // old, location
            Storage.setValue("wf01_sun_color", Graphics.COLOR_DK_GRAY);
        } else {
            Storage.setValue("wf01_sun_location", loc);
        }

        // couldn't get any valid position, nothing to do
        if (loc == null || (loc[0] == 0 && loc[1] == 0)) {
            return;
        }

        var now = Time.now();
        var sunrise_moment = sunCalc.calculate(now, loc, sunCalc.SUNRISE);
        var sunset_moment = sunCalc.calculate(now, loc, sunCalc.SUNSET);

        var timeInfoSunrise = Gregorian.info(sunrise_moment, Time.FORMAT_SHORT);
        var timeInfoSunset = Gregorian.info(sunset_moment, Time.FORMAT_SHORT);

        var sunrise_str = timeInfoSunrise.hour.format("%02d") + timeInfoSunrise.min.format("%02d");
        var sunset_str = timeInfoSunset.hour.format("%02d") + timeInfoSunset.min.format("%02d");

        var text_color = Storage.getValue("wf01_sun_color");

        // reset saved color to black
        Storage.setValue("wf01_sun_color", Graphics.COLOR_BLACK);

        if (sunrise_str == null || sunset_str == null || text_color == null) {
            return;
        }

        dc.setColor(text_color, leftBandColor);
        dc.drawText(
                screenCenterPoint[0] - MARGIN,
                lineStart + y,
                Graphics.FONT_SYSTEM_TINY,
                sunrise_str,
                Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(text_color, rightBandColor);
        dc.drawText(
                screenCenterPoint[0] + MARGIN,
                lineStart + y,
                Graphics.FONT_SYSTEM_TINY,
                sunset_str,
                Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawBattery(dc, y) {
        var stats = System.getSystemStats();
        dc.setColor(Graphics.COLOR_BLACK, rightBandColor);
        dc.drawText(
                screenCenterPoint[0] + MARGIN,
                lineStart + DIVIDER + y,
                Graphics.FONT_SYSTEM_TINY,
                stats.battery.format("%d"),
                Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawWeatherTemperature(dc, y) {
        var curConds = Weather.getCurrentConditions();
        var tempStr = "-";
        if (curConds != null) {
            var temp = curConds.temperature;
            if (temp != null) {
                tempStr = temp;
            }
        }
        var stats = System.getSystemStats();
        dc.setColor(Graphics.COLOR_BLACK, rightBandColor);
        dc.drawText(
                screenCenterPoint[0] + MARGIN,
                lineStart + DIVIDER + y,
                Graphics.FONT_SYSTEM_TINY,
                tempStr,
                Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawHeart(dc, y) {
        var avgHrStr = "-";
        var avgHr = UserProfile.Profile.averageRestingHeartRate;
        if (avgHr != null) {
            avgHrStr = avgHr;//.format("%d");
        }
        dc.setColor(Graphics.COLOR_BLACK, leftBandColor);
        dc.drawText(
                screenCenterPoint[0] - MARGIN,
                lineStart + y,
                Graphics.FONT_SYSTEM_TINY,
                avgHrStr,
                Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawTop(dc) {
        var settings = System.getDeviceSettings();
        if (settings.notificationCount <= 0) {
            return;
        }

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        dc.fillRectangle(0.5 * BAND_SIZE, 0, dc.getWidth() - BAND_SIZE, 27);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_RED);
        dc.drawText(
                screenCenterPoint[0],
                0,
                Graphics.FONT_SYSTEM_TINY,
                settings.notificationCount,
                Graphics.TEXT_JUSTIFY_CENTER);
    }

    function initialize() {
        WatchFace.initialize();

        sunCalc = new SunCalc();
        colors = new Colors();

        color_accent = Storage.getValue("wf01_accent");
        if (color_accent == null) {
            color_accent = colors.getRandomColor();
            Storage.setValue("wf01_accent", color_accent);
        }

        var settings = System.getDeviceSettings();
        var isConnected = settings.connectionAvailable;
        lastConnectionState = !isConnected;
    }

    function onLayout(dc) {
        font = WatchUi.loadResource(Rez.Fonts.id_font_time);

        offscreenBuffer = new Graphics.BufferedBitmap({
                :width=>dc.getWidth(),
                :height=>dc.getHeight()});

        screenCenterPoint = [dc.getWidth()/2, dc.getHeight()/2];
        lineStart = dc.getHeight() - BAND_SIZE;
        offscreenDc = offscreenBuffer.getDc();

        drawBandLeft(offscreenDc);
        drawBandRight(offscreenDc, true);

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        drawDate(offscreenDc, DATA_ROW_HEIGHT * 0, today);
        drawSun(offscreenDc, DATA_ROW_HEIGHT * 2);
        drawHeart(offscreenDc, DATA_ROW_HEIGHT * 3);
        drawSteps(offscreenDc, DATA_ROW_HEIGHT * 1, true);
        lastDate = today;
    }

    function onUpdate(dc) {
        // first update offscreen buffer
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var newDay = true;
        if (lastDate == null) {
            lastDate = today;
        }
        else {
            newDay = today.day != lastDate.day;
        }
        lastDate = today;

        if (newDay) {
            // new day, new color!
            color_accent = colors.getRandomColor();
            Storage.setValue("wf01_accent", color_accent);
        }

        // left side is drawn when shown in init
        var invalid = drawBandRight(offscreenDc, newDay);
        if (newDay || invalid) {
            drawBandLeft(offscreenDc);
            drawDate(offscreenDc, DATA_ROW_HEIGHT * 0, today);
            drawSun(offscreenDc, DATA_ROW_HEIGHT * 2);
            drawHeart(offscreenDc, DATA_ROW_HEIGHT * 3);
            drawSteps(offscreenDc, DATA_ROW_HEIGHT * 1, true);
        }
        dc.drawBitmap(0, 0, offscreenBuffer);

        // update onscreen buffer
        drawTime(dc);
        drawBattery(dc, DATA_ROW_HEIGHT * 0);
        drawSteps(dc, DATA_ROW_HEIGHT * 1, false);
        drawWeatherTemperature(dc, DATA_ROW_HEIGHT * 3);
        drawTop(dc);
    }
}
