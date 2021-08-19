package com.hack.imagesplayer;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.CancellationSignal;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.util.Pair;
import android.util.Size;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;
import com.hack.imagesplayer.Util.ImageCropUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import static android.content.ContentValues.TAG;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.hack.imagesplayer/ImageGallery";
    private static final String EDITOR_CHANNEL = "com.hack.imagesplayer/ImageEditor";
    private static final String UTIL_CHANNEL = "com.hack.imagesplayer/Util";


    @RequiresApi(api = Build.VERSION_CODES.Q)
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EDITOR_CHANNEL).setMethodCallHandler((call, result) -> {
            if ("memoryToMemory".equals(call.method)) {
                addBorder(call.argument("image"), call.argument("size"), result);
            }
        });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), UTIL_CHANNEL).setMethodCallHandler((call, result) -> {
            if ("loadCompressedImage".equals(call.method)) {
                loadCompressedImage(this, call.argument("imagePath"), call.argument("width"), call.argument("height"), result);
            }
        });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {

                    switch (call.method) {
                        case "GetGallery":
                            getGallery(this, call.argument("albumId"), result);
                            break;
                        case "GetGalleryBuckets":
                            getGalleryBuckets(this, result);
                            break;
                        case "GetGalleryImage":
                            getGalleryImage(call.argument("imageDirectory"), call.argument("displayName"), result);
                            break;
                        case "GetThumbImage":
                            getThumbImage(this, call.argument("thumbUri"), result);
                        case "cropImage":

                            if ("cropImage".equals(call.method)) {
                                String path = call.argument("path");
                                double scale = call.argument("scale");
                                double left = call.argument("left");
                                double top = call.argument("top");
                                double right = call.argument("right");
                                double bottom = call.argument("bottom");
                                RectF area = new RectF((float) left, (float) top, (float) right, (float) bottom);
                                ImageCropUtil imageCropUtil = new ImageCropUtil(path, (float) scale, left, top, right, bottom, this.getActivity());
                                imageCropUtil.cropImage(result);
                            }
                    }
                });
    }

    private void loadCompressedImage(Context context, String imagePath, double w, double h, MethodChannel.Result result) {
        LoadCompressImageTask loadCompressImageTask = new LoadCompressImageTask(context, result);
        String[] params = {imagePath, String.valueOf((int) w), String.valueOf((int) h)};
        loadCompressImageTask.execute(params);
//        File file = new File(imagePath);
//        Glide
//                .with(getApplicationContext())
//                .asBitmap()
//                .load(file)
//                .into(new SimpleTarget<Bitmap>((int)w, (int)h) {
//                    @Override
//                    public void onResourceReady(@NonNull Bitmap bitmap, @Nullable Transition<? super Bitmap> transition) {
//                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
//                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
//                        byte[] byteArray = stream.toByteArray();
//                        result.success(byteArray);
//                    }
//
//                    @Override
//                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
//                        super.onLoadFailed(errorDrawable);
//                        result.success(null);
//                    }
//                });
    }

    private void addBorder(String imagePath, Double size, final MethodChannel.Result result) {

        File file = new File(imagePath);
        Glide
                .with(getApplicationContext())
                .asBitmap()
                .load(file)
                .into(new SimpleTarget<Bitmap>(150, 150) {
                    @Override
                    public void onResourceReady(@NonNull Bitmap bitmap, @Nullable Transition<? super Bitmap> transition) {

                        Bitmap newBitmap = Bitmap.createBitmap((int) (bitmap.getWidth() + size * 4), (int) (bitmap.getHeight() + size * 4), bitmap.getConfig());
                        Canvas canvas = new Canvas(newBitmap);
                        canvas.drawColor(Color.RED);
                        canvas.drawBitmap(bitmap, (int) (size * 2.0), (int) (size * 2.0), null);
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        newBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
                        byte[] byteArray = stream.toByteArray();
                        newBitmap.recycle();
                        result.success(byteArray);
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        super.onLoadFailed(errorDrawable);
                        result.success(null);
                    }
                });
    }

    void getGalleryBuckets(Context context, MethodChannel.Result result) {
        GetGalleryBucketsTask getGalleryBucketsTask = new GetGalleryBucketsTask(context, result);
        getGalleryBucketsTask.execute();
    }

    private void getGallery(Context context, String albumId, MethodChannel.Result result) {
        Pair<MethodChannel.Result, String> params = new Pair<MethodChannel.Result, String>(result, albumId);
        GetGalleryTask loadImages = new GetGalleryTask(context, result);
        loadImages.execute(params);
    }

    private void getGalleryImage(String imageDirectory, String imageName, MethodChannel.Result result) {
        HashMap<String, String> res = new HashMap<>();
        String path = Environment.getExternalStorageDirectory() + "/" + imageDirectory + imageName;
        res.put("image", imageDirectory);
        result.success(res);
    }

    private void getThumbImage(Context context, String thumbUri, MethodChannel.Result result) {
        GetThumbImage getThumbImage = new GetThumbImage(context, result);
        getThumbImage.execute(thumbUri);
    }
}


