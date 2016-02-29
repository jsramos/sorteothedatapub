# Clean environment
rm(list = ls())

# Meetup.com API key: 253275a5c18147e74c5b1e2a6708
meetupurl <-
    "https://api.meetup.com/2/profiles?&sign=true&photo-host=public&group_urlname=thedatapub&key=253275a5c18147e74c5b1e2a6708"

# Libraries
library(RCurl)
library(jsonlite)
library(dplyr)
library(tidyr)

# Get Meetup.com list of attendees.
# Load it from file if present, otherwise go get it from meetup.com API
if (file.exists('./attendees.RDS')) {
    attendeesraw <- readRDS('./attendees.RDS')
} else {
    # Result from jsonlite call is a list, from which only
    # the 1st element is the actual dataframe. We extract that.
    attendeesraw <-
        fromJSON(
            getURL(meetupurl), simplifyVector = T, flatten = T, simplifyDataFrame = T
        )[[1]]
    saveRDS(attendeesraw, './attendees.RDS')
}

# Build a new dataframe with just names and answers.
# Be aware that we cannot unlist and keep the same number of elements in the
# resulting vector because NULLs are eliminated. Instead, we should convert
# them to NA.
# Also, be aware that some scores have commas in them, so we're removing them
# from the start.
# Finally, we're converting each score from string to a numeric value.
attendees <- data.frame(
    name = attendeesraw$name,
    stats = unlist(sapply(
        attendeesraw$answers,
        FUN = function(x) {
            elem <- x$answer[1]
            ifelse(is.null(elem), NA, gsub(',','', substr(elem, 1, 3)))
        }
    )),
    cs = unlist(sapply(
        attendeesraw$answers,
        FUN = function(x) {
            elem <- x$answer[2]
            ifelse(is.null(elem), NA, gsub(',','', substr(elem, 1, 3)))
        }
    )),
    swdev = unlist(sapply(
        attendeesraw$answers,
        FUN = function(x) {
            elem <- x$answer[3]
            ifelse(is.null(elem), NA, gsub(',','', substr(elem, 1, 3)))
        }
    )),
    dataviz = unlist(sapply(
        attendeesraw$answers,
        FUN = function(x) {
            elem <- x$answer[4]
            ifelse(is.null(elem), NA, gsub(',','', substr(elem, 1, 3)))
        }
    )),
    biz = unlist(sapply(
        attendeesraw$answers,
        FUN = function(x) {
            elem <- x$answer[5]
            ifelse(is.null(elem), NA, gsub(',','', substr(elem, 1, 3)))
        }
    )),
    stringsAsFactors = F # Critical if yo don't want factors to screw up your transformation
)

# Un seed arbitrario
# Con este seed el ejercicio se vuelve repetible para todo el que desee auditarlo.
set.seed(20160229)
# Selección de ganadores, 1 = DataDay, 2 = DataDay+MobileDay
attendees[round(runif(2, 1, length(attendees$name))),]
