package com.myverbatm.verbatm.backend.models;

/**
 * Page entity used to represent a page in a user's post
 */
public class Page {

    /**
     * Unique identifier of this Page Entity in the database.
     */
    private Integer id;

    /**
     * Stores the index of this page in the POV
     */
    private Integer pageNumberInPost;

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

    public Integer getPageNumberInPost() {
        return pageNumberInPost;
    }

    public void setPageNumberInPost(Integer pageNumberInPost) {
        this.pageNumberInPost = pageNumberInPost;
    }
}
