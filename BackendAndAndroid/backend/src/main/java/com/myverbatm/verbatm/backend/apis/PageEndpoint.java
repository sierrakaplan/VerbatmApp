package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.ServiceException;
import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.config.Named;
import com.google.appengine.api.users.User;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.models.Page;

import java.util.List;
import java.util.logging.Logger;

import static com.myverbatm.verbatm.backend.OfyService.*;

/**
 * Exposes REST API over page resources
 */
@Api(name = "verbatmApp", version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)
@ApiClass(resource = "page",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

/**
 * An endpoint class we are exposing.
 */
public class PageEndpoint {
    /**
     * Log output.
     */
    private static final Logger LOG =
        Logger.getLogger(PageEndpoint.class.getName());

    /**
     * Lists all the entities inserted in datastore.
     *
     * @param user the user requesting the entities.
     * @return the list of all entities persisted.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @SuppressWarnings({"cast", "unchecked"})
    public final List<Page> listpage(final User user) throws
        ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return ofy().load().type(Page.class).list();
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
    public final Page getPage(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return findPage(id);
    }

    /**
     * Inserts the entity into App Engine datastore. It uses HTTP POST method.
     *
     * @param page the entity to be inserted.
     * @param user the user trying to insert the entity.
     * @return The inserted entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "POST")
    public final Page insertPage(final Page page, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAuthenticated(user);

        // Do not use the key provided by the caller; use a generated key.
        page.clearId();

        ofy().save().entity(page).now();

        return page;
    }

    /**
     * Updates a entity. It uses HTTP PUT method.
     *
     * @param page the entity to be updated.
     * @param user the user trying to update the entity.
     * @return The updated entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "PUT")
    public final Page updatePage(final Page page, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        ofy().save().entity(page).now();
        return page;
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
    public final void removePage(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        Page page = findPage(id);
        if (page == null) {
            LOG.info("Page " + id + " not found, skipping deletion.");
            return;
        }
        ofy().delete().entity(page).now();
    }

    /**
     * Searches an entity by ID.
     *
     * @param id the page ID to search
     * @return the page associated to id
     */
    private Page findPage(final Long id) {
        return ofy().load().type(Page.class).id(id).now();
    }

}
