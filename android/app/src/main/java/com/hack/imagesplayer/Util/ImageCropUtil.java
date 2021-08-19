package com.hack.imagesplayer.Util;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.Log;


import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


import io.flutter.plugin.common.MethodChannel;

import static android.content.ContentValues.TAG;

public class ImageCropUtil {

    private ExecutorService executor;

    String path;
    double scale;
    double left;
    double top;
    double right;
    double bottom;
    Activity activity;
    RectF area;

    public ImageCropUtil(String path, double scale, double left, double top, double right, double bottom, Activity activity) {
        this.path = path;
        this.scale = scale;
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
        this.activity = activity;
        this.area = new RectF((float) left, (float) top, (float) right, (float) bottom);
    }

    private void ui(@NonNull Runnable runnable) {
        activity.runOnUiThread(runnable);
    }

    public void cropImage(final MethodChannel.Result result) {
        io(new Runnable() {
            @Override
            public void run() {
                File srcFile = new File(path);
                if (!srcFile.exists()) {
                    ui(new Runnable() {
                        @Override
                        public void run() {
                            result.error("INVALID", "Image source cannot be opened", null);
                        }
                    });
                    return;
                }

                Bitmap srcBitmap = BitmapFactory.decodeFile(path, null);
                if (srcBitmap == null) {
                    ui(new Runnable() {
                        @Override
                        public void run() {
                            result.error("INVALID", "Image source cannot be decoded", null);
                        }
                    });
                    return;
                }

                ImageOptions options = decodeImageOptions(path);
                if (options.isFlippedDimensions()) {
                    Matrix transformations = new Matrix();
                    transformations.postRotate(options.getDegrees());
                    Bitmap oldBitmap = srcBitmap;
                    srcBitmap = Bitmap.createBitmap(oldBitmap,
                            0, 0,
                            oldBitmap.getWidth(), oldBitmap.getHeight(),
                            transformations, true);
                    oldBitmap.recycle();
                }
                Log.i(TAG, "run: " + path + " " + options.getWidth() + " " + area.width() + " " + scale);

                int width = (int) (options.getWidth() * area.width() * scale);
                int height = (int) (options.getHeight() * area.height() * scale);

                Bitmap dstBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
                Canvas canvas = new Canvas(dstBitmap);

                Paint paint = new Paint();
                paint.setAntiAlias(true);
                paint.setFilterBitmap(true);
                paint.setDither(true);

                Rect srcRect = new Rect((int) (srcBitmap.getWidth() * area.left),
                        (int) (srcBitmap.getHeight() * area.top),
                        (int) (srcBitmap.getWidth() * area.right),
                        (int) (srcBitmap.getHeight() * area.bottom));
                Rect dstRect = new Rect(0, 0, width, height);
                canvas.drawBitmap(srcBitmap, srcRect, dstRect, paint);

                try {
                    final File dstFile = createTemporaryImageFile();
                    compressBitmap(dstBitmap, dstFile);
                    ui(new Runnable() {
                        @Override
                        public void run() {
                            result.success(dstFile.getAbsolutePath());
                        }
                    });
                } catch (final IOException e) {
                    ui(new Runnable() {
                        @Override
                        public void run() {
                            result.error("INVALID", "Image could not be saved", e);
                        }
                    });
                } finally {
                    canvas.setBitmap(null);
                    dstBitmap.recycle();
                    srcBitmap.recycle();
                }
            }
        });
    }

    private synchronized void io(@NonNull Runnable runnable) {
        if (executor == null) {
            executor = Executors.newCachedThreadPool();
        }
        executor.execute(runnable);
    }


    private void compressBitmap(Bitmap bitmap, File file) throws IOException {
        OutputStream outputStream = new FileOutputStream(file);
        try {
            boolean compressed = bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
            if (!compressed) {
                throw new IOException("Failed to compress bitmap into JPEG");
            }
        } finally {
            try {
                outputStream.close();
            } catch (IOException ignore) {
            }
        }
    }

    private File createTemporaryImageFile() throws IOException {
        File directory = activity.getCacheDir();
        String name = "image_crop_" + UUID.randomUUID().toString();
        return File.createTempFile(name, ".jpg", directory);
    }

    private ImageOptions decodeImageOptions(String path) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, options);
        return new ImageOptions(options.outWidth, options.outHeight, 0);
    }


    static final class ImageOptions {
        private final int width;
        private final int height;
        private final int degrees;

        ImageOptions(int width, int height, int degrees) {
            this.width = width;
            this.height = height;
            this.degrees = degrees;
        }

        int getHeight() {
            return isFlippedDimensions() ? width : height;
        }

        int getWidth() {
            return isFlippedDimensions() ? height : width;
        }

        int getDegrees() {
            return degrees;
        }

        boolean isFlippedDimensions() {
            return degrees == 90 || degrees == 270;
        }

        public boolean isRotated() {
            return degrees != 0;
        }
    }


}

