package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;

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
    @Index
    private Integer indexInPage;

    /**
     * The key of the user who uploaded this video
     */
    @Index
    private Long userId;

    /**
     * The blobKey for this video in the blobstore
     */
    private String blobKeyString;

    /**
     * Text caption to a video
     */
    private String text;

    /**
     * The y position of the text
     */
    private Float textYPosition;

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
     * Returns the blobKey for this video in the blobstore
     * @return the blobKey for this video in the blobstore
     */
    public String getBlobKeyString() {
        return blobKeyString;
    }

    /**
     * Sets the blobKey for this video in the blobstore
     * @param blobKeyString the blobKey for this video in the blobstore
     */
    public void setBlobKeyString(String blobKeyString) {
        this.blobKeyString = blobKeyString;
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

    public Float getTextYPosition() {
        return textYPosition;
    }

    public void setTextYPosition(Float textYPosition) {
        this.textYPosition = textYPosition;
    }
}
