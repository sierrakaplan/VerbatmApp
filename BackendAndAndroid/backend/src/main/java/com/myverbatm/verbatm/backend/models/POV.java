package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.*;

import java.util.Date;

/**
 * POV entity used to represent what the user posts to Verbatm in full (previously called Article or Story)
 */
@Entity
public class POV {

    /**
     * Unique identifier of this POV Entity in the database.
     */
    @Id
    private Long key;

    /**
     * VerbatmUser given title for the POV
     */
    private String title;

    /**
     * The url of the cover picture in the blobstore
     */
    private String coverPicUrl;

    /**
     * Date the POV was published
     */
    private Date datePublished;

    /**
     * Number of up votes this POV has received
     */
    private Integer numUpVotes;

    /**
     * POV's creator's user key
     */
    private Long creatorUserKey;

    /**
     * Array of pages in the POV
     */
    private Page[] pages;

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
     * Returns the POV's title
     * @return the POV's title
     */
    public final String getTitle() {
        return title;
    }

    /**
     * Sets the POV's title
     * @param title the title to be set for this POV
     */
    public final void setTitle(String title) {
        this.title = title;
    }

    /**
     * Returns the url of the cover picture from the blobstore
     * @return the url of the cover picture from the blobstore
     */
    public final String getCoverPicUrl() {
        return coverPicUrl;
    }

    /**
     * Sets the url of the cover picture from the blobstore
     * @param coverPicUrl the url of the cover picture from the blobstore
     */
    public final void setCoverPicUrl(String coverPicUrl) {
        this.coverPicUrl = coverPicUrl;
    }

    /**
     * Returns the date the POV was published
     * @return the date the POV was published
     */
    public final Date getDatePublished() {
        return datePublished;
    }

    /**
     * Sets the date the POV was published
     * @param datePublished the publish date to be set for this POV
     */
    public final void setDatePublished(Date datePublished) {
        this.datePublished = datePublished;
    }

    /**
     * Returns the number of up votes this POV has received
     * @return the number of up votes this POV has received
     */
    public Integer getNumUpVotes() {
        return numUpVotes;
    }

    /**
     * Sets the number of up votes this POV has received
     * @param numUpVotes the number of up votes this POV has received
     */
    public void setNumUpVotes(Integer numUpVotes) {
        this.numUpVotes = numUpVotes;
    }

    /**
     * Returns the user key for this POV's creator
     * @return the user key for this POV's creator
     */
    public final Long getCreatorUserKey() {
        return creatorUserKey;
    }

    /**
     * Sets the user key of the creator of this POV
     * @param creatorUserKey the user key of the creator for this POV to be set
     */
    public final void setCreatorUserKey(Long creatorUserKey) {
        this.creatorUserKey = creatorUserKey;
    }

    /**
     * Returns the pages within this POV
     * @return the pages within this POV
     */
    public final Page[] getPages() {
        return pages;
    }

    /**
     * Sets the pages within this POV
     * @param pages The pages to be set for this POV
     */
    public final void setPages(Page[] pages) {
        this.pages = pages;
    }
}
