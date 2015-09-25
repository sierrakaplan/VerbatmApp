package com.myverbatm.verbatm.backend.models;

import com.google.appengine.api.datastore.Email;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.api.users.User;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

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
    private Email email;

    /**
     * VerbatmUser name
     */
    private String name;
    
    /**
     * User phone number
     */
    private PhoneNumber phoneNumber;

    /**
     * User profile photo
     */
    private Long profilePhotoImageID;

    //TODO(sierrakn): Store user friends


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
    public final Email getEmail() {
        return email;
    }

    /**
     * Sets the user email
     * @param pEmail the email to set for this user
     */
    public final void setEmail(final Email pEmail) {
        this.email = pEmail;
    }

    /**
     * Returns the user phone number
     * @return the user phone number
     */
    public final PhoneNumber getPhoneNumber() {
        return phoneNumber;
    }

    /**
     * Sets the user phone number
     * @param pPhoneNumber the phone number to set for this user
     */
    public final void setPhoneNumber(PhoneNumber pPhoneNumber) {
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
}
