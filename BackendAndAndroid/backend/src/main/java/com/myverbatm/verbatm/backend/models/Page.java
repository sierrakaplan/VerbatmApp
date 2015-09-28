package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.*;

import java.util.ArrayList;
import java.util.List;

/**
 * Page entity used to represent a page in a user's POV (shown as an AVE)
 */
@Entity
public class Page {

    /**
     * Unique identifier of this Page Entity in the database.
     */
    @Id
    private Long id;

    /**
     * Stores the index of this page in the POV
     */
    @Index
    private Integer indexInPOV;

    /**
     * Array of images ids in page
     */
    private ArrayList<Long> imageIds;

    /**
     * Array of videos ids in page
     */
    private ArrayList<Long> videoIds ;

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
     * Returns the index of this page in the POV
     * @return  the index of this page in the POV
     */
    public Integer getIndexInPOV() {
        return indexInPOV;
    }

    /**
     * Sets the index of this page in the POV
     * @param indexInPOV the index of this page in the POV
     */
    public void setIndexInPOV(Integer indexInPOV) {
        this.indexInPOV = indexInPOV;
    }

    /**
     * Returns the list of Video ids stored in page
     * @return the list of Video ids stored in page
     */
    public ArrayList<Long> getVideoIds() {
        return videoIds;
    }

    /**
     * Sets the list of Video ids stored in page
     * @param videoIds the list of Video ids stored in page
     */
    public void setVideoIds(ArrayList<Long> videoIds) {
        this.videoIds = videoIds;
    }

    /**
     * Returns the list of Image ids stored in page
     * @return the list of Image ids stored in page
     */
    public ArrayList<Long> getImageIds() {
        return imageIds;
    }

    /**
     * Sets the list of Image ids stored in page
     * @param imageIds the list of Image ids stored in page
     */
    public void setImageIds(ArrayList<Long> imageIds) {
        this.imageIds = imageIds;
    }
}
