package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;

/**
 * Image entity used to represent an image
 */
@Entity
public class Image {

    /**
     * Unique identifier of this Page Entity in the database.
     */
    @Id
    private Long id;

    /**
     * Stores the index of this image in the page
     */
    @Index
    private Integer indexInPage;

    /**
     * The key of the user who uploaded this image
     */
    @Index
    private Long userKey;

    /**
     * The serving url to access this image in the blobstore from ImagesService
     */
    private String servingUrl;

    /**
     * Text caption to an image
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
     * Gets the key of the user who uploaded this image
     * @return the key of the user who uploaded this image
     */
    public final Long getUserKey() {
        return userKey;
    }

    /**
     * Sets the key of the user who uploaded this image
     * @param userKey the key of the user who uploaded this image
     */
    public final void setUserKey(Long userKey) {
        this.userKey = userKey;
    }

    /**
     * Gets the url of this image in the BlobStore
     * @return The url of this image in the BlobStore
     */
    public final String getServingUrl() {
        return servingUrl;
    }

    /**
     * Sets the url of this image in the BlobStore
     * @param servingUrl The url of this image in the BlobStore
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

    public Float getTextYPosition() {
        return textYPosition;
    }

    public void setTextYPosition(Float textYPosition) {
        this.textYPosition = textYPosition;
    }
}
