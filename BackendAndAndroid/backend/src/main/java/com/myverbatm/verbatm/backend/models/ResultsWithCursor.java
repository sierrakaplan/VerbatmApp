package com.myverbatm.verbatm.backend.models;

/**
 * ResultsWithCursor class
 */
public class ResultsWithCursor {
    public final T t;
    public final U u;

    public ResultsWithCursor(T t, U u) {
        this.t= t;
        this.u= u;
    }
}
