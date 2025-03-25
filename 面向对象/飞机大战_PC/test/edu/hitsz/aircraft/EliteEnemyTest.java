package edu.hitsz.aircraft;

import edu.hitsz.application.ImageManager;
import edu.hitsz.application.Main;
import edu.hitsz.bullet.BaseBullet;
import edu.hitsz.factory.AbstractItemFactory;
import edu.hitsz.factory.BombSupplyItemFactory;
import edu.hitsz.factory.FireSupplyItemFactory;
import edu.hitsz.factory.HealingItemFactory;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class EliteEnemyTest {
    EliteEnemy testElite = new EliteEnemy((int) ( Math.random() * (Main.WINDOW_WIDTH - ImageManager.MOB_ENEMY_IMAGE.getWidth()))*1,
            (int) (Math.random() * Main.WINDOW_HEIGHT * 0.2)*1,
            0,
            10,
            200);

    @Test
    @DisplayName("testShootMethod")
    void shoot() {
        System.out.println("当前正在测试shoot()方法：");
        List<BaseBullet> enemyBulletList = testElite.shoot();
        assertEquals(2, enemyBulletList.size());
        System.out.println("精英敌机射出的子弹数量为 " + enemyBulletList.size() + " ,符合预期");
        System.out.println("------------------------");
    }

    @Test
    @DisplayName("testDropItemMethod")
    void dropItem() {
        System.out.println("当前正在测试dropItem()方法：");
        AbstractItemFactory testItemFactory = new HealingItemFactory();
        assertNotNull(testElite.dropItem(testItemFactory));
        System.out.println("生成治疗道具非空，运行正常；");

        testItemFactory = new FireSupplyItemFactory();
        assertNotNull(testElite.dropItem(testItemFactory));
        System.out.println("生成火力支援道具非空，运行正常；");

        testItemFactory = new BombSupplyItemFactory();
        assertNotNull(testElite.dropItem(testItemFactory));
        System.out.println("生成炸弹支援道具非空，运行正常。‹");

        System.out.println("------------------------");
    }
}