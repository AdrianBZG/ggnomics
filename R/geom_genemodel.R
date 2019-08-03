#' Gene models
#'
#' @description \code{geom_genemodel} is a specialised geom for drawing gene
#'   models. It draws coding sequences thicker than untranslated regions and
#'   styles introns with arrows, lines or chevrons. By default, it separates
#'   different overlapping models along the y-axis.
#'
#' @inheritParams ggplot2::geom_rect
#' @param data The data to be displayed in this layer. There are three options:
#'
#'   If \code{`NULL`}, the default, the data is inherited from the plot data as
#'   specified in the call to \code{\link[ggplot2]{ggplot}}.
#'
#'   A \code{`data.frame`} or other object will override the plot data. All
#'   objects will be fortified to produce a \code{data.frame}. See
#'   \code{\link[ggplot2]{fortify}} for which variables will be created.
#'
#'   A \code{`function`} will be called with a single argument, the plot data.
#'   The return value must be a \code{`data.frame`}, and will be used as the
#'   layer data. A \code{`function`} can be created from a \code{`formula`}
#'   (e.g. \code{`~ head(.x, 10)`}).
#'
#'   A duo of wrapper functions for acquiring gene model data are available in
#'   \link[=genemodel_helpers]{genemodel helpers}.
#' @param position Position adjustment, either as a string, or the result of a
#'   call to a position adjustment function.
#'   \code{\link[ggnomics]{position_disjoint_ranges}} is recommended when gene
#'   models overlap.
#' @param intron.style By default, introns are displayed as a series of arrows
#'   (\code{"arrowline"}) when a \code{strand} aesthetic contains \code{"+"} or
#'   \code{"-"}. Alternatively, a \code{"chevron"} option is available. In
#'   absence of strand information, the intron style defaults to a simple line
#'   (\code{"line"}).
#' @param arrow Specification for arrow heads, as created by
#'   \code{\link[grid]{arrow}}. Only applicable when \code{intron.style =
#'   "arrowline"} (the default). Defaults internally to \code{grid::arrow(length
#'   = grid::unit(2, "mm"))}.
#' @param arrow.freq A \code{\link[grid]{unit}} object specifying the distance
#'   over which arrows should be repeated. Only applicable when
#'   \code{intron.style = "arrowline"}.
#' @param chevron.height A \code{numeric} of length one specifying how high
#'   chevrons should rise relative to coding sequences. Only applicable when
#'   \code{intron.style = "chevron"}.
#'
#' @details The expected input format is that every exon has its own row. The
#'   genomic location of the exons are to be given to the \code{xmin} aesthetic
#'   for start positions and the \code{xmax} aesthetic for the end position.
#'   Genes are interpreted to be groups of exons specified by the required
#'   \code{group} aesthetic. Exons that belong to the same group will be
#'   connected by introns.
#'
#'   Optionally, a distinction between coding sequences (CDSs) and untranslated
#'   regions (UTRs) can be made for each exon by providing the \code{type}
#'   aesthetic, which checks for a case-insensitive match with the string
#'   \code{"utr"}. Also, strand information can be used to style introns in the
#'   \code{"arrowline"} or \code{"chevron"} fashion by providing a \code{strand}
#'   aesthetic, which assumes that \code{"+"} should be oriented left-to-right
#'   and \code{"-"} should be right-to-left. A \code{y} aesthetic can be
#'   provided to offset the gene models from the x-axis. The \code{thickness}
#'   aesthetic controls how thick a CDS should be drawn in y-axis units.
#'
#'   Alternatively, this geom can also be used to visualise transcript models,
#'   in which case the following recommendations apply. Supply a transcript name
#'   or transcript ID to the group aesthetic instead of a gene name or gene ID.
#'   Set \code{intron.style = "chevron"} which is more appropriate for splice
#'   junctions.
#'
#' @section Aesthetics:
#'
#'   \code{geom_genemodel} understands the following aesthetics (required
#'   aesthetics are in bold, optional aesthetics in italics)
#'
#'   \itemize{ \item{\strong{xmax}} \item{\strong{xmin}} \item{\strong{group}}
#'   \item{\emph{y}} \item{\emph{thickness}} \item{\emph{type}}
#'   \item{\emph{strand}} \item{colour} \item{fill} \item{size} \item{linetype}
#'   \item{alpha} }
#'
#' @seealso \code{\link[ggnomics]{position_disjoint_ranges}}
#'
#' @export
#'
#' @examples
#' # Two arbitrary gene models
#' df <- data.frame(
#'   start = c(0, 1, 3, 7, 2, 7, 8),
#'   end   = c(1, 2, 5, 8, 6, 8, 11),
#'   type  = c("UTR", rep("CDS", 5), "UTR"),
#'   gene  =  gl(2, 4, 7, c("A", "B")),
#'   strand = gl(2, 4, 7, c("+", "-"))
#' )
#'
#' # Even though genes overlap they are seperated
#' ggplot(df) +
#'   geom_genemodel(aes(
#'     xmin = start, xmax = end, group = gene, # Required aes
#'     strand = strand, type = type # Optional aes
#'   ))
geom_genemodel <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = position_disjoint_ranges(extend = 1e4),
  ...,
  intron.style = "arrowline",
  arrow = NULL,
  arrow.freq = unit(4, "mm"),
  chevron.height = 1,
  linejoin = "mitre",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  intron.style <- match.arg(
    intron.style,
    c("arrowline", "line", "chevron")
  )
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomGeneModel,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      intron.style = intron.style,
      chevron.height = chevron.height,
      arrow = arrow,
      arrow.freq = arrow.freq,
      linejoin = linejoin, na.rm = na.rm, ...
    )
  )
}

