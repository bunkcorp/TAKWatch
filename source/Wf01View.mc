using Toybox.Application.Storage;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi;

const COLOR_DND = 0xaaaaaa;
const COLOR_LINE = 0x000000;
const BAND_SIZE = 80;
const MARGIN = 4;
const DIVIDER = 1;

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
        drawDate(offscreenDc, today);
        drawSun(offscreenDc);
        drawSteps(offscreenDc, true);
        lastDate = today;
    }

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

    function drawSteps(dc, draw_goal) {
        var activityInfo = ActivityMonitor.getInfo();
        dc.setColor(Graphics.COLOR_BLACK, leftBandColor);
        dc.drawText(
                screenCenterPoint[0] - MARGIN,
                lineStart + 25,
                Graphics.FONT_SYSTEM_TINY,
                activityInfo.steps,
                Graphics.TEXT_JUSTIFY_RIGHT);
        if (draw_goal) {
            dc.setColor(Graphics.COLOR_BLACK, rightBandColor);
            dc.drawText(
                    screenCenterPoint[0] + MARGIN,
                    lineStart + 25,
                    Graphics.FONT_SYSTEM_TINY,
                    activityInfo.stepGoal,
                    Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawDate(dc, today) {
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
                lineStart + DIVIDER,
                Graphics.FONT_SYSTEM_TINY,
                dateString,
                Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawSun(dc) {
        var info = Position.getInfo();
        if (info != null && info.accuracy != Position.QUALITY_NOT_AVAILABLE) {
            var loc = info.position.toRadians();
            var now = Time.now();
            var sunrise_moment = sunCalc.calculate(now, loc, sunCalc.SUNRISE);
            var sunset_moment = sunCalc.calculate(now, loc, sunCalc.SUNSET);

            var timeInfoSunrise = Gregorian.info(sunrise_moment, Time.FORMAT_SHORT);
            var timeInfoSunset = Gregorian.info(sunset_moment, Time.FORMAT_SHORT); 

            var sunrise_str = timeInfoSunrise.hour.format("%02d") + timeInfoSunrise.min.format("%02d");
            var sunset_str = timeInfoSunset.hour.format("%02d") + timeInfoSunset.min.format("%02d");

            dc.setColor(Graphics.COLOR_BLACK, leftBandColor);
            dc.drawText(
                    screenCenterPoint[0] - MARGIN,
                    lineStart + 50,
                    Graphics.FONT_SYSTEM_TINY,
                    sunrise_str,
                    Graphics.TEXT_JUSTIFY_RIGHT);

            dc.setColor(Graphics.COLOR_BLACK, rightBandColor);
            dc.drawText(
                    screenCenterPoint[0] + MARGIN,
                    lineStart + 50,
                    Graphics.FONT_SYSTEM_TINY,
                    sunset_str,
                    Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawBattery(dc) {
        var stats = System.getSystemStats();
        dc.setColor(Graphics.COLOR_BLACK, rightBandColor);
        dc.drawText(
                screenCenterPoint[0] + MARGIN,
                lineStart + DIVIDER,
                Graphics.FONT_SYSTEM_TINY,
                stats.battery.format("%d"),
                Graphics.TEXT_JUSTIFY_LEFT);
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
            drawDate(offscreenDc, today);
            drawSun(offscreenDc);
            drawSteps(offscreenDc, true);
        }
        dc.drawBitmap(0, 0, offscreenBuffer);

        // update onscreen buffer
        drawTime(dc);
        drawBattery(dc);
        drawSteps(dc, false);
        drawTop(dc);
    }
}
