package com.javih.add2calendar;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.TimeZone;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.pm.PackageManager.PERMISSION_GRANTED;

/**
 * Add2CalendarPlugin
 **/
public class Add2CalendarPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    private MethodChannel channel;
    private Activity activity;
    private Context context;

    /**
     * backward compatibility with embedding v1
     **/
    @SuppressWarnings("deprecation") // Registrar deprecated (v1 plugin embedding).
    public static void registerWith(Registrar registrar) {
        Add2CalendarPlugin plugin = new Add2CalendarPlugin();
        plugin.activity = registrar.activity();
        plugin.context = registrar.context();
        plugin.setupMethodChannel(registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        setupMethodChannel(flutterPluginBinding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    private void setupMethodChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, "flutter.javih.com/add_2_calendar");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        if (call.method.equals("add2Cal")) {
            try {
                insert((String) call.argument("title"),
                        (String) call.argument("desc"),
                        (String) call.argument("location"),
                        (long) call.argument("startDate"),
                        (long) call.argument("endDate"),
                        (String) call.argument("timeZone"),
                        (boolean) call.argument("allDay"),
                        (HashMap) call.argument("recurrence"),
                        (String) call.argument("invites")
                );
                result.success(true);
            } catch (NullPointerException e) {
                result.error("Exception occurred in Android code", e.getMessage(), false);
            }
        } else {
            result.notImplemented();
        }
    }

    private void insert(String title, String desc, String loc, long start, long end, String timeZone, boolean allDay, HashMap recurrence, String invites) {

        Context mContext = activity != null ? activity : context;
        Intent intent = new Intent(Intent.ACTION_INSERT, CalendarContract.Events.CONTENT_URI);
        intent.putExtra(CalendarContract.Events.TITLE, title);
        intent.putExtra(CalendarContract.Events.DESCRIPTION, desc);
        intent.putExtra(CalendarContract.Events.EVENT_LOCATION, loc);
        intent.putExtra(CalendarContract.Events.EVENT_TIMEZONE, timeZone);
        intent.putExtra(CalendarContract.Events.EVENT_END_TIMEZONE, timeZone);
        intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start);
        intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, end);
        intent.putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, allDay);

        if (recurrence != null) {
            intent.putExtra(CalendarContract.Events.RRULE, buildRRule(recurrence));
        }

        if (invites != null) {
            intent.putExtra(Intent.EXTRA_EMAIL, invites);
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    private String buildRRule(HashMap recurrence) {
        String rRule = (String) recurrence.get("rRule");
        if (rRule == null) {
            rRule = "";
            Integer freqEnum = (Integer) recurrence.get("frequency");
            if (freqEnum != null) {
                rRule += "FREQ=";
                switch (freqEnum) {
                    case 0:
                        rRule += "DAILY";
                        break;
                    case 1:
                        rRule += "WEEKLY";
                        break;
                    case 2:
                        rRule += "MONTHLY";
                        break;
                    case 3:
                        rRule += "YEARLY";
                        break;
                }
                rRule += ";";
            }
            rRule += "INTERVAL=" + (int) recurrence.get("interval") + ";";
            Integer ocurrences = (Integer) recurrence.get("ocurrences");
            if (ocurrences != null) {
                rRule += "COUNT=" + ocurrences.intValue() + ";";
            }
            Long endDateMillis = (Long) recurrence.get("endDate");
            if (endDateMillis != null) {
                Date  endDate = new Date(endDateMillis);
                DateFormat formatter = new SimpleDateFormat("yyyyMMdd'T'HHmmss");
                rRule += "UNTIL=" + formatter.format(endDate ) + ";";
            }
        }
        return rRule;
    }

    /**
     * Adds Events and Reminders in Calendar.
     */
    private void insertNoUI(String title, String desc, String loc, long start, long end, String timeZone, boolean allDay, HashMap recurrence, Double alarm, String invites) {
        final int callbackId = 42;


        boolean permissions = ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_CALENDAR) == PERMISSION_GRANTED;

        if (!permissions) {
            ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.WRITE_CALENDAR}, callbackId);
            return;
        }
        TimeZone timeZone2 = TimeZone.getTimeZone("UTC");

        //  Calendar cal = Calendar.getInstance();
        Context mContext = activity != null ? activity : context;
        Uri EVENTS_URI = CalendarContract.Events.CONTENT_URI; //Uri.parse(getCalendarUriBase(true) + "events");
        ContentResolver cr = mContext.getContentResolver();

        /** Inserting an event in calendar. */
        ContentValues values = new ContentValues();
        values.put(CalendarContract.Events.CALENDAR_ID, 3);
        values.put(CalendarContract.Events.TITLE, title);
        values.put(CalendarContract.Events.DESCRIPTION, desc);
        values.put(CalendarContract.Events.ALL_DAY, allDay);
        values.put(CalendarContract.Events.EVENT_LOCATION, loc);
        values.put(CalendarContract.Events.DTSTART, start);

        if (recurrence != null) {
            values.put(CalendarContract.Events.RRULE, buildRRule(recurrence));
            values.put(CalendarContract.Events.DURATION, (String) recurrence.get("androidNoUIEventDuration"));
        } else {
            values.put(CalendarContract.Events.DTEND, end);
        }

        if (invites != null) {
            values.put(Intent.EXTRA_EMAIL, invites);
        }

        values.put(CalendarContract.Events.EVENT_TIMEZONE, timeZone != null ? timeZone : timeZone2.getID());

        Uri event = cr.insert(EVENTS_URI, values);

        Long eventId =  Long.parseLong(event.getLastPathSegment());

        if (alarm != null) {
            /** Adding reminder for event added. */
            ContentValues reminderValues = new ContentValues();
            reminderValues.put(CalendarContract.Events.HAS_ALARM, 1);
            reminderValues = new ContentValues();
            reminderValues.put(CalendarContract.Reminders.EVENT_ID, eventId);
            reminderValues.put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT);
            reminderValues.put(CalendarContract.Reminders.MINUTES, alarm / 60);
            cr.insert(CalendarContract.Reminders.CONTENT_URI, reminderValues);
        }
    }


}
