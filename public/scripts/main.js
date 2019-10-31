function init() {

}

/* Rooms */
function newGame() {
    const req = new XMLHttpRequest();
    req.onreadystatechange = () => { location.reload(); }
    req.open("GET", "create");
    req.send();
}

/* Log */

function log(text) {
    let e = document.getElementById("log")
    e.innerHTML = '<p>' + text + '<p/>' + e.innerHTML;
}

/* Websocket */
let socket


function connect(uuid) {
    log("connecting...");
    socket = new WebSocket(getBaseURL() + "/ws" + "?uuid=" + uuid);

    socket.onmessage = handleMessage;
    socket.onopen = () => { log("connected. waiting for timer..."); }
    socket.onclose = () => { log("Connection closed."); location.reload(); }
    socket.onerror = () => { log("Websocket error!"); }
}

function handleMessage(message) {
    let data = message.data.split("\n");
    if (data[0] == "grid")
        draw(data.slice(1));
}

function getBaseURL() {
    var href = window.location.href.substring(7); // strip "http://"
    var idx = href.indexOf("/");
    return "ws://" + href.substring(0, idx);
}

/* Input */
document.onkeydown = function (evt) {
    evt = evt || window.event;
    let charCode = evt.keyCode || evt.which;
    let key;
    switch (charCode) {
        case 37:
            key = "left";
            break;
        case 38:
            key = "up";
            break;
        case 39:
            key = "right";
            break;
        case 40:
            key = "down";
            break;
        default:
            key = "unknown";
    }
    if (key != "unknown") {
        socket.send("turn\n" + key);
        log("Key pressed: " + key);
    }
};

/* Draw */

let rgbaBlack = "rgba(0,0,0,255)";
let rgbaWhite = "rgba(255,255,255,255)";

function draw(grid) {
    let drawContext = document.getElementById("game").getContext('2d');
    drawContext.imageSmoothingEnabled = false;

    drawContext.fillStyle = rgbaWhite;
    drawContext.fillRect(0
        , 0, 96, 64);

    grid.forEach((line, y) => {
        [...line].forEach((c, x) => {
            if (c == '1') {
                drawContext.fillStyle = rgbaBlack;
                drawContext.fillRect(x, y, 1, 1);
            }
        });
    });

}