#' @rdname geom_genemodel
#' @usage NULL
#' @format NULL
#' @importFrom ggplot2 aes ggproto GeomRect draw_key_polygon
#' @importFrom grid gpar rectGrob grob gTree gList
#' @importFrom rlang eval_tidy
#' @importFrom scales alpha
#' @export
GeomGeneModel <- ggproto(
  "GeomGeneModel", GeomRect,
  default_aes = aes(colour = "grey35", fill = "grey35",
                    size = 0.5, linetype = 1, alpha = NA,
                    y = 0, thickness = 0.9, strand = "*", type = "CDS"),
  required_aes = c("xmin", "xmax", "group"),
  optional_aes = c("strand", "type", "y", "thickness"),
  draw_panel = function(
    self, data, panel_params, coord,
    intron.style = "line", chevron.height = 1,
    arrow = NULL, arrow.freq = unit(4, "mm"),
    linejoin = "mitre"
  ) {

    coords <- coord$transform(data, panel_params)
    coords$colour <- scales::alpha(coords$colour, coords$alpha)
    coords$fill <- scales::alpha(coords$fill, coords$alpha)

    # Build exons
    rect <- grid::rectGrob(
      coords$xmin, coords$ymin,
      width  = coords$xmax - coords$xmin,
      height = coords$ymax - coords$ymin,
      default.units = "npc",
      just = c("left", "bottom"),
      gp = grid::gpar(
        col = coords$colour,
        fill = coords$fill,
        lwd = coords$size * .pt,
        lty = coords$linetype,
        linejoin = linejoin,
        lineend = if (identical(linejoin, "round")) "round" else "square"
      )
    )

    # Distribute intron styling
    if (intron.style == "line" || !any(c("+", "-") %in% coords$strand)) {
      intronlines <- style_intron_plainline(coords, linejoin)
      return(grid::gTree(children = grid::gList(intronlines, rect)))
    }

    if (intron.style == "chevron") {
      intronlines <- style_intron_chevron(coords, linejoin, chevron.height)
      return(grid::gTree(children = grid::gList(intronlines, rect)))
    }

    if (intron.style == "arrowline") {
      intronlines <- style_intron_arrowline(coords, linejoin, arrow, arrow.freq)
      return(grid::gTree(children = grid::gList(intronlines, rect),
                         cl = 'genemodel'))
    }

  },
  setup_data = function(self, data, params) {

    # Fill in optional aes
    missing <- setdiff(self$optional_aes, names(data))
    opts <- lapply(self$default_aes[missing], rlang::eval_tidy)
    add <- setdiff(names(opts), names(data))
    data[add] <- opts[add]

    # Merge overlapping ranges of the same group and type
    data <- split(data,
                  interaction(data$group, data$type, drop = TRUE),
                  drop = TRUE)

    data <- lapply(data, function(df){

      df <- df[order(df$xmin, df$xmax),]

      merge <- tail(df$xmin, -1) <= head(df$xmax, -1)
      if (!any(merge)) {
        return(df)
      }
      rle <- rle(merge)
      end <- cumsum(rle$lengths)[rle$values]
      start <- end - rle$lengths[rle$values] + 1

      df$xmax[start] <- df$xmax[end + 1]
      df <- df[-(which(merge) + 1),]
      return(df)
    })
    data <- do.call(rbind.data.frame, data)
    data <- data[order(data$PANEL, data$group, data$xmin, data$xmax),]
    rownames(data) <- NULL

    # Interpret and drop optional aes
    data$thickness <- ifelse(
      grepl("utr", data$type ,ignore.case = TRUE),
      0.5, 1) * data$thickness

    data <- transform(data,
                      ymin = y - thickness / 2,
                      ymax = y + thickness / 2,
                      thickness = NULL,
                      y = NULL,
                      type = NULL
    )
    return(data)
  },
  use_defaults = function(self, data, params = list()) {
    # 'width', 'y' and 'type' are already evaluated in setup_data(), so we can
    # skip evaluating defaults for these by pretending these are already in the
    # data columns
    data_cols <- c(names(data), "y", "thickness", "type")
    missing_aes  <- setdiff(names(self$default_aes), data_cols)
    missing_eval <- lapply(self$default_aes[missing_aes], rlang::eval_tidy)
    missing_eval <- ggplot2:::compact(missing_eval)
    if (ggplot2:::empty(data)) {
      data <- ggplot2:::as_gg_data_frame(missing_eval)
    }
    else {
      data[names(missing_eval)] <- missing_eval
    }
    aes_params <- intersect(self$aesthetics(), names(params))
    ggplot2:::check_aesthetics(params[aes_params], nrow(data))
    data[aes_params] <- params[aes_params]
    data
  },
  draw_key = ggplot2::draw_key_polygon
)

