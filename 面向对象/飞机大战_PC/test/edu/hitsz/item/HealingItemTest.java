package edu.hitsz.item;

import edu.hitsz.aircraft.HeroAircraft;
import edu.hitsz.application.ImageManager;
import edu.hitsz.application.Main;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class HealingItemTest {
    HeroAircraft testHero = HeroAircraft.getInstance();
    HealingItem testItem = new HealingItem((int) ( Math.random() * (Main.WINDOW_WIDTH - ImageManager.MOB_ENEMY_IMAGE.getWidth()))*1,
            (int) (Math.random() * Main.WINDOW_HEIGHT * 0.2)*1, -2, 5);

    @Test
    @DisplayName("testItemFunctionMethod")
    void itemFunction() {
        testHero.setStatus(
                Main.WINDOW_WIDTH / 2,
                Main.WINDOW_HEIGHT - ImageManager.HERO_IMAGE.getHeight() ,
                0, 0, 100);
        testHero.decreaseHp(40);
        testItem.itemFunction();
        assertEquals(90, testHero.getHp());
        System.out.println("英雄机被正常治疗");
        System.out.println("-------------");
    }

    @Test
    void forward() {
        testItem.forward();
        if(testItem.getLocationY() >= Main.WINDOW_HEIGHT) {
            assertTrue(testItem.notValid());
            System.out.println("道具由于出界，被正常无效化");
        } else {
            assertFalse(testItem.notValid());
            System.out.println("道具未出界，保持正常有效状态");
        }
        System.out.println("--------------");
    }
}