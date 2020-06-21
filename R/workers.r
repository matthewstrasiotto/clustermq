#' Creates a pool of workers
#'
#' @param n_jobs      Number of jobs to submit (0 implies local processing)
#' @param data        Set common data (function, constant args, seed)
#' @param reuse       Whether workers are reusable or get shut down after call
#' @param template    A named list of values to fill in template
#' @param log_worker  Write a log file for each worker
#' @param qsys_id     Character string of QSys class to use
#' @param verbose     Print message about worker startup
#' @param ...         Additional arguments passed to the qsys constructor
#' @return            An instance of the QSys class
#' @export
workers = function(n_jobs, data=NULL, reuse=TRUE, template=list(), log_worker=FALSE,
                   qsys_id=getOption("clustermq.scheduler", qsys_default),
                   verbose=FALSE, ...) {
    if (n_jobs == 0)
        qsys_id = "LOCAL"

    gc() # be sure to clean up old zmq handles (zeromq/libzmq/issues/1108)
    qsys = get(toupper(qsys_id), envir=parent.env(environment()))
    qsys = qsys$new(data=data, reuse=reuse, ...)

    if (log_worker && is.null(template$log_file)) {
        .Deprecated(msg=paste("'log_worker' is deprecated and will be removed in v0.9.",
                              "Use template=list(log_file=...) instead"))
        template$log_file = paste0("cmq", qsys$id, ".log")
    }

    do.call(qsys$submit_jobs, c(template, list(n_jobs=n_jobs, verbose=verbose)))
    qsys
}
