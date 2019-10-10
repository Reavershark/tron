module app;

import vibe.core.core : sleep;

import vibe.core.log;
import vibe.http.fileserver : serveStaticFiles;
import vibe.http.router : URLRouter;
import vibe.http.server;
import vibe.web.web;
import vibe.http.websockets : WebSocket, handleWebSockets;

import core.time;
import std.conv : to;

import std.array;
import std.uuid;

import types;
import game;

struct UserSettings {
    string userName;
}

class WebsocketService {
    private {
        SessionVar!(UserSettings, "settings") m_userSettings;
        TronGame[UUID] games;
    }

    @path("/") void getHome()
    {
        render!("index.dt");
    }

    @path("/ws") void getWebsocket(scope WebSocket socket){
        TronGame game;
        int id;

        if (games.length == 0)
        {
            game = new TronGame;
            games[randomUUID()] = game;
            id = 0;
        }
        else
        {
            foreach(g; games)
                game = g;
            id = 1;
        }

        logInfo("Got new web socket connection.");
        logInfo("Player: %d", id);

        do {
            sleep(250.msecs);

            if (socket.dataAvailableForRead)
            {
                auto message = socket.receiveText.split;
                logInfo("Reveived message: %s", message);

                if (message[0] == "turn")
                    game.setDirection(id, message[1]);
            }

            socket.send("grid\n" ~ game.getGrid());
        } while (socket.connected && game.tick());

        logInfo("Client disconnected.");
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

    logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}
