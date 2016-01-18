package com.myverbatm.verbatm.backend.models;

/**
 * Image entity, containing a url where the image is stored in the blobstore,
 * its page number, its index in the page and text as well as text position
 */
public class Image {

    /**
     * Unique identifier of this Page Entity in the database.
     */
    private Integer id;

    /**
     * Stores which page in post this image belongs to
     */
    private Integer pageNum;

    /**
     * Stores the index of this image in the page
     */
    private Integer indexInPage;

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
