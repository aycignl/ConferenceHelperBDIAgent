package com.gonulyavuz;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Intention {
    public boolean isDropped = false;
    public final Belief triggeringBelief;
    public final Desire relatedDesire;

    public Intention(Belief b, Desire relatedDesire) {
        this.triggeringBelief = b;
        this.relatedDesire = relatedDesire;
    }

    public void reconsider() {
        if (triggeringBelief.isCanceled()) {
            isDropped = true;
        }
    }

    public boolean isCompleted(Date today) {
        return (!isDropped && triggeringBelief.getDate().before(today));
    }

    @Override
    public String toString() {
        return "Intention : " + triggeringBelief.getDescription() + " @" + triggeringBelief.getDate() + " [RELATED TO : " + (relatedDesire == null ? "NO DESIRES" : relatedDesire.getDescription()) + "]";
    }
}
