package com.hack.imagesplayer.Models;

import android.media.Image;

public class ImageMeta {
    String id;
    String displayName;
    String bucketDisplayName;
    String imageStoragePath;
    String imageDirectory;
    String imageThumbPath;
    String dateAdded;

    public ImageMeta(String id, String displayName, String bucketDisplayName, String imageStoragePath, String imageDirectory, String imageThumbPath, String dateAdded) {
        this.id = id;
        this.displayName = displayName;
        this.bucketDisplayName = bucketDisplayName;
        this.imageStoragePath = imageStoragePath;
        this.imageDirectory = imageDirectory;
        this.imageThumbPath = imageThumbPath;
        this.dateAdded = dateAdded;
    }
}