class LoadCompressImageTask extends AsyncTask<String[], Void, Void> {
    @SuppressLint("StaticFieldLeak")
    Context context;
    MethodChannel.Result result;
    byte[] byteArray = null;


    LoadCompressImageTask(Context ct, MethodChannel.Result rt) {
        context = ct;
        result = rt;
    }

    @Override
    protected void onPostExecute(Void aVoid) {
        super.onPostExecute(aVoid);
        result.success(byteArray);
    }

    @Override
    protected Void doInBackground(String[]... filePath) {
        File file = new File(filePath[0][0]);
        Glide
                .with(context)
                .asBitmap()
                .load(file)
                .into(new SimpleTarget<Bitmap>(Integer.parseInt(filePath[0][1]), Integer.parseInt(filePath[0][2])) {
                    @Override
                    public void onResourceReady(@NonNull Bitmap bitmap, @Nullable Transition<? super Bitmap> transition) {
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
                        byte[] byteArray = stream.toByteArray();
                        setBytes(byteArray);
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        super.onLoadFailed(errorDrawable);
                        setBytes(null);
                    }
                });
        return  null;
    }

    private void setBytes(byte[] bytes) {
        byteArray = bytes;
    }
}

class GetThumbImage extends AsyncTask<String, Void, HashMap<String, byte[]>> {
    @SuppressLint("StaticFieldLeak")
    Context context;
    MethodChannel.Result result;

    GetThumbImage(Context ct, MethodChannel.Result rt) {
        context = ct;
        result = rt;
    }

    @Override
    protected void onPostExecute(HashMap<String, byte[]> stringHashMap) {
        super.onPostExecute(stringHashMap);
        result.success(stringHashMap);
    }

    @Override
    protected HashMap<String, byte[]> doInBackground(String... thumbUris) {
        HashMap<String, byte[]> res = new HashMap<>();

        Bitmap bitmap;
        try {
            bitmap = MediaStore.Images.Thumbnails.getThumbnail(
                    context.getContentResolver(), Long.parseLong(thumbUris[0]),
                    MediaStore.Images.Thumbnails.MICRO_KIND,
                    (BitmapFactory.Options) null);
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 40, stream);
            byte[] byteArray = stream.toByteArray();
            bitmap.recycle();
            res.put("thumbBytes", byteArray);

        } catch (Exception e) {
            Log.i(TAG, "Failed to fetch some Items GetThumbImage " + thumbUris[0]);
        }
        return res;
    }
}

class GetGalleryBucketsTask extends AsyncTask<Void, Void, HashMap<String, byte[]>> {
    private Context context;
    private final MethodChannel.Result result;

