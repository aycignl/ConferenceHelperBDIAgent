package com.gonulyavuz;

import java.util.Date;

public class Belief {
    private Date date;
    private boolean isCanceled = false;
    private boolean isDateAltered = false;
    private String description;

    public Belief(Date date, String description) {
        this.date = date;
        this.description = description;
    }

    public void cancel() {
        isCanceled = false;
    }

    public boolean isCanceled() {
        return isCanceled;
    }

    public boolean isDateAltered() {
        return isDateAltered;
    }

    public void alterDate(Date newDate) {
        date = newDate;
    }

    public Date getDate() {
        return date;
    }

    @Override
    public String toString() {
        return "@" + date.toString() + " : " + description;
    }

    public String getDescription() {
        return description;
    }
}
