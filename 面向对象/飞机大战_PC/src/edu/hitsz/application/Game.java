package edu.hitsz.application;

import edu.hitsz.aircraft.*;
import edu.hitsz.bullet.BaseBullet;
import edu.hitsz.basic.AbstractFlyingObject;
import edu.hitsz.dao.Player;
import edu.hitsz.dao.PlayerDAO;
import edu.hitsz.dao.PlayerDAOImpl;
import edu.hitsz.factory.*;
import edu.hitsz.item.AbstractItem;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.util.*;
import java.util.List;
import java.util.concurrent.*;

import static edu.hitsz.application.Main.*;

/**
 * 游戏主面板，游戏启动
 *
 * @author hitsz
 */
public abstract class Game extends JPanel {

    private int backGroundTop = 0;

    /**
     * Scheduled 线程池，用于任务调度
     */
    private final ScheduledExecutorService executorService;

    /**
     * 时间间隔(ms)，控制刷新频率
     */
    private int timeInterval = 40;

    private final HeroAircraft heroAircraft;
    public static List<AbstractAircraft> enemyAircrafts;
    private final List<BaseBullet> heroBullets;
    public static List<BaseBullet> enemyBullets;
    private final List<AbstractItem> itemList;
    final EliteEnemyFactory eliteFactory = new EliteEnemyFactory();
    final MobEnemyFactory mobFactory = new MobEnemyFactory();
    final BossEnemyFactory bossFactory = new BossEnemyFactory();
    private final HealingItemFactory healingItemFactory = new HealingItemFactory();
    private final FireSupplyItemFactory fireSupplyItemFactory = new FireSupplyItemFactory();
    private final BombSupplyItemFactory bombSupplyItemFactory = new BombSupplyItemFactory();

    int enemyMaxNumber = 5;

    private boolean gameOverFlag = false;

    int bossHp = 1500;
    double bossHpRate = 1.5;
    int mobHp = 100;
    int eliteHp = 200;
    public static int score = 0;
    private int time = 0;
    /**
     * 周期（ms)
     * 指示子弹的发射、敌机的产生频率
     */
    private int cycleDuration = 500;
    private int cycleTime = 0;
    int eliteGenerationFlag = 0;
    int mobGenerationFlag = 0;

    int shootPeriodFlag = 0;
    int shootPeriodLimit = 5;
    public static int bossScore = 0;
    private double shootPeriodRate = 0.8;
    private double maxNumberRate = 1.2;
    private double enemyGenerationRate = 0.8;
    int mobGenerationLimit = 5;
    int eliteGenerationLimit = 20;
    int bossGenerationLimit = 200;

    boolean bossGenerationFlag = true;

    MusicThread bgmThread = new MusicThread("src/videos/bgm.wav");
    MusicThread bossThread = new MusicThread("src/videos/bgm_boss.wav");

    public Game() {
        heroAircraft = HeroAircraft.getInstance();
        heroAircraft.setStatus(
                WINDOW_WIDTH / 2,
                WINDOW_HEIGHT - ImageManager.HERO_IMAGE.getHeight() ,
                0, 0, 1000);

        enemyAircrafts = new LinkedList<>();
        heroBullets = new LinkedList<>();
        enemyBullets = new LinkedList<>();
        itemList = new LinkedList<>();

        //Scheduled 线程池，用于定时任务调度
        ThreadFactory gameThread = new ThreadFactory() {
            @Override
            public Thread newThread(Runnable r) {
                Thread t = new Thread(r);
                t.setName("game thread");
                return t;
            }
        };
        executorService = new ScheduledThreadPoolExecutor(1, gameThread);

        //启动英雄机鼠标监听
        new HeroController(this, heroAircraft);

    }

    public abstract void difficultyTag();