    GetGalleryBucketsTask(Context ct, MethodChannel.Result rt) {
        context = ct;
        result = rt;
    }

    @Override
    protected void onPostExecute(HashMap<String, byte[]> stringHashMap) {
        super.onPostExecute(stringHashMap);
        result.success(stringHashMap);
    }

    @Override
    protected HashMap<String, byte[]> doInBackground(Void... voids) {
        HashMap<String, byte[]> ret = new HashMap<>();
        HashMap<String, String> uniques = new HashMap<>();

        ContentResolver contentResolver = context.getContentResolver();
        Uri uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        String[] projection;
        String sortOrder;

        projection = new String[]{
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID,
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) ? MediaStore.Images.Media.VOLUME_NAME : null,
                MediaStore.Images.Media._ID,
                MediaStore.Video.Media.DATE_ADDED,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.DATA
        };
        sortOrder = MediaStore.Video.Media.DATE_ADDED + " DESC";

        Cursor cursor = contentResolver.query(
                uri, // Uri
                projection,
                null,
                null,
                sortOrder
        );

        if (cursor == null) {
            Log.i(TAG, "doInBackground: Something Went Wrong.");
        } else if (!cursor.moveToFirst()) {
            Log.i(TAG, "doInBackground: No Images Found on SD Card.");
        } else if (cursor.getCount() > 0) {
            do {

                String bucketId;
                String bucketDisplayName;

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    bucketId = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_ID));
                    bucketDisplayName = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME));

                    if (bucketDisplayName != null && !uniques.containsKey(bucketDisplayName)) {
                        String id = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
                        String volumeName = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.VOLUME_NAME));
                        String imageUri = MediaStore.Images.Media.getContentUri(volumeName).toString();
                        Size size = new Size(100, 100);
                        Bitmap bitmap;
                        byte[] byteArray;
                        try {
                            CancellationSignal cancellationSignal = new CancellationSignal();
                            bitmap = context.getContentResolver().loadThumbnail(Uri.parse(imageUri + "/" + id), size, cancellationSignal);
                            ByteArrayOutputStream stream = new ByteArrayOutputStream();
                            bitmap.compress(Bitmap.CompressFormat.PNG, 40, stream);
                            byteArray = stream.toByteArray();
                            bitmap.recycle();
                        } catch (IOException e) {
                            Log.i(TAG, "Failed to fetch some Items");
                            continue;
                        }

                        String count = getBucketImagesCount(context, bucketDisplayName);
                        JSONObject mJson = new JSONObject();
                        try {
                            mJson.put("albumId", bucketId);
                            mJson.put("albumName", bucketDisplayName);
                            mJson.put("count", count);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        ret.put(mJson.toString(), byteArray);
                        uniques.put(bucketDisplayName, "");
                    }
                } else {

                    bucketId = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.BUCKET_ID));
                    bucketDisplayName = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME));

                    if (bucketDisplayName != null && !uniques.containsKey(bucketDisplayName)) {
                        String id = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));

                        Bitmap bitmap;
                        byte[] byteArray = null;

                        try {
                            bitmap = MediaStore.Images.Thumbnails.getThumbnail(
                                    context.getContentResolver(), Long.parseLong(id),
                                    MediaStore.Images.Thumbnails.MICRO_KIND,
                                    (BitmapFactory.Options) null);

                            ByteArrayOutputStream stream = new ByteArrayOutputStream();
                            bitmap.compress(Bitmap.CompressFormat.PNG, 40, stream);
                            byteArray = stream.toByteArray();
                            bitmap.recycle();
                        } catch (Exception e) {
                            Log.i(TAG, "Failed to fetch some Items");
                        }
                        String count = getBucketImagesCount(context, bucketDisplayName);

                        JSONObject mJson = new JSONObject();
                        try {
                            mJson.put("albumId", bucketId);
                            mJson.put("albumName", bucketDisplayName);
                            mJson.put("count", count);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        ret.put(mJson.toString(), byteArray);
                        uniques.put(bucketDisplayName, "");
                    }
                }
            } while (cursor.moveToNext());
        }
        if (cursor != null) {
            cursor.close();
        }
        return ret;
    }

    private String getBucketImagesCount(Context context, String bucketDisplayName) {
        String ct = "0";
        ContentResolver contentResolver = context.getContentResolver();
        Uri uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        Cursor cursor = null;
        String[] projection = null;
        String sortOrder;

        sortOrder = MediaStore.Images.Media.DATE_MODIFIED + " DESC";
        cursor = contentResolver.query(
                uri, // Uri
                null,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME + " = ? ",
                new String[]{bucketDisplayName},
                sortOrder
        );
        if (cursor == null) {
            Log.i(TAG, "getBucketImagesCount: Something Went Wrong.");
        } else if (!cursor.moveToFirst()) {
            Log.i(TAG, "getBucketImagesCount: No Images Found on SD Card.");
        } else if (cursor.getCount() > 0) {
            ct = String.valueOf(cursor.getCount());
        }
        if (cursor != null) {
            cursor.close();
        }
        return ct;
    }
}