# Helpers ----------------------------------------

#' Intron styles
#'
#' @description Curious little monkey, aren't we? These internal helper
#'   functions help \code{geom_genemodel} style its introns. I can't see why a
#'   user would need these as they only make sense in the context of
#'   constructing grobs. Alas, here we are: me trying to hide my internal
#'   functions and you reading poorly written documentation for them anyway.
#'
#' @seealso \code{\link[ggnomics]{geom_genemodel}}
#' @keywords internal
#' @importFrom grid unit grob arrow
style_intron_arrowline <- function(
  data, linejoin = "mitre",
  arrow.template = NULL, arrow.freq = unit(4, "mm")
) {
  data <- lapply(split(data, data$group), function(group) {
    extremes <- group[which.max(group$xmax),]
    extremes$xmin <- min(group$xmin)
    extremes$y <- (extremes$ymax + extremes$ymin) / 2
    extremes
  })
  data <- do.call(rbind, data)
  data$xmin <- unit(data$xmin, "npc")
  data$xmax <- unit(data$xmax, "npc")

  if (is.null(arrow.template)) {
    arrow.template <- arrow(length = unit(2, "mm"))
  }

  grid::grob(
    data = data,
    arrow.template = arrow.template,
    arrow.freq.number = as.numeric(arrow.freq),
    arrow.freq.unit = attr(arrow.freq, "unit"),
    gp = grid::gpar(
      col  = data$colour,
      fill = data$fill,
      lwd  = data$size * .pt,
      lty  = data$linetype,
      linejoin = linejoin,
      lineend = if (identical(linejoin, "round")) "round" else "butt"
    ),
    cl = "arrowline"
  )
}

#' @rdname style_intron_arrowline
#' @importFrom grid segmentsGrob unit gpar
#' @keywords internal
style_intron_plainline <- function(data, linejoin) {
  data <- lapply(split(data, data$group), function(group) {
    extremes <- group[which.max(group$xmax),]
    extremes$xmin <- min(group$xmin)
    extremes$y <- (extremes$ymax + extremes$ymin) / 2
    extremes
  })
  data <- do.call(rbind, data)
  data$xmin <- unit(data$xmin, "npc")
  data$xmax <- unit(data$xmax, "npc")

  grid::segmentsGrob(
    x0 = data$xmin,
    x1 = data$xmax,
    y0 = data$y,
    y1 = data$y,
    gp = grid::gpar(
      col  = data$colour,
      lwd  = data$size * .pt,
      lty  = data$linetype,
      linejoin = linejoin,
      lineend = if (identical(linejoin, "round")) "round" else "butt"
    )
  )
}

