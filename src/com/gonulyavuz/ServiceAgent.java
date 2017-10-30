package com.gonulyavuz;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

public class ServiceAgent {
    public final String name;
    public final Set<Event> events = new HashSet<>();

    public ServiceAgent(String name, Set<Event> events) {
        this.events.addAll(events);
        this.name = name;
    }

    public void warnCancel(BDIAgent agent, Event e) {
        Event eventToRemove = null;
        for (Event previous : events) {
            if (previous.equals(e)) {
                eventToRemove = e;
            }
        }
        events.remove(eventToRemove);

        Belief beliefToRemove = null;
        for (Belief b : agent.getBeliefs()) {
            if (b.getDate().equals(e.date)) {
                if (b.getDescription().equals(e.description)) {
                    beliefToRemove = b;
                    break;
                }
            }
        }
        if (beliefToRemove != null) {
            agent.getBeliefs().remove(beliefToRemove);

            agent.constructIntentions();
            System.out.println();
            System.out.println("IMPORTANT WARNING: Event " + e.description + " @ " + e.date + " is CANCELED");
        } else {
            System.out.println();
            System.out.println("UNIMPORTANT WARNING: Event " + e.description + " @ " + e.date + " is CANCELED");
        }
    }

    public void warnAlter(BDIAgent agent, Event e, Date newDate) {
        Belief beliefToRemove = null;
        for (Belief b : agent.getBeliefs()) {
            if (b.getDate().equals(e.date)) {
                if (b.getDescription().equals(e.description)) {
                    beliefToRemove = b;
                    break;
                }
            }
        }
        if (beliefToRemove != null) {
            agent.getBeliefs().remove(beliefToRemove);
            agent.getBeliefs().add(new Belief(newDate, e.description));

            agent.constructIntentions();
            System.out.println();
            System.out.println("IMPORTANT WARNING: Date of Event " + e.description + " changed from " + e.date + " to " + newDate);
        } else {
            System.out.println();
            System.out.println("UNIMPORTANT WARNING: Date of Event " + e.description + " changed from " + e.date + " to " + newDate);
        }

        for (Event previous : events) {
            if (previous.equals(e)) {
                previous.setDate(newDate);
            }
        }
    }
}
