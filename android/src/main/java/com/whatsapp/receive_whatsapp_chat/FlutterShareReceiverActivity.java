package com.whatsapp.receive_whatsapp_chat;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import static com.whatsapp.receive_whatsapp_chat.ReceiveWhatsappChatPlugin.IS_MULTIPLE;
import static com.whatsapp.receive_whatsapp_chat.ReceiveWhatsappChatPlugin.PATH;
import static com.whatsapp.receive_whatsapp_chat.ReceiveWhatsappChatPlugin.TEXT;
import static com.whatsapp.receive_whatsapp_chat.ReceiveWhatsappChatPlugin.TITLE;
import static com.whatsapp.receive_whatsapp_chat.ReceiveWhatsappChatPlugin.TYPE;

/**
 * main activity super, handles eventChannel sink creation
 * , share intent parsing and redirecting to eventChannel sink stream
 *
 * @author Duarte Silveira
 * @version 1
 * @since 25/05/18
 */
public class FlutterShareReceiverActivity extends FlutterActivity {

    public static final String STREAM = "plugins.flutter.io/receiveshare";

    private static final String CHANNEL = "com.whatsapp.chat/chat";

    private EventChannel.EventSink eventSink = null;
    private boolean inited = false;
    private List<Intent> backlog = new ArrayList<>();
    private boolean ignoring = false;

    @SuppressLint("NewApi")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("analyze")) {
                        String URL = call.argument("data");
                        Uri students = Uri.parse(URL);
                        Cursor c = getContentResolver().query(students, null, null, null, null);

                        try {
                            final InputStream openInputStream = getContentResolver().openInputStream(students);
                            BufferedReader r = new BufferedReader(new InputStreamReader(openInputStream));

                            assert c != null;
                            c.moveToFirst();
                            ArrayList arrayList = new ArrayList();
                            arrayList.add(c.getString(0));
                            arrayList.add(String.valueOf(c.getString(1)));
                            String textMsg = "";
                            List<String> lines = new ArrayList<String>();

                            for (String line; (line = r.readLine()) != null; ) {

                                lines.add(line);
                                textMsg += line;
                                int countSlash = textMsg.length() - textMsg.replaceAll("/", "").length();
                                int countDot = textMsg.length() - textMsg.replaceAll("\\.", "").length();
                                int countTwoDots = textMsg.length() - textMsg.replaceAll(":", "").length();
                                boolean isSlash = textMsg.contains(" - ");
                                boolean isComa = textMsg.contains(", ");

                                if ((countSlash >= 2 || countDot >= 2) && countTwoDots >= 2 && isSlash && isComa) {
                                    if (textMsg.contains("AM") || textMsg.contains("PM")) {
                                        arrayList.add(textMsg);
                                    } else {
                                        try {
                                            String splited = textMsg.split(" - ")[0].split(", ")[1];
                                            final SimpleDateFormat sdf = new SimpleDateFormat("H:mm");
                                            final Date dateObj = sdf.parse(splited);
                                            String correcetTime = new SimpleDateFormat("K:mm a").format(dateObj);
                                            arrayList.add(textMsg.replaceAll(splited, correcetTime));
                                        } catch (Exception e) {
                                            Log.d("Error:", String.valueOf(e));
                                        }
                                    }
                                    textMsg = "";
                                }
                            }
                            result.success(arrayList);
                        } catch (Exception e) {
                            ArrayList arrayList = new ArrayList();
                            Log.d("Error:", String.valueOf(e));
                            result.success(arrayList);
                        }
                    } else if (call.method.equals("OpenWhatsapp")) {
                        //openWhatsApp();
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!inited) {
            init(getFlutterEngine().getDartExecutor().getBinaryMessenger(), this);
        }
    }

    public void init(BinaryMessenger flutterView, Context context) {
        Log.i(getClass().getSimpleName(), "initializing eventChannel");

        context.startActivity(new Intent(context, ShareReceiverActivityWorker.class));

        // Handle other intents, such as being started from the home screen
        new EventChannel(flutterView, STREAM).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object args, EventChannel.EventSink events) {
                Log.i(getClass().getSimpleName(), "adding listener");
                eventSink = events;
                ignoring = false;
                for (int i = 0; i < backlog.size(); i++) {
                    handleIntent(backlog.remove(i));
                }
            }

            @Override
            public void onCancel(Object args) {
                Log.i(getClass().getSimpleName(), "cancelling listener");
                ignoring = true;
                eventSink = null;
            }
        });

        inited = true;

        handleIntent(getIntent());

    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    public void handleIntent(Intent intent) {
        // Get intent, action and MIME type
        String action = intent.getAction();
        String type = intent.getType();

        if (Intent.ACTION_SEND.equals(action) && type != null) {
            String sharedTitle = intent.getStringExtra(Intent.EXTRA_SUBJECT);
            if ("text/plain".equals(type)) {
                Log.i(getClass().getSimpleName(), "receiving shared title: " + sharedTitle);
                String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
                Log.i(getClass().getSimpleName(), "receiving shared text: " + sharedText);
                if (eventSink != null) {
                    Map<String, String> params = new HashMap<>();
                    params.put(TYPE, type);
                    params.put(TEXT, sharedText);
                    if (!TextUtils.isEmpty(sharedTitle)) {
                        params.put(TITLE, sharedTitle);
                    }
                    eventSink.success(params);
                } else if (!ignoring && !backlog.contains(intent)) {
                    backlog.add(intent);
                }
            } else {
                Log.i(getClass().getSimpleName(), "receiving shared title: " + sharedTitle);
                Uri sharedUri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
                Log.i(getClass().getSimpleName(), "receiving shared file: " + sharedUri);
                if (eventSink != null) {
                    Map<String, String> params = new HashMap<>();
                    params.put(TYPE, type);
                    params.put(PATH, sharedUri.toString());
                    if (!TextUtils.isEmpty(sharedTitle)) {
                        params.put(TITLE, sharedTitle);
                    }
                    if (!intent.hasExtra(Intent.EXTRA_TEXT)) {
                        params.put(TEXT, intent.getStringExtra(Intent.EXTRA_TEXT));
                    }
                    eventSink.success(params);
                } else if (!ignoring && !backlog.contains(intent)) {
                    backlog.add(intent);
                }
            }

        } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
            Log.i(getClass().getSimpleName(), "receiving shared files!");
            ArrayList<Uri> uris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
            if (eventSink != null) {
                Map<String, String> params = new HashMap<>();
                params.put(TYPE, type);
                params.put(IS_MULTIPLE, "true");
                for (int i = 0; i < uris.size(); i++) {
                    params.put(Integer.toString(i), uris.get(i).toString());
                }
                eventSink.success(params);
            } else if (!ignoring && !backlog.contains(intent)) {
                backlog.add(intent);
            }

        }
    }
}
