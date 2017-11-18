package com.gonulyavuz;

import javafx.util.Pair;

import java.util.*;

public class BestPlan {
    public final List<Intention> bestIntentions = new LinkedList<>();
    private Map<Date, Set<Belief>> candidates = new HashMap<Date, Set<Belief>>();

    public BestPlan(Set<Belief> beliefs, List<Desire> desires, Date today) {
        for (Belief b : beliefs) {
            if (candidates.get(b.getDate()) == null) {
                candidates.put(b.getDate(), new HashSet<Belief>() {{
                    add(b);
                }});
            } else {
                candidates.get(b.getDate()).add(b);
            }
        }

        // DEBUG
        //Integer nPlans = 1;
        //for (Date key : candidates.keySet()) {
        //    nPlans *= candidates.get(key).size();
        //}
        //System.out.println();
        //System.out.println("NO OF PLANS = " + nPlans);

        Map<Belief, Intention> intentions = new HashMap<>();
        for (Belief b : beliefs) {
            Desire relatedDesire = findRelatedUnsatisfiedDesire(b, desires, today);
            Intention i = new Intention(b, relatedDesire);
            intentions.put(b, i);
        }

        // DEBUG
        // System.out.println();
        // for (Intention i : intentions.values()) {
        //    System.out.println(i);
        //}

        // GREEDY
        for (Date d : candidates.keySet()) {
            Intention selected = null;
            for (Belief b : candidates.get(d)) {
                Intention i = intentions.get(b);
                if (i.relatedDesire == null) {
                    continue;
                } else if (selected == null || i.relatedDesire.getRank() < selected.relatedDesire.getRank()) {
                    selected = i;
                    i.relatedDesire.addNecessaryIntention(i);
                }
            }
            if (selected != null) {
                bestIntentions.add(selected);
            }
        }
    }

    private Desire findRelatedUnsatisfiedDesire(Belief b, List<Desire> desires, Date today) {
        // Assume that we have at least 1 desire
        Desire bestDesire = null;

        for (Desire d : desires) {
            if (bestDesire == null) {
                if (!d.isSatisfied(today) && similarity(b, d) > 0) {
                    bestDesire = d;
                }
            } else {
                if (!d.isSatisfied(today) && similarity(b, d) > similarity(b, bestDesire)) {
                    bestDesire = d;
                }
            }
        }

        if ((bestDesire == null) || similarity(b, bestDesire) == 0) {
            return null;
        } else {
            return bestDesire;
        }
    }

    private int similarity(Belief b, Desire d) {
        String str1 = b.getDescription().toLowerCase();
        String str2 = d.getDescription().toLowerCase();
        String[] words1 = str1.split(" ");
        String[] words2 = str2.split(" ");

        int similarity = 0;
        for (String w1 : words1) {
            for (String w2 : words2) {
                if (w1.equals(w2)) {
                    similarity++;
                }
            }
        }

        return similarity;
    }
}
