package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.ServiceException;
import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.config.Named;
import com.google.appengine.api.users.User;
import com.googlecode.objectify.Objectify;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.OfyService;
import com.myverbatm.verbatm.backend.models.POV;
import com.myverbatm.verbatm.backend.models.Page;
import com.myverbatm.verbatm.backend.models.VerbatmUser;
import com.myverbatm.verbatm.backend.utils.EndpointUtil;

import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

import static com.myverbatm.verbatm.backend.OfyService.*;

/**
 * Exposes REST API over POV resources
 */
@Api(name = "verbatmApp", version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)
@ApiClass(resource = "pov",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

/**
 * An endpoint class we are exposing.
 */
public class POVEndpoint {

    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(POVEndpoint.class.getName());

    /**
     * Lists all the entities inserted in datastore.
     *
     * @param user the user requesting the entities.
     * @return the list of all entities persisted.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @SuppressWarnings({"cast", "unchecked"})
    public final List<POV> listPOV(final User user) throws
        ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return ofy().load().type(POV.class).list();
    }

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
    public final POV getPOV(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return findPOV(id);
    }

    /**
     * Inserts the entity into App Engine datastore. It uses HTTP POST method.
     *
     * @param pov  the entity to be inserted.
     * @param user the user trying to insert the entity.
     * @return The inserted entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "POST")
    public final POV insertPOV(final POV pov, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAuthenticated(user);

        // Do not use the key provided by the caller; use a generated key.
        pov.clearKey();
        ofy().save().entity(pov).now();
        return pov;
    }

    /**
     * Updates a entity. It uses HTTP PUT method.
     *
     * @param pov the entity to be updated.
     * @param user    the user trying to update the entity.
     * @return The updated entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "PUT")
    public final POV updatePOV(final POV pov, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        ofy().save().entity(pov).now();

        return pov;
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
    public final void removePOV(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        POV pov = findPOV(id);
        if (pov == null) {
            LOG.info(
                "POV " + id + " not found, skipping deletion.");
            return;
        }
        ofy().delete().entity(pov).now();
    }

    /**
     * Searches an entity by ID.
     *
     * @param id the pov ID to search
     * @return the pov associated to id
     */
    private POV findPOV(final Long id) {
        return ofy().load().type(POV.class).id(id).now();
    }

}
