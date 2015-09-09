package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

/**
 * Image entity used to represent an image
 */
@Entity
public class Video {

    /**
     * Unique identifier of this Page Entity in the database.
     */
    @Id
    private Long id;

    /**
     * The key of the user who uploaded this video
     */
    private Long userId;

    /**
     * The url of this video in the BlobStore
     */
    private String servingUrl;

    /**
     * Text caption to a video
     */
    private String text;


    /**
     *
     * @return the unique identifier of this Entity.
     */
    public final Long getId() {
        return id;
    }

    /**
     * Resets the Entity key to null.
     */
    public final void clearId() {
        id = null;
    }

    /**
     * Gets the key of the user who uploaded this video
     * @return the key of the user who uploaded this video
     */
    public final Long getUserId() {
        return userId;
    }

    /**
     * Sets the key of the user who uploaded this video
     * @param userId the key of the user who uploaded this video
     */
    public final void setUserId(Long userId) {
        this.userId = userId;
    }

    /**
     * Gets the url of this video in the BlobStore
     * @return The url of this video in the BlobStore
     */
    public final String getServingUrl() {
        return servingUrl;
    }

    /**
     * Sets the url of this video in the BlobStore
     * @param servingUrl The url of this video in the BlobStore
     */
    public final void setServingUrl(String servingUrl) {
        this.servingUrl = servingUrl;
    }

    /**
     * Returns the text caption of this video
     * @return the text caption of this video
     */
    public final String getText() {
        return text;
    }

    /**
     * Sets the text caption of this video
     * @param text the text caption of this video
     */
    public final void setText(String text) {
        this.text = text;
    }
}