class GetGalleryTask extends AsyncTask<Pair<MethodChannel.Result, String>, Void, ArrayList<String>> {
    private final Context context;
    private final MethodChannel.Result result;

    GetGalleryTask(Context ct, MethodChannel.Result rt) {
        context = ct;
        result = rt;
    }

    @Override
    protected void onPostExecute(ArrayList<String> strings) {
        super.onPostExecute(strings);
        result.success(strings);
    }

    @SafeVarargs
    @Override
    protected final ArrayList<String> doInBackground(Pair<MethodChannel.Result, String>... pairs) {
        ArrayList<String> res = new ArrayList<>();

        ContentResolver contentResolver = context.getContentResolver();
        Uri uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        Cursor cursor;
        String[] projection;
        String sortOrder;

        sortOrder = MediaStore.Images.Media.DATE_MODIFIED + " DESC";
        projection = new String[]{
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID,
                MediaStore.Images.Media.DATE_MODIFIED,
                MediaStore.Images.Media._ID,
                MediaStore.Video.Media.DATE_ADDED,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.DATA
        };
        cursor = contentResolver.query(
                uri, // Uri
                projection,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME + " = ? ",
                new String[]{pairs[0].second},
                sortOrder
        );

        if (cursor == null) {
            Log.i(TAG, "getGallery: Something Went Wrong.");
        } else if (!cursor.moveToFirst()) {
            Log.i(TAG, "getGallery: No Images Found on SD Card.");
        } else if (cursor.getCount() > 0) {
            do {
                try {
                    String id = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
                    String displayName = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME));
                    String dateAdded = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED));

                    String bucketDisplayName;
                    String imageDirectory;

                    bucketDisplayName = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME));
                    imageDirectory = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA));

                    long date = Long.parseLong(dateAdded);
                    Date d = new Date(date * 1000L);
                    dateAdded = new SimpleDateFormat("dd-MM-yyyy hh:mm aa", Locale.ENGLISH).format(d);

                    JSONObject mJson = new JSONObject();
                    try {
                        mJson.put("id", id);
                        mJson.put("displayName", displayName);
                        mJson.put("bucketDisplayName", bucketDisplayName);
                        //   Image directory is actually the complete path here
                        mJson.put("imageStoragePath", imageDirectory);
                        mJson.put("imageDirectory", imageDirectory);
                        //   We can use this id to fetch the path again
                        mJson.put("imageThumbPath", id);
                        mJson.put("dateAdded", dateAdded);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    res.add(mJson.toString());
                } catch (Exception e) {
                    Log.i(TAG, "doInBackground: " + e.getMessage());
                }
            } while (cursor.moveToNext());
        }

        if (cursor != null)
            cursor.close();
        return res;
    }
}

