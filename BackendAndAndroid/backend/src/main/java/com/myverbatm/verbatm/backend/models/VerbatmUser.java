package com.myverbatm.verbatm.backend.models;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;

import java.util.ArrayList;

/**
 * Verbatm user account entity
 */
@Entity
public class VerbatmUser {

    /**
     * Unique identifier of this POV Entity in the database.
     */
    @Id
    private Long id;

    /**
     * User email
     */
    @Index
    private String email;

    /**
     * VerbatmUser name
     */
    @Index
    private String name;
    
    /**
     * User phone number
     */
    @Index
    private String phoneNumber;

    /**
     * User profile photo
     */
    @Index
    private Long profilePhotoImageID;

    //TODO(sierrakn): Store user fb friends

    /**
     * IDs of all the POV's the user has liked
     */
    @Index
    private ArrayList<Long> likedPOVIDs;


    /**
     * Returns a boolean indicating if the user is an admin or not.
     * @param user to check.
     * @return the user authorization level.
     */
    public static boolean isAdmin(final VerbatmUser user) {
        return false;
    }

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
     * Returns the user name
     * @return the user name
     */
    public final String getName() {
        return name;
    }

    /**
     * Sets user name
     * @param pName the name to set for this user
     */
    public final void setName(final String pName) {
        this.name = pName;
    }

    /**
     * Returns the user email.
     * @return the user email
     */
    public final String getEmail() {
        return email;
    }

    /**
     * Sets the user email
     * @param pEmail the email to set for this user
     */
    public final void setEmail(final String pEmail) {
        this.email = pEmail;
    }

    /**
     * Returns the user phone number
     * @return the user phone number
     */
    public final String getPhoneNumber() {
        return phoneNumber;
    }

    /**
     * Sets the user phone number
     * @param pPhoneNumber the phone number to set for this user
     */
    public final void setPhoneNumber(String pPhoneNumber) {
        this.phoneNumber = pPhoneNumber;
    }

    /**
     * Gets the user profile photo id
     * @return user profile photo id
     */
    public final Long getProfilePhotoImageID() {
        return profilePhotoImageID;
    }

    /**
     * Sets the user profile photo
     * @param profilePhotoImageID the profile photo image id to set for this user
     */
    public final  void setProfilePhotoImageID(Long profilePhotoImageID) {
        this.profilePhotoImageID = profilePhotoImageID;
    }

    /**
     * Gets the list of POV IDs that the user has liked
     * @return the list of POV IDs that the user has liked
     */
    public ArrayList<Long> getLikedPOVIDs() {
        return likedPOVIDs;
    }

    /**
     * Sets the list of POV IDs that the user has liked
     * @param likedPOVIDs the list of POV IDs that the user has liked
     */
    public void setLikedPOVIDs(ArrayList<Long> likedPOVIDs) {
        this.likedPOVIDs = likedPOVIDs;
    }
}
