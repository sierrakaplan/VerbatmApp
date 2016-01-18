package com.myverbatm.verbatm.backend.models;

/**
 * Video entity, containing a blobStore key string of where the video is stored,
 * its page number, its index in the page and text as well as text position
 */
public class Video {

    /**
     * Unique identifier of this Video Entity in the database.
     */
    private Integer id;

    /**
     * Stores which page in post this video belongs to
     */
    private Integer pageNum;

    /**
     * Stores the index of this video in the page
     */
    private Integer indexInPage;

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
    public final Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getPageNum() {
        return pageNum;
    }

    public void setPageNum(Integer pageNum) {
        this.pageNum = pageNum;
    }

    public Integer getIndexInPage() {
        return indexInPage;
    }

    public void setIndexInPage(Integer indexInPage) {
        this.indexInPage = indexInPage;
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
