package com.myverbatm.verbatm.backend.handlers;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.blobstore.FileInfo;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.ServingUrlOptions;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.logging.Logger;

/**
 * Class that handles request to upload image to the blobstore
 * (from "/uploadImage" success uri passed when requesting an upload uri from the blobstore)
 */
public class UploadImage extends HttpServlet {

    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(ServeVideo.class.getName());

    private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {

        LOG.info("Request URL for upload image: " + req.getRequestURL().toString());

        try {
            Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(req);
            BlobKey blobKey = blobs.get("defaultImage").get(0);

            ImagesService imagesService = ImagesServiceFactory.getImagesService();
            ServingUrlOptions options = ServingUrlOptions.Builder.withBlobKey(blobKey);
            String imageUrl = imagesService.getServingUrl(options);

            res.getWriter().write(imageUrl);
            System.out.println("Image successfully uploaded");
        }
        catch (Exception e) {
            System.out.println("Image failed to upload");
        }
    }
}
