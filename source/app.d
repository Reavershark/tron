module app;

import vibe.core.core : sleep;

import vibe.core.log;
import vibe.http.fileserver : serveStaticFiles;
import vibe.http.router : URLRouter;
import vibe.http.server;
import vibe.web.web;
import vibe.http.websockets : WebSocket, handleWebSockets;
import vibe.core.core : runTask;

import core.time;
import std.conv : to;

import std.array;
import std.uuid;

import types;
import game;

__gshared TronGame[UUID] games;

struct UserSettings
{
    string userName;
    UUID lastRoom;
}

class WebsocketService
{
    private
    {
        SessionVar!(UserSettings, "settings") m_userSettings;
    }

    @path("/") void getHome()
    {
        render!("index.dt", games);
    }

    @path("/ws") void getWebsocket(scope WebSocket socket)
    {
        UUID gameUUID;
        int playerId;

        if (games.length == 0)
        {
            gameUUID = randomUUID();
            games[gameUUID] = new TronGame;
            playerId = 0;
        }
        else
        {
            foreach (uuid; games.byKey)
                gameUUID = uuid;
            playerId = 1;
        }

        logInfo("Got new web socket connection.");
        logInfo("Player: %d", playerId);

        while (socket.connected)
        {
            TronGame game = games[gameUUID];
            if (socket.dataAvailableForRead)
            {
                auto message = socket.receiveText.split;
                logInfo("Reveived message: %s", message);

                if (message[0] == "turn")
                    game.setDirection(playerId, message[1]);
            }
            socket.send("grid\n" ~ game.getGrid());

            sleep(250.msecs);
        }

        logInfo("Client disconnected.");
    }
}

void gameLoop()
{
    while (true)
    {
        foreach (uuid, game; games)
        {
            if (!game.tick())
            {
                // Game end
                game.restart();
                //games.remove(uuid);
            }
        }
        sleep(1000.msecs);
    }
}

shared static this()
{
    auto router = new URLRouter;

    router.registerWebInterface(new WebsocketService);

    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);

    runTask(&gameLoop);

    logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}
