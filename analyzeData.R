# Author: Gary Chung
# Project: FDA AERS Seasonality Exploration
# Description: Testbed for R Code for Report
# =========================================

# -----------------
# Required Packages
# -----------------

require(plyr)
require(dplyr)
require(dygraphs)
require(xts)
require(googleVis)

# ----------------
# Required Sources
# ----------------

load(file="Data/reportData.Rdata")

# ------------------
# Defined Functions
# ------------------

# N/A

# ------
# Script
# ------

y.xts <- xts(select(y, -Ym), y$Ym)
z.xts <- xts(select(z, -Ym), z$Ym)
a.xts <- xts(select(a, -Ym), a$Ym)
dygraph(y.xts, main = pts[i], group="jamby") %>%
  dyOptions(colors = RColorBrewer::brewer.pal(3, "Set1")) %>%
  dyRoller(rollPeriod = 3)
dygraph(z.xts, main = pts[i], group="jamby") %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyRoller(rollPeriod = 3) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              highlightSeriesOpts = list(strokeWidth = 3))
dygraph(a.xts, main = pts[i], group="jamby") %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyRoller(rollPeriod = 3) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              highlightSeriesOpts = list(strokeWidth = 3))

sankey <- gvisSankey(s, 
                     from="drugname", to="indi_pt", weight="value",
                     options=list(width=700, height=600,
                                  sankey="{link: {color: { fill: '#d799ae' } },
                                  node: { color: { fill: '#a61d4c' },
                                  label: { color: '#871b47', fontSize: 16 } }}"))

plot(sankey)


# OPEN FDA
require(jsonlite)

data1 <- fromJSON(paste0("https://api.fda.gov/drug/event.json?",
                         "api_key=szuDIP4PDwueFy4Ol8Zfxg4Q5O4hNNHkZs0fDY4o&", 
                         "search=receivedate:[20040101+TO+20150101]"))
temp<-data1$results
data1$meta