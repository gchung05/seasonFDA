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
require(jsonlite)

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

theNames <- c("Ym", "Total Events", "Seasonality", "Trend")
for(i in 1:10) { colnames(ten.y[[i]]) <- theNames }
rm(theNames, i)

# Review a specific MedDRA PT
i <- 5

y.xts <- xts(select(ten.y[[i]], -Ym), ten.y[[i]]$Ym)
z.xts <- xts(select(ten.z[[i]], -Ym), ten.z[[i]]$Ym)
a.xts <- xts(select(ten.a[[i]], -Ym), ten.a[[i]]$Ym)
dygraph(y.xts, main = pts[i], group="jamby") %>%
  dyOptions(colors = RColorBrewer::brewer.pal(3, "Set1")) %>%
  dyRoller(rollPeriod=3) %>% dyLegend(width=400) %>%
  dyRangeSelector() %>%
  dyLimit(0, color = "black", strokePattern="dotted") %>%
  dySeries("Total Events", strokeWidth=1.5) %>%
  dySeries("Seasonality", strokePattern="dashed") %>%
  dySeries("Trend", strokePattern="dashed") %>%
  dyHighlight(highlightCircleSize=5,
              highlightSeriesOpts=list(strokeWidth=3))
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

gSet <- ten.s[[i]][ten.s[[i]]$value > 2, ]
names(gSet)[names(gSet)=="value"] <- "Reported Events"
sankey <- gvisSankey(gSet, 
                     from="drugname", to="indi_pt", weight="Reported Events",
                     options=list(width=700, height=500,
                                  sankey="{link: {color: { fill: '#d799ae' } },
                                  node: { color: { fill: '#a61d4c' },
                                  label: { color: '#871b47', fontSize: 16 } }}"))

plot(sankey)

# SAVE lightweight dataset that will be used in R-Markdown
y.xts <- list()
z.xts <- list()
a.xts <- list()
for(i in 1:10) {
  y.xts[[i]] <- xts(select(ten.y[[i]], -Ym), ten.y[[i]]$Ym)
  z.xts[[i]] <- xts(select(ten.z[[i]], -Ym), ten.z[[i]]$Ym)
  a.xts[[i]] <- xts(select(ten.a[[i]], -Ym), ten.a[[i]]$Ym)
}

save(pts, ten.s, y.xts, z.xts, a.xts, file="Data/forRmd.Rdata")

save(pts, file="Data/pts.Rdata")

# OPEN FDA

data1 <- fromJSON(paste0("https://api.fda.gov/drug/event.json?",
                         "api_key=szuDIP4PDwueFy4Ol8Zfxg4Q5O4hNNHkZs0fDY4o&", 
                         "search=receivedate:[20110401+TO+20150630]&",
                         "count=patient.reaction.reactionmeddrapt.exact&limit=1000"))
temp<-data1$results
data1$meta

data1 <- fromJSON("https://api.fda.gov/drug/label.json")
data1$meta

lastu <- fromJSON(paste0("https://api.fda.gov/drug/event.json?",
                         "api_key=szuDIP4PDwueFy4Ol8Zfxg4Q5O4hNNHkZs0fDY4o&", 
                         "search=receivedate:[20110401+TO+20150630]"))$meta$results$total
etodt <- fromJSON(paste0("https://api.fda.gov/drug/event.json?",
                         "api_key=szuDIP4PDwueFy4Ol8Zfxg4Q5O4hNNHkZs0fDY4o&", 
                         "search=receivedate:[19000101+TO+",
                         format(Sys.Date(), "%Y%m%d"), "]"))$meta$results$total
erang <- fromJSON(paste0("https://api.fda.gov/drug/event.json?",
                         "api_key=szuDIP4PDwueFy4Ol8Zfxg4Q5O4hNNHkZs0fDY4o&", 
                         "search=receivedate:[20110401+TO+20150630]"))$meta$results$total
outset <- cbind.data.frame("OpenFDA Last Updated"=lastu,
                           "Events: To Date"=etodt,
                           "Events: 4/2011 to 6/2015"=erang)
plot <- gvisTable(outset, formats=list("Events to Date"="#,###",
                                       "Events: 4/2011 to 6/2015"="#,###"))
print(plot, tag='chart')