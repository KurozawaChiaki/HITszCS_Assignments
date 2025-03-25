package edu.hitsz.item;

import edu.hitsz.application.Main;
import edu.hitsz.basic.AbstractFlyingObject;
import edu.hitsz.aircraft.HeroAircraft;

public abstract class AbstractItem extends AbstractFlyingObject {
    public AbstractItem(int locationX, int locationY, int speedX, int speedY) {
        super(locationX, locationY, speedX, speedY);
    }

    public abstract void itemFunction();

}
