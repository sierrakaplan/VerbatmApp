package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.ServiceException;
import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.config.Named;
import com.google.appengine.api.users.User;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.models.Image;

import java.util.logging.Logger;

import static com.myverbatm.verbatm.backend.OfyService.ofy;

/**
 * Exposes REST API over image resources
 */
@Api(name = "verbatmApp", version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)
@ApiClass(resource = "image",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

/**
 * An endpoint class we are exposing.
 */
public class ImageEndpoint {

    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(ImageEndpoint.class.getName());

    /**
     * Gets the entity having primary key id.
     *
     * @param id   the primary key of the java bean.
     * @param user the user requesting the entity.
     * @return The entity with primary key id.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "GET")
    public final Image getImage(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return findImage(id);
    }

    /**
     * Inserts the entity into App Engine datastore. It uses HTTP POST method.
     *
     * @param image  the entity to be inserted.
     * @param user the user trying to insert the entity.
     * @return The inserted entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "POST")
    public final Image insertImage(final Image image, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAuthenticated(user);

        // Do not use the key provided by the caller; use a generated key.
        image.clearId();
        ofy().save().entity(image).now();
        return image;
    }

    /**
     * Updates a entity. It uses HTTP PUT method.
     *
     * @param image the entity to be updated.
     * @param user    the user trying to update the entity.
     * @return The updated entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "PUT")
    public final Image updateImage(final Image image, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        ofy().save().entity(image).now();

        return image;
    }

    /**
     * Removes the entity with primary key id. It uses HTTP DELETE method.
     *
     * @param id   the primary key of the entity to be deleted.
     * @param user the user trying to delete the entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "DELETE")
    public final void removeImage(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        Image image = findImage(id);
        if (image == null) {
            LOG.info(
                "Image " + id + " not found, skipping deletion.");
            return;
        }
        ofy().delete().entity(image).now();
    }

    /**
     * Searches an entity by ID.
     *
     * @param id the image ID to search
     * @return the image associated to id
     */
    private Image findImage(final Long id) {
        return ofy().load().type(Image.class).id(id).now();
    }
}
