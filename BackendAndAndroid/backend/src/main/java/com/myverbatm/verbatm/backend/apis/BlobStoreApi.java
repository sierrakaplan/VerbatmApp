package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.ServingUrlOptions;
import com.myverbatm.verbatm.backend.Constants;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import br.com.caelum.vraptor.Path;
import br.com.caelum.vraptor.Result;
import br.com.caelum.vraptor.view.Results;

import static br.com.caelum.vraptor.view.Results.http;

@Api(name = "verbatmApp", version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)
@ApiClass(resource = "blobstore",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

@Resource
@Path("/media")
public class BlobStoreApi {

    private final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
    private HttpServletRequest request = null;
    private Result result = null;

    public BlobStoreApi() {
    }

    public BlobStoreApi(Result result, HttpServletRequest request) {
        this.result = result;
        this.request = request;
    }

    @Path("/createUploadURI")
    @ApiMethod(path="/createUploadURI")
    public void uploadURI() {
        String uploadURI = blobstoreService.createUploadUrl("/image/upload");
        result.use(http()).body(uploadURI);
    }

    @Path("/uploadImage")
    @ApiMethod(path="/uploadImage")
    public void uploadImage() {
        Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(request);
        BlobKey blobKey = blobs.get("defaultImage").get(0);

        ImagesService imagesService = ImagesServiceFactory.getImagesService();
        ServingUrlOptions options = ServingUrlOptions.Builder.withBlobKey(blobKey);
        String imageUrl = imagesService.getServingUrl(options);

        result.use(Results.http()).body(imageUrl);
    }
}
