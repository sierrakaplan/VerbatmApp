package com.myverbatm.verbatm.backend.models;

import java.sql.Timestamp;

/**
 * A Post in a User's channel, containing one or more pages
 */
public class Post {

    private Long id;

    private Long channelId;

    private Long sharedFromPostId;

    private Timestamp dateCreated;

    public Post(Long id, Long channelId, Long sharedFromPostId, Timestamp dateCreated) {
        this.id = id;
        this.channelId = channelId;
        this.dateCreated = dateCreated;
        this.dateCreated = dateCreated;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getChannelId() {
        return channelId;
    }

    public void setChannelId(Long channelId) {
        this.channelId = channelId;
    }

    public Long getSharedFromPostId() {
        return sharedFromPostId;
    }

    public void setSharedFromPostId(Long sharedFromPostId) {
        this.sharedFromPostId = sharedFromPostId;
    }

    public Timestamp getDateCreated() {
        return dateCreated;
    }

    public void setDateCreated(Timestamp dateCreated) {
        this.dateCreated = dateCreated;
    }
}
