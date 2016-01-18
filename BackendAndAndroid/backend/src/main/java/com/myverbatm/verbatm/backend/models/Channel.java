package com.myverbatm.verbatm.backend.models;

import java.sql.Timestamp;

/**
 * Describes a channel (its name and owner's user id)
 */
public class Channel {

    private Integer id;

    private String name;

    private Integer creatorUserId;

    private Timestamp ts;

    public Channel() {}

    public Channel(Integer id, String name, Integer creatorUserId, Timestamp ts) {
        this.id = id;
        this.name = name;
        this.creatorUserId = creatorUserId;
        this.ts = ts;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Timestamp getTs() {
        return ts;
    }

    public void setTs(Timestamp ts) {
        this.ts = ts;
    }

    public Integer getCreatorUserId() {
        return creatorUserId;
    }

    public void setCreatorUserId(Integer creatorUserId) {
        this.creatorUserId = creatorUserId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
