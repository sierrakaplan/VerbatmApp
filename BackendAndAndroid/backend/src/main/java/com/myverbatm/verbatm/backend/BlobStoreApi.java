package com.myverbatm.verbatm.backend;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.ServingUrlOptions;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import br.com.caelum.vraptor.Path;
import br.com.caelum.vraptor.Result;
import br.com.caelum.vraptor.view.Results;

import static br.com.caelum.vraptor.view.Results.http;

@Resource
@Path("/media")
public class BlobStoreApi {

    private final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
    private HttpServletRequest request = null;
    private Result result = null;

    public BlobStoreApi(Result result, HttpServletRequest request) {
        this.result = result;
        this.request = request;
    }

    @Path("/createUploadURI")
    public void uploadURI() {
        String uploadURI = blobstoreService.createUploadUrl("/image/upload");
        result.use(http()).body(uploadURI);
    }

    @Path("/uploadImage")
    public void uploadImage() {
        Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(request);
        BlobKey blobKey = blobs.get("defaultImage").get(0);

        ImagesService imagesService = ImagesServiceFactory.getImagesService();
        ServingUrlOptions options = ServingUrlOptions.Builder.withBlobKey(blobKey);
        String imageUrl = imagesService.getServingUrl(options);

        result.use(Results.http()).body(imageUrl);
    }
}
