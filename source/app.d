module app;

import vibe.core.core : sleep;

import std.exception : enforce;
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
    UUID playerUUID = UUID.init;
}

class WebsocketService
{
    private SessionVar!(UserSettings, "settings") m_userSettings;

    @path("/") void getHome()
    {
        render!("index.dt", games);
    }

    @path("/create") void getCreate(scope HTTPServerResponse res)
    {
        UUID uuid = randomUUID();
        games[uuid] = new TronGame;
        res.writeVoidBody();
    }

    @path("/ws") void getWebsocket(scope WebSocket socket)
    {
        auto request = cast(HTTPServerRequest) socket.request;

        if (m_userSettings.playerUUID == UUID.init) // Register user session
        {
            UserSettings s;
            s.playerUUID = randomUUID();
            m_userSettings = s;
        }

        UUID gameUUID = request.query["uuid"];
        UUID playerUUID = m_userSettings.playerUUID;

        enforce(gameUUID in games, "Game has ended");

        if (games[gameUUID].addPlayer(playerUUID))
            logInfo("Player %s joined game %s", playerUUID, gameUUID);
        else
        {
            logInfo("Player %s tried to join full game %s", playerUUID, gameUUID);
            enforce(false, "Game is full");
        }

        while (socket.connected)
        {
            TronGame game = games[gameUUID];
            if (socket.dataAvailableForRead)
            {
                auto message = socket.receiveText.split;
                logInfo("Reveived message: %s", message);

                if (message[0] == "turn")
                    game.setDirection(playerUUID, message[1]);
            }
            socket.send("grid\n" ~ game.getGrid());

            sleep(75.msecs);
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
            }
        }
        sleep(150.msecs);
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
    settings.sessionStore = new MemorySessionStore;
    listenHTTP(settings, router);

    runTask(&gameLoop);

    logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}