    public abstract void generateEnemy();
    public abstract void difficultyEvolve();
    public abstract void readPlayerList(PlayerDAO playerDAO);
    public abstract void savePlayerList(PlayerDAO playerDAO);
    /**
     * 游戏启动入口，执行游戏逻辑
     */
    public void action() {
        difficultyTag();

        if(Main.bgmFlag) {
            bgmThread.start();
            bgmThread.setLoop(true);
        }

        // 定时任务：绘制、对象产生、碰撞判定、击毁及结束判定
        Runnable task = () -> {

            time += timeInterval;

            // 周期性执行（控制频率）
            if (timeCountAndNewCycleJudge()) {
                System.out.println(time);
                generateEnemy();
                // 飞机射出子弹
                shootAction();
            }

            // 子弹移动
            bulletsMoveAction();

            //道具移动
            itemMoveAction();

            // 飞机移动
            aircraftsMoveAction();

            // 撞击检测
            crashCheckAction();

            // 后处理
            postProcessAction();

            //每个时刻重绘界面
            repaint();

            // 游戏结束检查
            if (heroAircraft.getHp() <= 0) {
                // 游戏结束
                if(bgmFlag) {
                    bgmThread.over();
                    MusicThread gameOverThread = new MusicThread("src/videos/game_over.wav");
                    gameOverThread.setLoop(false);
                    gameOverThread.start();
                }

                executorService.shutdown();
                Main.frame.setVisible(false);
                gameOverFlag = true;
                System.out.println("Game Over!");

                PlayerDAO playerDAO = new PlayerDAOImpl();
                readPlayerList(playerDAO);

                JFrame addFrame = new JFrame("添加新纪录");
                CreateNewPlayer addObj = new CreateNewPlayer();
                addFrame.setContentPane(addObj.contentPane);
                addFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                addFrame.pack();

                JFrame rankFrame;
                switch(difficultyOption) {
                    case 0: {
                        rankFrame = new JFrame("得分排名:EASY");
                        break;
                    }

                    case 1: {
                        rankFrame = new JFrame("得分排名:NORMAL");
                        break;
                    }
                    case 2: {
                        rankFrame = new JFrame("得分排名:HARD");
                        break;
                    }
                    default: {
                        rankFrame = new JFrame("得分排名");
                    }
                }

                PlayerRank rankObj = new PlayerRank();
                rankFrame.setContentPane(rankObj.panelRank);
                rankFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                rankFrame.pack();

                Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
                rankFrame.setSize(WINDOW_WIDTH, WINDOW_HEIGHT);
                rankFrame.setBounds(((int) screenSize.getWidth() - WINDOW_WIDTH) / 2, 0,
                        WINDOW_WIDTH, WINDOW_HEIGHT);

                //addFrame.setSize(WINDOW_WIDTH / 4, WINDOW_HEIGHT / 10);
                //设置窗口的大小和位置,居中放置
                addFrame.setBounds(((int) screenSize.getWidth() - WINDOW_WIDTH) / 2, 0,
                        WINDOW_WIDTH, WINDOW_HEIGHT / 3);

                Object lock = new Object();

                addObj.buttonOK.addActionListener(new ActionListener() {
                    @Override
                    public void actionPerformed(ActionEvent e) {
                        synchronized (lock) {
                            playerDAO.addPlayer(addObj.playerIDEditior.getText(), score);
                            savePlayerList(playerDAO);
                            addFrame.setVisible(false);
                            rankFrame.setVisible(true);
                            lock.notify();
                        }
                    }
                });

                addObj.buttonCancel.addActionListener(new ActionListener() {
                    @Override
                    public void actionPerformed(ActionEvent e) {
                        synchronized (lock) {
                            addFrame.setVisible(false);
                            rankFrame.setVisible(true);
                            lock.notify();
                        }
                    }
                });

                List<Player> playerList = null;

                Runnable rAddPlayer = () -> {
                    addFrame.setVisible(true);
                };

                Runnable rRankList = () -> {
                    synchronized (lock) {
                        try {
                            lock.wait();
                        } catch(InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                    List<Player> playerListTemp = playerDAO.getPlayerList();
                    String[] columnName = {"排名", "ID", "成绩", "时间"};
                    String[][] tableData = new String[playerListTemp.size()][4];
                    for(Player player: playerListTemp) {
                        tableData[playerListTemp.indexOf(player)][0] = (playerListTemp.indexOf(player) + 1) + "";
                        tableData[playerListTemp.indexOf(player)][1] = player.getPlayerName();
                        tableData[playerListTemp.indexOf(player)][2] = player.getScore() + "";
                        tableData[playerListTemp.indexOf(player)][3] = player.getDateTime();
                    }
                    DefaultTableModel model = new DefaultTableModel(tableData, columnName) {
                        @Override
                        public boolean isCellEditable(int row, int col) {
                            return false;
                        }
                    };
                    rankObj.tableRank.setModel(model);
                    rankObj.DELETEButton.addActionListener(new ActionListener() {
                        @Override
                        public void actionPerformed(ActionEvent e) {
                            synchronized (lock) {
                                int row = rankObj.tableRank.getSelectedRow();
                                String[] option = {"OK", "Cancel"};
                                int opt = JOptionPane.showOptionDialog(null, "是否确认删除该记录？", "删除确认", JOptionPane.DEFAULT_OPTION, JOptionPane.INFORMATION_MESSAGE, null, option, option[0]);
                                if (row != -1 && opt == 0) {
                                    model.removeRow(row);
                                    playerDAO.deletePlayer(row);
                                    savePlayerList(playerDAO);
                                }
                            }
                        }
                    });
                };
                Thread tAddPlayer = new Thread(rAddPlayer, "AddPlayer");
                Thread tRankList = new Thread(rRankList, "RankList");
                tRankList.start();
                tAddPlayer.start();

            }
        };

        /**
         * 以固定延迟时间进行执行
         * 本次任务执行完成后，需要延迟设定的延迟时间，才会执行新的任务
         */
        executorService.scheduleWithFixedDelay(task, timeInterval, timeInterval, TimeUnit.MILLISECONDS);

    }

    //***********************
    //      Action 各部分
    //***********************

    private boolean timeCountAndNewCycleJudge() {
        cycleTime += timeInterval;
        if (cycleTime >= cycleDuration && cycleTime - timeInterval < cycleTime) {
            // 跨越到新的周期
            cycleTime %= cycleDuration;
            return true;
        } else {
            return false;
        }
    }

    private void shootAction() {
        // 敌机射击
        if(shootPeriodFlag >= shootPeriodLimit) {
            for (AbstractAircraft enemy : enemyAircrafts) {
                enemyBullets.addAll(enemy.shoot());
            }

            shootPeriodFlag = 0;
        }
        // 英雄射击
        heroBullets.addAll(heroAircraft.shoot());
        if(bgmFlag) {
            MusicThread bulletShootThread = new MusicThread("src/videos/bullet.wav");
            bulletShootThread.start();
        }
    }

    private void bulletsMoveAction() {
        for (BaseBullet bullet : heroBullets) {
            bullet.forward();
        }
        for (BaseBullet bullet : enemyBullets) {
            bullet.forward();
        }
    }

    private void aircraftsMoveAction() {
        for (AbstractAircraft enemyAircraft : enemyAircrafts) {
            enemyAircraft.forward();
        }
    }

    private void itemMoveAction() {
        for(AbstractItem item: itemList) {
            item.forward();
        }
    }


    /**
     * 碰撞检测：
     * 1. 敌机攻击英雄
     * 2. 英雄攻击/撞击敌机
     * 3. 英雄获得补给
     */
    private void crashCheckAction() {
        // 敌机子弹攻击英雄
        for(BaseBullet bullet: enemyBullets) {
            if(bullet.notValid()) {
                continue;
            }

            if(heroAircraft.crash(bullet)) {
                heroAircraft.decreaseHp(bullet.getPower());
                if(bgmFlag) {
                    MusicThread bulletHitThread = new MusicThread("src/videos/bullet_hit.wav");
                    bulletHitThread.start();
                }
                bullet.vanish();
            }
        }

        // 英雄子弹攻击敌机
        for (BaseBullet bullet : heroBullets) {
            if (bullet.notValid()) {
                continue;
            }
            for (AbstractAircraft enemyAircraft : enemyAircrafts) {
                if (enemyAircraft.notValid()) {
                    // 已被其他子弹击毁的敌机，不再检测
                    // 避免多个子弹重复击毁同一敌机的判定
                    continue;
                }
                if (enemyAircraft.crash(bullet)) {
                    // 敌机撞击到英雄机子弹
                    // 敌机损失一定生命值
                    if(bgmFlag) {
                        MusicThread bulletHitThread = new MusicThread("src/videos/bullet_hit.wav");
                        bulletHitThread.start();
                    }
                    enemyAircraft.decreaseHp(bullet.getPower());
                    bullet.vanish();
                    if (enemyAircraft.notValid()) {
                        // 获得分数，产生道具补给
                        if(enemyAircraft.eliteFlag) {
                            score += 20;
                            bossScore += 20;
                        } else if(enemyAircraft.bossFlag) {
                            score += 50;
                            bossScore += 50;
                        } else {
                            score += 10;
                            bossScore += 10;
                        }
                        if(enemyAircraft.bossFlag) {
                            bossGenerationFlag = true;
                            if(bgmFlag) {
                                bossThread.over();
                                bgmThread = new MusicThread("src/videos/bgm.wav");
                                bgmThread.start();
                            }
                            difficultyEvolve();
                        }

                        double prob = Math.random();
                        AbstractItem newItem = null;
                        if (prob < 0.3) {
                            newItem = enemyAircraft.dropItem(healingItemFactory);
                        } else if (prob >= 0.3 && prob <= 0.6) {
                            newItem = enemyAircraft.dropItem(fireSupplyItemFactory);
                        } else if (prob > 0.6 && prob <= 0.9) {
                            newItem = enemyAircraft.dropItem(bombSupplyItemFactory);
                        }

                        if(newItem != null) {
                            itemList.add(newItem);
                        }

                    }
                }
                // 英雄机 与 敌机 相撞，均损毁
                if (enemyAircraft.crash(heroAircraft) || heroAircraft.crash(enemyAircraft)) {
                    enemyAircraft.vanish();
                    heroAircraft.decreaseHp(Integer.MAX_VALUE);
                }
            }
        }

        // 我方获得道具，道具生效
        for(AbstractItem item: itemList) {
            if(item.notValid()) {
                continue;
            }

            if(heroAircraft.crash(item)) {
                if(bgmFlag) {
                    MusicThread getSupplyThread = new MusicThread("src/videos/get_supply.wav");
                    getSupplyThread.start();
                }
                item.itemFunction();
                item.vanish();
            }
        }
    }

    /**
     * 后处理：
     * 1. 删除无效的子弹
     * 2. 删除无效的敌机
     * 3. 检查英雄机生存
     * <p>
     * 无效的原因可能是撞击或者飞出边界
     */
    private void postProcessAction() {
        enemyBullets.removeIf(AbstractFlyingObject::notValid);
        heroBullets.removeIf(AbstractFlyingObject::notValid);
        enemyAircrafts.removeIf(AbstractFlyingObject::notValid);
        itemList.removeIf(AbstractFlyingObject::notValid);
    }


    //***********************
    //      Paint 各部分
    //***********************

    /**
     * 重写paint方法
     * 通过重复调用paint方法，实现游戏动画
     *
     * @param  g
     */
    @Override
    public void paint(Graphics g) {
        super.paint(g);

        // 绘制背景,图片滚动
        g.drawImage(ImageManager.BACKGROUND_IMAGE, 0, this.backGroundTop - WINDOW_HEIGHT, null);
        g.drawImage(ImageManager.BACKGROUND_IMAGE, 0, this.backGroundTop, null);
        this.backGroundTop += 1;
        if (this.backGroundTop == WINDOW_HEIGHT) {
            this.backGroundTop = 0;
        }

        // 先绘制子弹，后绘制飞机
        // 这样子弹显示在飞机的下层
        paintImageWithPositionRevised(g, enemyBullets);
        paintImageWithPositionRevised(g, itemList);
        paintImageWithPositionRevised(g, heroBullets);

        paintImageWithPositionRevised(g, enemyAircrafts);

        g.drawImage(ImageManager.HERO_IMAGE, heroAircraft.getLocationX() - ImageManager.HERO_IMAGE.getWidth() / 2,
                heroAircraft.getLocationY() - ImageManager.HERO_IMAGE.getHeight() / 2, null);

        //绘制得分和生命值
        paintScoreAndLife(g);

    }

    private void paintImageWithPositionRevised(Graphics g, List<? extends AbstractFlyingObject> objects) {
        if (objects.size() == 0) {
            return;
        }

        for (AbstractFlyingObject object : objects) {
            BufferedImage image = object.getImage();
            assert image != null : objects.getClass().getName() + " has no image! ";
            g.drawImage(image, object.getLocationX() - image.getWidth() / 2,
                    object.getLocationY() - image.getHeight() / 2, null);
        }
    }

    private void paintScoreAndLife(Graphics g) {
        int x = 10;
        int y = 25;
        g.setColor(new Color(16711680));
        g.setFont(new Font("SansSerif", Font.BOLD, 22));
        g.drawString("SCORE:" + this.score, x, y);
        y = y + 20;
        g.drawString("LIFE:" + this.heroAircraft.getHp(), x, y);
    }


}
