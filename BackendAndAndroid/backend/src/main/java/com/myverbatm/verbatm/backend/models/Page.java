package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.*;

/**
 * Page entity used to represent a page in a user's POV (shown as an AVE)
 */
@Entity
public class Page {

    /**
     * Unique identifier of this Page Entity in the database.
     */
    @Id
    private Long key;

    /**
     * Text in page
     */
    private String text;

    /**
     * Array of images in page
     */
    private Image[] images;

    /**
     * Array of videos in page
     */
    private Video[] videos;

    /**
     *
     * @return the unique identifier of this Entity.
     */
    public final Long getKey() {
        return key;
    }

    /**
     * Resets the Entity key to null.
     */
    public final void clearKey() {
        key = null;
    }

    /**
     * Returns text from the Page
     * @return text from the Page
     */
    public final String getText() {
        return text;
    }

    /**
     * Sets this page's text
     * @param text to set this Page's text to
     */
    public final void setText(String text) {
        this.text = text;
    }

    /**
     * Gets this page's images
     * @return this page's images
     */
    public final Image[] getImages() {
        return images;
    }

    /**
     * Sets this page's images
     * @param images images for this Page
     */
    public final void setImages(Image[] images) {
        this.images = images;
    }

    /**
     * Sets this page's videos
     * @return this page's videos
     */
    public final Video[] getVideos() {
        return videos;
    }

    /**
     * Sets this page's videos
     * @param videos videos for this Page
     */
    public final void setVideos(Video[] videos) {
        this.videos = videos;
    }
}
