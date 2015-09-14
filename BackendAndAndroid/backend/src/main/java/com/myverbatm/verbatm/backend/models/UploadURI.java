package com.myverbatm.verbatm.backend.models;


/**
 * Wrapper class for uri String
 */
public class UploadURI {

    private String uploadURIString;

    public UploadURI(String uploadURIString) {
        this.uploadURIString = uploadURIString;
    }

    public String getUploadURIString() {
        return uploadURIString;
    }

    public void setUploadURIString(String uploadURIString) {
        this.uploadURIString = uploadURIString;
    }
}
