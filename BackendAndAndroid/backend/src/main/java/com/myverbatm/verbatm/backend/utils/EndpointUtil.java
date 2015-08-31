package com.myverbatm.verbatm.backend.utils;

import com.google.api.server.spi.response.UnauthorizedException;
import com.google.appengine.api.users.User;
import com.myverbatm.verbatm.backend.models.VerbatmUser;

/**
 * Created by sierrakaplan-nelson on 8/26/15.
 */
public class EndpointUtil {


    /**
     * Default constructor, never called.
     */
    private EndpointUtil() {
    }

    /**
     * Throws an exception if the user is not an admin.
     * @param user User object to be checked if it represents an admin.
     * @throws com.google.api.server.spi.response.UnauthorizedException when the
     *      user object does not represent an admin.
     */
    public static void throwIfNotAdmin(final VerbatmUser user) throws
            UnauthorizedException {
        if (!VerbatmUser.isAdmin(user)) {
            throw new UnauthorizedException(
                    "You are not authorized to perform this operation");
        }
    }

    /**
     * Throws an exception if the user object doesn't represent an authenticated
     * call.
     * @param user User object to be checked if it represents an authenticated
     *      caller.
     * @throws com.google.api.server.spi.response.UnauthorizedException when the
     *      user object does not represent an admin.
     */
    public static void throwIfNotAuthenticated(final VerbatmUser user) throws
            UnauthorizedException {
        if (user == null) {
            throw new UnauthorizedException(
                    "Only authenticated users may invoke this operation");
        }
    }
}
