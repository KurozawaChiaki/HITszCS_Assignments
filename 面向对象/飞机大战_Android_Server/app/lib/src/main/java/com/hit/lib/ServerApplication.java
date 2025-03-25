package com.hit.lib;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;

public class ServerApplication {
    private HashMap<String, PlayerStatus> playerList;
    private String content;

    public static void main(String[] args) {
        new ServerApplication();
    }

    public ServerApplication() {
        playerList = new HashMap<>();
        try{
            InetAddress addr = InetAddress.getLocalHost();
            System.out.println("local host:" + addr);

            //创建server socket
            ServerSocket serverSocket = new ServerSocket(9999);
            System.out.println("listen port 9999");

            while(true){
                System.out.println("waiting client connect");
                Socket socket = serverSocket.accept();
                System.out.println("accept client connect" + socket);
                new Thread(new Service(socket)).start();
            }
        }catch (Exception ex){
            ex.printStackTrace();
        }
    }

    class Service implements Runnable {
        private Socket socket;
        private BufferedReader in = null;
        private PrintWriter writer = null;

        public Service(Socket socket) {
            this.socket = socket;

            try {
                in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                writer = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())), true);
            } catch(Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void run() {
            System.out.println("Waiting For the Client.");

            try {
                while ((content = in.readLine()) != null) {
                    System.out.println("messge from client:" + content.toString());
                    if(content.equals("Player START")) {
                        String name = in.readLine();
                        String score = in.readLine();
                        String flag = in.readLine();

                        PlayerStatus newPlayer = new PlayerStatus();
                        newPlayer.playerID = name;
                        System.out.println("--------------");
                        System.out.println(name);
                        System.out.println(score);
                        System.out.println(flag);
                        System.out.println("--------------");
                        newPlayer.playerScore = Integer.parseInt(score);
                        newPlayer.playerReady = Boolean.parseBoolean(flag);
                        fillList(newPlayer);
                        sendMessage(newPlayer);
                    } else if(content.equals("BYE")) {
                        socket.shutdownInput();
                        socket.shutdownOutput();
                        socket.close();
                        playerList.clear();
                    }
                }
            } catch(Exception e) {
                e.printStackTrace();
            }
        }

        private void fillList(PlayerStatus player) {
            if(player == null) {
                return;
            }
            if(playerList.containsKey(player.playerID)) {
                playerList.replace(player.playerID, player);
            } else {
                playerList.put(player.playerID, player);
            }

            while(playerList.size() < 2) {
                // System.out.println("Waiting For 2nd Player");
                writer.println("WAITING");
            }
        }

        private void sendMessage(PlayerStatus currentPlayer) {
            try {
                PlayerStatus otherPlayer = null;
                for(String playerName: playerList.keySet()) {
                    if(playerName.equals(currentPlayer.playerID)) {
                        continue;
                    } else {
                        otherPlayer = playerList.get(playerName);
                    }
                }
                writer.println("Player START");
                writer.println(otherPlayer.playerID);
                writer.println(otherPlayer.playerScore);
                writer.println(otherPlayer.playerReady);
                writer.println("Player END");
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
}