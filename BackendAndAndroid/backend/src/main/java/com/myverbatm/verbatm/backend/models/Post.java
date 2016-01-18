package com.myverbatm.verbatm.backend.models;

import java.sql.Timestamp;

/**
 * A Post in a User's channel, containing one or more pages
 */
public class Post {

    private Integer id;

    private Integer channelId;

    private Integer sharedFromPostId;

    private Timestamp dateCreated;

    // each page knows which number in post it is
    private PageListWrapper pages;

    // each image and each video knows which page it belongs to
    private ImageListWrapper images;

    private VideoListWrapper videos;

    public Post() {
    }

    public Post(Integer id, Integer channelId, Integer sharedFromPostId, Timestamp dateCreated) {
        this.id = id;
        this.channelId = channelId;
        this.dateCreated = dateCreated;
        this.dateCreated = dateCreated;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getChannelId() {
        return channelId;
    }

    public void setChannelId(Integer channelId) {
        this.channelId = channelId;
    }

    public Integer getSharedFromPostId() {
        return sharedFromPostId;
    }

    public void setSharedFromPostId(Integer sharedFromPostId) {
        this.sharedFromPostId = sharedFromPostId;
    }

    public Timestamp getDateCreated() {
        return dateCreated;
    }

    public void setDateCreated(Timestamp dateCreated) {
        this.dateCreated = dateCreated;
    }

    public PageListWrapper getPages() {
        return pages;
    }

    public void setPages(PageListWrapper pages) {
        this.pages = pages;
    }

    public ImageListWrapper getImages() {
        return images;
    }

    public void setImages(ImageListWrapper images) {
        this.images = images;
    }

    public VideoListWrapper getVideos() {
        return videos;
    }

    public void setVideos(VideoListWrapper videos) {
        this.videos = videos;
    }
}
