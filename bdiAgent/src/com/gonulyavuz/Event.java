package com.gonulyavuz;

import java.util.Date;

public class Event {
    public final String description;
    public Date date;

    public Event(String description, Date date) {
        this.description = description;
        this.date = date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
