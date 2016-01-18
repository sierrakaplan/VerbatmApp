package com.myverbatm.verbatm.backend;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyFactory;
import com.googlecode.objectify.ObjectifyService;
import com.myverbatm.verbatm.backend.models.*;

/**
 * Objectify service wrapper so we can statically register our persistence classes
 * More on Objectify here : https://code.google.com/p/objectify-appengine/
 */
public final class OfyService {

    /**
     * Default constructor, never called
     */
    private OfyService() {}

    static {
        factory().register(RegistrationRecord.class);
        factory().register(Image.class);
        factory().register(Page.class);
        factory().register(VerbatmUser.class);
        factory().register(Video.class);
    }

    /**
     * Returns the Objectify service wrapper
     * @return The Objectify service wrapper
     */
    public static Objectify ofy() {
        return ObjectifyService.ofy();
    }

    /**
     * Returns the Objectify factory service
     * @return The Objectify factory service
     */
    public static ObjectifyFactory factory() {
        return ObjectifyService.factory();
    }
}
