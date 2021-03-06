# Generating Beta with Tidyquant - Oct 2018. Author: Shen Lim
# Copyright 2018, Shen Lim, All Rights Reserved.
library(tidyquant)

beta <- function(symbol,index,from,to,period) {
  
  Ra <- (tq_get(symbol,
                get  = "stock.prices",
                from = from,
                to   = to) %>%
           tq_transmute(select     = adjusted,
                        mutate_fun = periodReturn,
                        period     = period,
                        type       = "arithmetic",
                        col_rename = "Ra"))
  
  Rb <- (tq_get(index,
                get  = "stock.prices",
                from = from,
                to   = to) %>%
           tq_transmute(select     = adjusted,
                        mutate_fun = periodReturn,
                        period     = period,
                        type       = "arithmetic",
                        col_rename = "Rb"))
  
  capm.beta <- rename((tq_performance(data = left_join(Ra, Rb, by = c("date" = "date")),
                                      Ra = Ra,
                                      Rb = Rb,
                                      performance_fun = CAPM.beta)), Beta = 'CAPM.beta.1')
  
  ggplot <- (left_join(Ra, Rb, by = c("date" = "date")) %>%
               ggplot(aes(x = Rb, y = Ra)) +
               geom_point(color = "orange1", alpha = 1, na.rm = TRUE) +
               geom_smooth(method = "lm", color = "cyan", level = FALSE, na.rm = TRUE) +
               labs(title = paste(symbol, "Returns Regressed on", index, "Returns"),
                    x = paste(index, "Returns"),
                    y = paste(symbol, "Returns")) +
               geom_vline(aes(xintercept = 0), color = "ghostwhite", size = 0.75) +
               geom_hline(aes(yintercept = 0), color = "ghostwhite", size = 0.75) +
               xlim((abs(max(Rb$Rb)) * -1.005),
                    (abs(max(Rb$Rb)) * 1.005)) +
               ylim((abs(max(Ra$Ra)) * -1.005),
                    (abs(max(Ra$Ra)) * 1.005)) +
               theme(panel.background = element_rect(fill   = "black",
                                                     colour = "black",
                                                     size   = 0.5, linetype = "solid"),
                     panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "gray50"),
                     panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "gray50")))
               
  return(list(ggplot, capm.beta))
}
