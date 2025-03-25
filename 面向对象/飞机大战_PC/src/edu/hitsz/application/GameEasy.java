package edu.hitsz.application;

import edu.hitsz.dao.PlayerDAO;

import static edu.hitsz.application.Main.*;

public class GameEasy extends Game{
    @Override
    public void difficultyTag() {
        System.out.println("当前难度:EASY");
        System.out.println("无BOSS机生成;难度不随时间变化");
    }

    public void difficultyEvolve(){}
    public void generateEnemy() {
        if(eliteGenerationFlag == eliteGenerationLimit) {
            eliteGenerationFlag = 0;
            if(enemyAircrafts.size() < enemyMaxNumber) {
                enemyAircrafts.add(eliteFactory.createEnemy(
                        (int) ( Math.random() * (WINDOW_WIDTH - ImageManager.MOB_ENEMY_IMAGE.getWidth()))*1,
                        (int) (Math.random() * WINDOW_HEIGHT * 0.2)*1,
                        Math.random() > 0.3 ? 4 : 0,
                        4,
                        200
                ));
            }
        }
        // 新敌机产生
        if(mobGenerationFlag == mobGenerationLimit) {
            mobGenerationFlag = 0;
            if (enemyAircrafts.size() < enemyMaxNumber) {
                enemyAircrafts.add(mobFactory.createEnemy(
                        (int) (Math.random() * (WINDOW_WIDTH - ImageManager.MOB_ENEMY_IMAGE.getWidth())) * 1,
                        (int) (Math.random() * WINDOW_HEIGHT * 0.2) * 1,
                        0,
                        10,
                        100
                ));
            }
        }
        eliteGenerationFlag++;
        mobGenerationFlag++;
        shootPeriodFlag++;
    }

    public void readPlayerList(PlayerDAO playerDAO) {
        playerDAO.readPlayerList(0);
    }

    public void savePlayerList(PlayerDAO playerDAO) {
        playerDAO.savePlayerList(0);
    }
}
