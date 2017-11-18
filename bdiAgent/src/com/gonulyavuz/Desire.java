package com.gonulyavuz;

import java.util.HashSet;
import java.util.Set;
import java.util.Date;

public class Desire {
    private Integer rank;
    private String description;
    private Set<Intention> necessaryIntentions = new HashSet<>();
    private Set<ServiceAgent> relatedAgents;

    public Desire(Integer rank, String description, Set<ServiceAgent> relatedAgents) {
        this.rank = rank;
        this.description = description;
        this.relatedAgents = relatedAgents;
    }

    public void addNecessaryIntention(Intention i) {
        necessaryIntentions.add(i);
    }

    public Set<ServiceAgent> getRelatedAgents() {
        return relatedAgents;
    }

    public boolean isMoreImportantThan(Desire other) {
        return this.rank > other.rank;
    }

    public void alterRank(Integer newRank) {
        rank = newRank;
    }

    public boolean isSatisfiable() {
        for (Intention i : necessaryIntentions) {
            if (i.isDropped) {
                return false;
            }
        }

        return true;
    }

    public boolean isSatisfied(Date today) {
        for (Intention i : necessaryIntentions) {
            if (i.isCompleted(today)) {
                return true;
            }
        }

        return false;
    }

    @Override
    public String toString() {
        return rank.toString() + ".Desire : " + description;
    }

    public String getDescription() {
        return description;
    }

    public Integer getRank() { return rank; }

    public void clearNecessaryIntentions() { necessaryIntentions.clear(); }
}
