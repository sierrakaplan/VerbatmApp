package com.myverbatm.verbatm.backend.models;

/**
 * Verbatm user
 */
public class VerbatmUser {

    /**
     * Unique identifier of this User in the database.
     */
    private Long id;

    /**
     * VerbatmUser name
     */
    private String name;

    /**
     * User email
     */
    private String email;
    
    /**
     * User phone number
     */
    private String phoneNumber;

    /**
     * User profile photo url
     */
    private String profileImageUrl;

    /**
     *
     * @return the unique identifier of this Entity.
     */
    public final Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
}
