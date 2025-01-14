#' Plot the overall variance of your dataset
#'
#' @description
#' This function will plot the overall variance explained by the selected factors.
#' You can choose to plot it as boxplots or heatmap.
#' - Boxplots : points will represent the mean abundance of the features. Features with p.adj < 0.05 and p < 0.05 will be plotted.
#' - Heatmap : all factors will be plotted as rows. Currently doesn't shows which features ar significant.
#'
#' @param variance An object returned by the \link{calculate_variance}
#' @param plot_type Categorical. Plot as boxplots or heatmap. Default= "boxplot".
#' @param top For heatmap plotting only. The top N features to plot. Default = 30.
#'
#'
#' @return
#' A ggplot.
#' @export
#'
#' @examples
#' var = metabolomic %>%
#' dplyr::select(!child_id) %>%
#' calculate_variance(clinical_data = 1:3, cores = 1)
#'
#' # A boxplot with jitter.
#' plot_all_variance(var, col = c("brown", "darkgreen", "grey"))
#'
#' # alternatively you can plot the results as a Heatmap
#' plot_all_variance(var, plot_type = "heatmap")
plot_all_variance = function(variance, plot_type= "boxplot", top=30, col= c("brown", "orange", "grey")){
  var_exp = variance$variance %>%
    dplyr::filter(variable=="var.exp")%>%
    tidyr::pivot_longer(names_to = "factor", values_to = "value", cols = !features:variable)%>%
    dplyr::full_join(variance$p.value, by=c("features","factor"))%>%
    dplyr::full_join(variance$variance %>%
                       dplyr::filter(variable=="mean.feat") %>%
                       tidyr::pivot_longer(names_to = "factor", values_to = "mean.feat", cols = !features:variable),
                     by=c("features", "factor"))


  if(plot_type=="boxplot"){
    ord = var_exp %>%
      dplyr::group_by(factor)%>%
      dplyr::mutate(mean.fac = median(value, na.rm=T))%>%
      dplyr::pull(mean.fac)
  # head(ord)

    p = var_exp %>%
      ggplot(aes(y = value, forcats::fct_reorder(factor, ord)))+

      geom_jitter(aes(size=mean.feat, fill= ifelse(p.adj<0.05, col[1],
                                                   ifelse(p<0.05, col[2], col[3]))),
                  shape=21)+
      geom_boxplot(size=1.5, alpha=0)+
      scale_fill_identity(name = "P values", breaks = c(col),
                          labels = c("FDR < 0.05", "nFDR < 0.05", "NS"),
                          guide = "legend")+
      guides(size= guide_legend("Mean features"))+
      coord_flip()+
      theme_bw()+
      labs(y="Variance explained by factors")+
      theme(axis.text.y = element_text(face="bold"),
            axis.title.y = element_blank(),
            legend.position = "bottom")
    p
  }
  if(plot_type=="heatmap"){

    top= variance$variance %>%
      dplyr::filter(variable=="var.tot")%>%
      tidyr::pivot_longer(names_to = "factor", values_to = "value", cols = !features:variable)%>%
      dplyr::group_by(features)%>%
      dplyr::summarise(mean.fac= mean(value, na.rm=T)) %>%
      top_n(top, wt = mean.fac)

    p = var_exp %>%
      dplyr::filter(features %in% top$features)%>%
      ggplot(aes(fct_reorder(features, mean.feat), factor))+
      geom_tile(aes(fill=value))+
      scale_fill_gradient(high = col[1], low = "white", name="Percent of variance")+
      theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5),
            axis.title = element_blank(),
            legend.position = "top")

  }
return(p)

}

