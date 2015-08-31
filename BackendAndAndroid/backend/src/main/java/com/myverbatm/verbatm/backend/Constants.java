package com.myverbatm.verbatm.backend;

/**
 * Created by sierrakaplan-nelson on 8/21/15.
 */
public final class Constants {

    /**
     * Google Cloud Messaging API key
     */
    public static final String GCM_API_KEY= "AIzaSyC4ozEf8SvY1CsvelX5TsBosCPXyKGG7pU";

    /**
     * Android client ID from Google Cloud console
     */
    public static final String ANDROID_CLIENT_ID = "";

    /**
     * iOS client ID from Google Cloud console
     */
    public static final String IOS_CLIENT_ID = "340461213452-2s3rsl904usfhcr4afskpb5b9pdnrmai.apps.googleusercontent.com";

    /**
     * Web client ID from Google Cloud console
     */
    public static final String WEB_CLIENT_ID = "340461213452-vrmr2vt1v1adgkra963vomulfv449odv.apps.googleusercontent.com";

    /**
     * Audience ID used to limit access to some client to the API.
     */
    public static final String AUDIENCE_ID = WEB_CLIENT_ID;

    /**
     * API package name.
     */
    public static final String API_OWNER = "verbatmbackend.verbatm.myverbatm.com";

    /**
     * API package path
     */
    public static final String API_PACKAGE_PATH = "com.myverbatm.verbatm.backend.apis";

    /**
     * Default constructor, never called
     */
    private Constants() {}
}
