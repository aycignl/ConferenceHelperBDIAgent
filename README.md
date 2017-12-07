# Movie Negotiator
We propose Pareto Optimal Movie Negotiator (POMN), an agent which performs the Movie Negotiation Game (MNG) for not just two, but also three users. Unless the given MNG is a zero-sum game, POMN always returns a Pareto efficient deal. We implement POMN in Perl since visualization of negotiation graphs is convenient in Perl. Alternating offers is a known protocol for bilateral negotiations. In this study, we propose two generalizations of alternating offers protocol, Gonul Protocol (GP) and Yavuz Protocol (YP) so that these protocols support three negotiators.

### HOW TO RUN?
1) ./main.pl <preferenceTable.csv> <protocol> </br>
e.g., ./main.pl example1.csv GP 

# Movie Selector
We propose Movie Selector, an agent which suggests the five best unwatched movies for the user. Movie Selector ranks movies based on ratings given by other users as well as trust relationships of the user. We propose a fast scoring function, Gonul Score, which takes only two seconds to compute. We implement and show that Gonul Score selects the most reasonable movies for all five case studies in our work. We compare Gonul Score with Naive Score and Yavuz Score. We show that other scoring functions fail in some case studies.<br>
We use the FilmTrust dataset which contains movie ratings and trust values for a set of users.<br>
We use R language to implement our agent.

### HOW TO RUN?
To execute our program, first open RStudio. Open the directory which contains main.R script and filmtrust dataset directory. Click more and then click Set as Working Directory to correctly set the R environment. Then, open the main.R script and change the UserID variable to whoever you want to select movies for. Then, execute whole script. 

# ConferenceHelperBDIAgent
Our BDI agent prepares a schedule and makes necessary arrangements <br>
We propose Conference Helper BDI Agent, an agent which prepares a schedule and makes the necessary arrangements for a user who is going to a conference in Amsterdam between July 16-21. Conference Helper BDI Agent adapts to on-the-fly changes in desires. We implement Conference Helper BDI Agent in pure Java. We did not use any other third-party libraries. We present a very rich scenario in terms of cancels, date changes, and other unexpected situations. We obtain new scenarios from this main scenario by making subtle but important changes to our main scenario and show that Conference Helper BDI Agent is capable to handle these changes.

### HOW TO RUN?
1) Import the project folder via Eclipse or IntelliJIDEA.
2) Execute Main.java
