package com.gonulyavuz;

import sun.security.krb5.internal.crypto.Des;

import java.util.*;

public class BDIAgent {
    private String name;

    private Set<Belief> beliefs = new HashSet<>();
    private List<Desire> desires = new LinkedList<>();
    private Set<Intention> intentions;
    private BestPlan bestPlan;
    private Date currentDateBelief;

    public BDIAgent(String name, List<Desire> initialDesires, Date NOW) {
        this.desires.addAll(initialDesires);
        this.currentDateBelief = NOW;
        constructBeliefs();
        constructIntentions();
        this.name = name;
    }

    private void reduceRankOfSatisfiedDesires() {
        for (Desire d : desires) {
            if (d.isSatisfied(currentDateBelief)) {
                for (Desire d2 : desires) {
                    if (d2.getRank() > d.getRank()) {
                        d2.alterRank(d2.getRank() - 1);
                    }
                }
                d.alterRank(desires.size() - 1);
            }
        }
        desires.sort(new Comparator<Desire>() {
            @Override
            public int compare(Desire o1, Desire o2) {
                return o1.getRank().compareTo(o2.getRank());
            }
        });
    }

    public void constructBeliefs() {
        for (Desire d : desires) {
            for (ServiceAgent s : d.getRelatedAgents()) {
                for (Event e : this.ask(s)) {
                    if (!hasBelief(e.date, e.description)) {
                        beliefs.add(new Belief(e.date, e.description));
                    }
                }
            }
        }
    }

    public void setCurrentDateBelief(Date today) {
        currentDateBelief = today;
    }

    private boolean hasBelief(Date date, String description) {
        for (Belief b : beliefs) {
            if (b.getDate().equals(date) && b.getDescription().equals(description)) {
                return true;
            }
        }
        return false;
    }

    public void constructIntentions() {
        // DEBUG
        // for (Belief b : beliefs) {
        //   System.out.println(b);
        // }

        reduceRankOfSatisfiedDesires();
        for (Desire d : desires) {
            d.clearNecessaryIntentions();
        }

        // Enumerate all possible intention sequences
        bestPlan = new BestPlan(beliefs, desires, currentDateBelief);

        //System.out.println();
        bestPlan.bestIntentions.sort(new Comparator<Intention>() {
            @Override
            public int compare(Intention o1, Intention o2) {
                return o1.triggeringBelief.getDate().compareTo(o2.triggeringBelief.getDate());
            }
        });

        // DEBUG
        // for (Intention i : bestPlan.bestIntentions) {
        //    System.out.println(i);
        //}
    }

    public void addDesire(Desire newDesire) {
        for (Desire d : desires) {
            if (d.getRank() >= newDesire.getRank()) {
                d.alterRank(d.getRank() + 1);
            }
        }
        desires.add(newDesire.getRank() - 1, newDesire);
    }

    public void removeDesire(Desire desire) {
        desires.remove(desire);
    }

    private Set<Event> ask(ServiceAgent a) {
        return a.events;
    }

    public void printBeliefs() {
        List<Belief> orderedBeliefs = new ArrayList<>();
        for (Belief b : beliefs) {
            orderedBeliefs.add(b);
        }

        orderedBeliefs.sort(new Comparator<Belief>() {
            @Override
            public int compare(Belief o1, Belief o2) {
                return o1.getDate().compareTo(o2.getDate());
            }
        });

        System.out.println("BELIEFS = ");
        for (Belief b : orderedBeliefs) {
            System.out.println(b);
        }
    }

    public void printExpectedIntentions(Date today) {
        System.out.println("FUTURE INTENTIONS = ");
        for (Intention i : bestPlan.bestIntentions) {
            if (!i.isCompleted(today) && !i.isDropped) {
                System.out.println(i);
            }
        }
    }

    public void printCompletedIntentions(Date today) {
        System.out.println("COMPLETED INTENTIONS = ");
        for (Intention i : bestPlan.bestIntentions) {
            if (i.isCompleted(today)) {
                System.out.println(i);
            }
        }
    }

    public void printUtilityCalculations(Date today) {
        List<Desire> expectedDesiresToAttend = new ArrayList<>();
        List<Desire> expectedDesiresToForgetAbout = new ArrayList<>();

        for (Desire d : desires) {
            for (Intention i : bestPlan.bestIntentions) {
                if (i.relatedDesire == d) {
                    expectedDesiresToAttend.add(d);
                    break;
                }
            }
            if (d.getDescription().contains("NOT")) {
                Date date = new Date(118, 6, 16, 9, 0);
                boolean allDatesFull = true;
                while (date.before(new Date(118, 6, 21, 18, 0))) {
                    for (Intention i : bestPlan.bestIntentions) {
                        allDatesFull &= i.triggeringBelief.getDate().equals(date);
                    }

                    if (date.getHours() == 9) {
                        date.setHours(18);
                    } else {
                        date.setDate(date.getDate() + 1);
                        date.setHours(9);
                    }
                }
                if (allDatesFull) {
                    expectedDesiresToAttend.add(d);
                }
            }
        }

        for (Desire d: desires) {
            if (!expectedDesiresToAttend.contains(d)) {
                expectedDesiresToForgetAbout.add(d);
            }
        }

        expectedDesiresToAttend.sort(new Comparator<Desire>() {
            @Override
            public int compare(Desire d1, Desire d2) {
                return d1.getRank().compareTo(d2.getRank());
            }
        });
        expectedDesiresToForgetAbout.sort(new Comparator<Desire>() {
            @Override
            public int compare(Desire d1, Desire d2) {
                return d1.getRank().compareTo(d2.getRank());
            }
        });

        System.out.println("SATISFIED DESIRES = ");
        for (Desire d : expectedDesiresToAttend) {
            if (d.isSatisfied(today)) {
                System.out.println(d);
            }
        }

        System.out.println();
        System.out.println("FUTURE DESIRES = ");
        for (Desire d : expectedDesiresToAttend) {
            if (!d.isSatisfied(today)) {
                System.out.println(d);
            }
        }

        System.out.println();
        System.out.println("FUTURE DESIRES TO FORGET ABOUT = ");
        for (Desire d : expectedDesiresToForgetAbout) {
            System.out.println(d);
        }
    }

    public Set<Belief> getBeliefs() {
        return beliefs;
    }
}
