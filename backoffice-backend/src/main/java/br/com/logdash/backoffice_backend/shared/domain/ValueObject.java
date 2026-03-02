package br.com.logdash.backoffice_backend.shared.domain;

public abstract class ValueObject {

    @Override
    public abstract boolean equals(Object o);

    @Override
    public abstract int hashCode();
}
