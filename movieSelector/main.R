rm(list=ls(all=TRUE))
cat("\014")
t_start <- Sys.time()

userIDs <- c(6, 16, 104, 546, 1187, 1508)
userID <- 6
decayFactor <- .5

ratings <- read.csv("filmtrust/ratings.txt", sep = " ", col.names = c("User", "Movie", "Rating"))
#ratings <- head(ratings, n = 5000)
trusts <- read.csv("filmtrust/trust.txt", sep = " ", col.names = c("User", "Friend", "Trust"))
#trusts <- head(trusts, n = 500)

ratingsGivenByFriends <- read.table(text="", col.names = c("User", "Movie", "Rating"))
ratingsGivenByFriendsFriends <- read.table(text="", col.names = c("User", "Movie", "Rating"))

ratingsNotGivenByUser <- ratings[ratings$User != userID,]

for (friend in trusts$Friend[trusts$User == userID]) {
  ratingsGivenByFriends <- rbind(ratingsGivenByFriends, ratingsNotGivenByUser[ratingsNotGivenByUser$User == friend,])
}
colnames(ratingsGivenByFriends) <- c("User", "Movie", "Rating")
colnames(ratingsGivenByFriendsFriends) <- c("User", "Movie", "Rating")
for (friend in trusts$Friend[trusts$User == userID]) {
  for (friendsFriend in trusts$Friend[trusts$User == friend]) {
    if (friendsFriend != userID) {
      found <- 0
      for (f2 in trusts$Friend[trusts$User == userID]) {
        if (f2 == friendsFriend) {
          found <- 1
        }
      }
      if (found == 0) {
        ratingsGivenByFriendsFriends <- rbind(ratingsGivenByFriendsFriends, ratingsNotGivenByUser[ratingsNotGivenByUser$User == friendsFriend,])
      }
    }
  }
}
ratingsGivenByFriendsFriends <- unique(ratingsGivenByFriendsFriends)

movieList <- read.table(text = "", col.names = c("Movie", "S_all", "S_1", "S_2", "GonulScore", "YavuzScore", "n1", "n2", "nAll"))
cat("Calculating scores for all movies...\n")
for (movie in unique(ratingsNotGivenByUser$Movie)) {
  naiveMean <- mean(ratingsNotGivenByUser$Rating[ratingsNotGivenByUser$Movie == movie])
  firstMean <- mean(ratingsGivenByFriends$Rating[ratingsGivenByFriends$Movie == movie])
  friendsCount <- length(ratingsGivenByFriends$Rating[ratingsGivenByFriends$Movie == movie])
  if (is.nan(firstMean)) {
    firstMean <- 0
  }
  secondMean <- mean(ratingsGivenByFriendsFriends$Rating[ratingsGivenByFriendsFriends$Movie == movie])
  friendsFriendsCount <- length(ratingsGivenByFriendsFriends$Rating[ratingsGivenByFriendsFriends$Movie == movie])
  if (is.nan(secondMean)) {
    secondMean <- 0
  }
  nReviews <- length(ratingsNotGivenByUser$Rating[ratingsNotGivenByUser$Movie == movie])
  combinedMean <- firstMean + decayFactor * secondMean
  if (friendsCount == 0) {
    firstMean <- 0
    secondMean <- 0
    combinedMean <- decayFactor * decayFactor * naiveMean
  }
  combinedMean2 <- firstMean + decayFactor * secondMean + decayFactor * decayFactor * (naiveMean * nReviews - firstMean * friendsCount - secondMean * friendsFriendsCount) / (nReviews - friendsCount - friendsFriendsCount)
  if (is.infinite(combinedMean2) || is.nan(combinedMean2)) {
    combinedMean2 <- firstMean + decayFactor * secondMean
  }
  movieList <- rbind(movieList, c(movie, naiveMean, firstMean, secondMean, combinedMean, combinedMean2, friendsCount, friendsFriendsCount, nReviews));
}

#movieList$nReviews <- movieList$nReviews / max(movieList$nReviews)

colnames(movieList) <- c("Movie", "S_all", "S_1", "S_2", "GonulScore", "YavuzScore", "n1", "n2", "nAll")
sorted1 <- movieList[order(movieList$GonulScore,movieList$n1,movieList$n2,movieList$nAll,decreasing = TRUE),]
selectedFilms1 <- head(sorted1, n = 5)
sorted2 <- movieList[order(movieList$YavuzScore,movieList$n1,movieList$n2,movieList$nAll,decreasing = TRUE),]
selectedFilms2 <- head(sorted2, n = 5)
sorted3 <- movieList[order(movieList$S_all,movieList$n1,movieList$n2,movieList$nAll,decreasing = TRUE),]
selectedFilms3 <- head(sorted3, n = 5)

t_end <- Sys.time()
cat("Total Execution Time =", t_end - t_start, "seconds\n\n")
cat("Hello User", userID, "\n")
if(length(trusts$Friend[trusts$User == userID]) == 1) {
  cat("You have", length(trusts$Friend[trusts$User == userID]), "friend\n")
} else {
  cat("You have", length(trusts$Friend[trusts$User == userID]), "friends\n")
}
cat(length(selectedFilms1$Movie), "best movies are selected from a total of", length(movieList$Movie), "movies\n")
cat("Movie IDs:", selectedFilms1$Movie,"\n\n")
rm(combinedMean, combinedMean2, f2, firstMean, found, friend, friendsCount, friendsFriend, friendsFriendsCount, userIDs, secondMean, naiveMean, nReviews, movie)
