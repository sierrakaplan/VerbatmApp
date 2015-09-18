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
     * Stores the index of this video in the page
     */
    private Integer indexInPage;

    /**
     * The key of the user who uploaded this video
     */
    private Long userId;

    /**
     * The cloud storage link where this video is stored
     */
    private String cloudStorageURL;

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

    public Integer getIndexInPage() {
        return indexInPage;
    }

    public void setIndexInPage(Integer indexInPage) {
        this.indexInPage = indexInPage;
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
     * Returns the cloud storage url where this video is stored
     * @return the cloud storage url where this video is stored
     */
    public String getCloudStorageURL() {
        return cloudStorageURL;
    }

    /**
     * Sets the cloud storage url where this video is stored
     * @param cloudStorageURL the cloud storage url where this video is stored
     */
    public void setCloudStorageURL(String cloudStorageURL) {
        this.cloudStorageURL = cloudStorageURL;
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
