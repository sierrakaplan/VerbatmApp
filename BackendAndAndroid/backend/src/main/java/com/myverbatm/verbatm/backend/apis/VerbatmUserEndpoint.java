package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.ServiceException;
import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.config.Named;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Email;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.users.User;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.models.VerbatmUser;

import java.util.List;
import java.util.logging.Logger;

import static com.myverbatm.verbatm.backend.OfyService.ofy;

/**
 * Exposes REST API over Verbatm user resources
 */
@Api(name = "verbatmApp", version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)
@ApiClass(resource = "verbatmuser",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

/**
 * An endpoint class we are exposing.
 */
public class VerbatmUserEndpoint {

    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(VerbatmUserEndpoint.class.getName());

    private static final DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

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
    public final VerbatmUser getUser(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return findUser(id);
    }

    /**
     * Returns the verbatm user with the given email, which should be unique
     * @return the verbatm user with the given email, which should be unique
     */
    @ApiMethod(path="/getUserFromEmail", httpMethod = "GET")
    public final VerbatmUser getUserFromEmail(@Named("email") final String email) {

        LOG.info("Get user from email: " + email);
        Query.Filter emailFilter = new Query.FilterPredicate("email", Query.FilterOperator.EQUAL, email);
        Query userFromEmailQuery = new Query("VerbatmUser")
            .setFilter(emailFilter);
        PreparedQuery preparedQuery = datastore.prepare(userFromEmailQuery);

        Entity entity = preparedQuery.asSingleEntity();
        return findUser(entity.getKey().getId());
    }

    /**
     * Inserts the entity into App Engine datastore. It uses HTTP POST method.
     *
     * @param verbatmUser the entity to be inserted.
     * @param user        the user trying to insert the entity.
     * @return The inserted entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "POST")
    public final VerbatmUser insertUser(final VerbatmUser verbatmUser, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAuthenticated(user);

        // Do not use the key provided by the caller; use a generated key.
        verbatmUser.clearId();
        ofy().save().entity(verbatmUser).now();
        return verbatmUser;
    }

    /**
     * Updates a entity. It uses HTTP PUT method.
     *
     * @param verbatmUser the entity to be updated.
     * @param user        the user trying to update the entity.
     * @return The updated entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "PUT")
    public final VerbatmUser updateUser(final VerbatmUser verbatmUser, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        ofy().save().entity(verbatmUser).now();

        return verbatmUser;
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
    public final void removeUser(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        VerbatmUser verbatmUser = findUser(id);
        if (verbatmUser == null) {
            LOG.info(
                "User " + id + " not found, skipping deletion.");
            return;
        }
        ofy().delete().entity(verbatmUser).now();
    }


    /**
     * Searches an entity by ID.
     *
     * @param id the Verbatm user ID to search
     * @return the Verbatm user associated to id
     */
    private VerbatmUser findUser(final Long id) {
        return ofy().load().type(VerbatmUser.class).id(id).now();
    }
}
