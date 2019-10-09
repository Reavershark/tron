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

import types;
import game;

struct UserSettings {
    string userName;
}

class WebsocketService {
    private {
        SessionVar!(UserSettings, "settings") m_userSettings;
    }

    @path("/") void getHome()
    {
        render!("index.dt");
    }

    @path("/ws") void getWebsocket(scope WebSocket socket){
        logInfo("Got new web socket connection.");

        TronGame game = new TronGame();
        int id = 0;

        while (socket.connected) {
            do {
                sleep(1000.msecs);
                if (!socket.connected) break;

                if (socket.dataAvailableForRead)
                {
                    auto message = socket.receiveText.split;
                    logInfo("Reveived message: %s", message);

                    if (message[0] == "direction")
                        game.setDirection(id, message[1]);
                }

                //string message = "p1 20 50";
                socket.send(to!string(game.getGrid()));
            } while (game.tick());
        }
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