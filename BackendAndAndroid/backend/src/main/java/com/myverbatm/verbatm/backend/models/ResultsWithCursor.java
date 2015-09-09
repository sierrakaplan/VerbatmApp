package com.myverbatm.verbatm.backend.models;

import java.util.List;

/**
 * ResultsWithCursor class is a helper class, useful for queries that return a list
 * of POVInfos (the results)
 * as well as a cursorString so that the client can query where they left off
 */
public class ResultsWithCursor {

    public final List<POVInfo> results;
    public final String cursorString;

    public ResultsWithCursor(List results, String cursorString) {
        this.results = results;
        this.cursorString = cursorString;
    }
}
