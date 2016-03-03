package com.myverbatm.verbatm.backend.models;

import com.google.appengine.api.datastore.*;
import com.googlecode.objectify.annotation.*;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Index;
import com.sun.org.apache.xpath.internal.operations.Bool;

import java.util.ArrayList;
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
    @Index
    private String title;

    /**
     * Date the POV was published
     */
    @Index
    private Date datePublished;

    /**
     * Number of up votes this POV has received
     */
    @Index
    private Long numUpVotes;

    /**
     * POV's creator's user id
     */
    @Index
    private Long creatorUserId;

    /**
     * Array of page keys in the POV
     */
    @Index
    private ArrayList<Long> pageIds;

    /**
     * Array of user ids who have liked this POV
     */
    @Index
    private ArrayList<Long> usersWhoHaveLikedIDs;


    public POV() {

    }

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
     * Returns the date the POV was published
     * @return the date the POV was published
     */
    public Date getDatePublished() {
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
    public Long getNumUpVotes() {
        return numUpVotes;
    }

    /**
     * Sets the number of up votes this POV has received
     * @param numUpVotes the number of up votes this POV has received
     */
    public void setNumUpVotes(Long numUpVotes) {
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
    public void setPageIds(ArrayList<Long> pageIds) {
        this.pageIds = pageIds;
    }

    /**
     * Gets the list of user ids of users who have liked this POV
     * @return the list of user ids of users who have liked this POV
     */
    public ArrayList<Long> getUsersWhoHaveLikedIDs() {
        return usersWhoHaveLikedIDs;
    }

    /**
     * Sets the list of user ids of users who have liked this POV
     * @param usersWhoHaveLikedIDs the list of user ids of users who have liked this POV
     */
    public void setUsersWhoHaveLikedIDs(ArrayList<Long> usersWhoHaveLikedIDs) {
        this.usersWhoHaveLikedIDs = usersWhoHaveLikedIDs;
    }

}
