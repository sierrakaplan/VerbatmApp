package com.myverbatm.verbatm.backend.handlers;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.blobstore.FileInfo;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Class that handles request to upload video to the blobstore
 * (from "/uploadVideo" success uri passed when requesting an upload uri from the blobstore)
 */
public class UploadVideo extends HttpServlet {

    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(ServeVideo.class.getName());

    private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

    public static final String GCS_HOST = "https://storage.googleapis.com/";

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {

        LOG.info("Request URL for upload video: " + req.getRequestURL().toString());

        try {
            //testing
            Map<String, List<FileInfo>> uploads = blobstoreService.getFileInfos(req);
            FileInfo fileInfo = uploads.get("defaultVideo").get(0);
            String objectName = fileInfo.getGsObjectName();
            LOG.info("Cloud storage object name: " + objectName);

            // substring(4) strips "/gs/" prefix
            res.getWriter().write(GCS_HOST + objectName.substring(4));
            System.out.println("Video successfully uploaded to " + GCS_HOST + objectName.substring(4));
        }
        catch (Exception e) {
            System.out.println("Video failed to upload");
        }
    }
}
