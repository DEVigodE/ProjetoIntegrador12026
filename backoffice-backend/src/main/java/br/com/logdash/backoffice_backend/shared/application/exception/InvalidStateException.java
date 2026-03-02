package br.com.logdash.backoffice_backend.shared.application.exception;

public class InvalidStateException extends RuntimeException {
    public InvalidStateException(String message) {
        super(message);
    }
}
