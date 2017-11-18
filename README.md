# ConferenceHelperBDIAgent
Our BDI agent prepares a schedule and makes necessary arrangements <br>

### HOW TO RUN?
1) Import the project folder via Eclipse or IntelliJIDEA.
2) Execute Main.java


# Movie Selector
We propose Movie Selector, an agent which suggests the five best unwatched movies for the user. Movie Selector ranks movies based on ratings given by other users as well as trust relationships of the user. We propose a fast scoring fucntion, Gonul Score, which takes only two seconds to compute. We implement and show that Gonul Score selects the most reasonable movies for all five case studies in our work. We compare Gonul Score with Naive Score and Yavuz Score. We show that other scoring functions fail in some case studies.<br>
We use the FilmTrust dataset which contains movie ratings and trust values for a set of users.<br>
We use R language to implement our agent.

### HOW TO RUN?
To execute our program, first open RStudio. Open the directory which contains main.R script and filmtrust dataset directory. Click more and then click Set as Working Directory to correctly set the R environment. Then, open the main.R script and change the UserID variable to whoever you want to select movies for. Then, execute whole script. 
