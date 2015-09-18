package com.myverbatm.verbatm.backend.handlers;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.logging.Logger;

/**
 * Gets the blob store key string from the request,
 */
public class ServeVideo extends HttpServlet {

    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(ServeVideo.class.getName());

    private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

    /**
     * Gets the blob store key string from the request,
     * creates a BlobKey from it and then serves it back to the response
     */
    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse res)
        throws IOException {

        LOG.info("Request URL for serve video: " + req.getRequestURL().toString());
        BlobKey blobKey = new BlobKey(req.getParameter("blob-key"));
        blobstoreService.serve(blobKey, res);
        res.addHeader("Content-Type", "video/mp4");
        LOG.info("Serving video response: " + res.toString());
    }
}
