package edu.hitsz.basic;

import edu.hitsz.aircraft.MobEnemy;
import edu.hitsz.application.ImageManager;
import edu.hitsz.application.Main;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AbstractFlyingObjectTest {
    AbstractFlyingObject testEnemy = new MobEnemy((int) (Math.random() * (Main.WINDOW_WIDTH - ImageManager.MOB_ENEMY_IMAGE.getWidth())) * 1,
            (int) (Math.random() * Main.WINDOW_HEIGHT * 0.2) * 1,
            0,
            10,
            100);

    @Test
    void setLocation() {
        testEnemy.setLocation(5.0, 7.0);
        assertEquals(5.0, testEnemy.getLocationX());
        assertEquals(7.0, testEnemy.getLocationY());
        System.out.println("正确修改X、Y轴坐标。");
        System.out.println("-----------------");
    }

    @Test
    void vanish() {
        testEnemy.vanish();
        assertTrue(testEnemy.notValid());
        System.out.println("对象已无效。");
        System.out.println("----------");
    }
}