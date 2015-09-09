package com.myverbatm.verbatm.backend.models;

import com.google.appengine.api.datastore.*;
import com.googlecode.objectify.annotation.*;
import com.googlecode.objectify.annotation.Entity;

import java.util.Date;
import java.util.List;

/**
 * POV entity used to represent what the user posts to Verbatm in full (previously called Article or Story)
 */
@Entity
public class POV {

    /**
     * Unique identifier of this POV Entity in the database.
     */
    @Id
    private Long id;

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
     * POV's creator's user id
     */
    private Long creatorUserId;

    /**
     * Array of page keys in the POV
     */
    private List<Long> pageIds;


    public POV() {

    }

//    /**
//     * Creates a POV instance from an entity of POV type
//     * @param entity
//     */
//    public POV(com.google.appengine.api.datastore.Entity entity) {
//        this.id = entity.getKey().getId();
//        this.title = (String) entity.getProperty("title");
//        this.coverPicUrl = (String) entity.getProperty("coverPicUrl");
//        this.datePublished = (Date) entity.getProperty("datePublished");
//        this.numUpVotes = (Integer) entity.getProperty("numUpVotes");
//        this.creatorUserId = (Long) entity.getProperty("creatorUserId");
//        this.pages = (List<Page>) entity.getProperty("pages");
//    }

    /**
     *
     * @return the unique identifier of this Entity.
     */
    public final Long getId() {
        return id;
    }

    /**
     * Resets the Entity id to null.
     */
    public final void clearId() {
        id = null;
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
     * Returns the user id for this POV's creator
     * @return the user id for this POV's creator
     */
    public final Long getCreatorUserId() {
        return creatorUserId;
    }

    /**
     * Sets the user id of the creator of this POV
     * @param creatorUserId the user id of the creator for this POV to be set
     */
    public final void setCreatorUserId(Long creatorUserId) {
        this.creatorUserId = creatorUserId;
    }

    /**
     * Returns the list of Page IDs for this POV
     * @return the list of Page IDs for this POV
     */
    public List<Long> getPageIds() {
        return pageIds;
    }

    /**
     * Sets the list of Page IDs for this POV
     * @param pageIds the list of Page IDs for this POV
     */
    public void setPageIds(List<Long> pageIds) {
        this.pageIds = pageIds;
    }
}