#' @rdname style_intron_arrowline
#' @importFrom grid polylineGrob gpar
#' @keywords internal
style_intron_chevron <- function(data, linejoin = "bevel", height = 1) {
  dropcols <- !(colnames(data) %in% c("xmin", "xmax", "ymin", "ymax", "fill"))
  data <- split(data, data$group)
  data <- lapply(seq_along(data), function(i) {
    group <- data[[i]]
    n <- nrow(group)
    if (n == 1) {
      return(NULL)
    }
    ymid <- (group$ymin[1] + group$ymax[1])/2
    ymax <- if (group$strand[1] == "+") max(group$ymax) else min(group$ymin)
    ymax <- ymid + diff(c(ymid, ymax)) * height
    out <- data.frame(
      x = c(head(group$xmax, -1), tail(group$xmin, -1),
            (head(group$xmax, -1) + tail(group$xmin, -1))/2),
      y = rep(c(ymid, ymax),
              c(2 * n - 2, n - 1)),
      id = i,
      row.names = NULL
    )
    out <- out[order(out$x),]
    data.frame(out, group[1, dropcols], row.names = NULL)
  })
  data <- do.call(rbind, data)
  grid::polylineGrob(
    x = data$x,
    y = data$y,
    id = data$id,
    gp = grid::gpar(
      col  = data$colour[!duplicated(data$id)],
      lwd  = data$size * .pt,
      lty  = data$linetype,
      linejoin = "bevel",
      lineend = if (identical(linejoin, "round")) "round" else "butt"
    )
  )
}

#' @export
#' @importFrom grid makeContent
makeContent.genemodel <- function(x) {
  # Evaluate arrowline grob to fix colour mistakes
  if (inherits(x$children[[1]], 'arrowline')) {
    x$children[[1]] <- grid::makeContent(x$children[[1]])
  }
  x
}

#' @importFrom grid convertX unit gpar
makeContent.arrowline <- function(x) {

  dat <- x$data
  x$data <- NULL

  # Convert coordinates to absolute
  dat$xmin <- grid::convertX(dat$xmin, x$arrow.freq.unit, TRUE)
  dat$xmax <- grid::convertX(dat$xmax, x$arrow.freq.unit, TRUE)

  dat <- split(dat, dat$group)
  dat <- lapply(dat, function(s){
    # Split up lines into parts
    munched <- if (s$strand == "+") {
      c(seq(min(s$xmin), max(s$xmax), by = x$arrow.freq.number), max(s$xmax))
    } else {
      c(seq(max(s$xmax), min(s$xmin), by = -x$arrow.freq.number), min(s$xmin))
    }
    offset <- if(length(munched) > 1) -1 else length(munched)
    trans <- data.frame(
      xmin = head(munched, offset),
      xmax = tail(munched, offset),
      s[1,!(colnames(s) %in% c("xmin", "xmax"))],
      arrow_length = c(rep(1, length(munched) - 2), 0),
      row.names = NULL,
      stringsAsFactors = FALSE
    )
  })
  dat <- do.call(rbind, dat)

  arrow <- x$arrow.template
  arrow$length <- unit(dat$arrow_length * as.numeric(arrow$length),
                       attr(arrow$length, "unit"))

  # Update grob
  x$gp = grid::gpar(
    col  = dat$colour,
    fill = dat$fill,
    lwd = dat$size * .pt,
    lty = dat$linetype,
    linejoin = x$linejoin,
    lineend = if (identical(x$linejoin, "round")) "round" else "butt"
  )

  x$x0 <- unit(dat$xmin, "mm")
  x$x1 <- unit(dat$xmax, "mm")
  x$y0 <- unit(dat$y, "npc")
  x$y1 <- unit(dat$y, "npc")
  x$arrow <- arrow

  # Re-class grob
  x$cl <- 'segments'
  class(x)[1] <- 'segments'
  x
}