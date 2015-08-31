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
     * Date the POV was published
     */
    private Date datePublished;

    /**
     * POV's creator's user key
     */
    private Long creatorUserKey;

    /**
     * Array of what labels associated with the POV (given by user)
     * These are the topics of the POV
     */
    private String[] whats;

    /**
     * Where label associated with the POV (given by user)
     * This is the location of the POV
     */
    //TODO: will probably have to change this to a location object
    private String where;

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
     * Returns the what tags associated with the POV
     * @return the what tags
     */
    public final String[] getWhats() {
        return whats;
    }

    /**
     * Sets the what tags associated with the POV
     * @param whats the what tags to be set associated with this POV
     */
    public final void setWhats(String[] whats) {
        this.whats = whats;
    }

    /**
     * Returns the where tag associated with this POV
     * @return the where tag
     */
    public final String getWhere() {
        return where;
    }

    /**
     * Sets the where tag associated with this POV
     * @param where the where tag to be set
     */
    public final void setWhere(String where) {
        this.where = where;
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
