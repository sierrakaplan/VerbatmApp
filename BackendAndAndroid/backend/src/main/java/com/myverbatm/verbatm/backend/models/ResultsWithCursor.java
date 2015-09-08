package com.myverbatm.verbatm.backend.models;

import java.util.List;

/**
 * ResultsWithCursor class is a helper class, useful for queries that return a list
 * of instances of model classes (the results)
 * as well as a cursorString so that the client can query where they left off
 */
public class ResultsWithCursor<T> {

    public final List<T> results;
    public final String cursorString;

    public ResultsWithCursor(List<T> results, String cursorString) {
        this.results = results;
        this.cursorString = cursorString;
    }
}
