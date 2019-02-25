package com.javih.add2calendar;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.provider.CalendarContract;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** Add2CalendarPlugin */
public class Add2CalendarPlugin implements MethodCallHandler {
    private final Registrar mRegistrar;

    public Add2CalendarPlugin(Registrar registrar) {
        mRegistrar = registrar;
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter.javih.com/add_2_calendar");
        channel.setMethodCallHandler(new Add2CalendarPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("add2Cal")) {
            try {
                insert((String) call.argument("title"), (String) call.argument("desc"), (String) call.argument("location"), (long) call.argument("startDate"), (long) call.argument("endDate"), (boolean) call.argument("allDay"));
                result.success(true);
            } catch (NullPointerException e) {
                result.error("Exception ocurred in Android code", e.getMessage(), false);
            }
        } else {
            result.notImplemented();
        }
    }

    @SuppressLint("NewApi")
    public void insert(String title, String desc, String loc, long start, long end, boolean allDay) {
        Context context = getActiveContext();
        Intent intent = new Intent(Intent.ACTION_INSERT, CalendarContract.Events.CONTENT_URI);
        intent.putExtra(CalendarContract.Events.TITLE, title);
        intent.putExtra(CalendarContract.Events.DESCRIPTION, desc);
        intent.putExtra(CalendarContract.Events.EVENT_LOCATION, loc);
        intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start);
        intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, end);
        intent.putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, allDay);
        context.startActivity(intent);
    }

    private Context getActiveContext() {
        return (mRegistrar.activity() != null) ? mRegistrar.activity() : mRegistrar.context();
    }
}
