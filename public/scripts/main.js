/*
 * Websocket
 */
let socket

function connect()
{
	log("connecting...");
	socket = new WebSocket(getBaseURL() + "/ws");
	socket.onopen = function() {
		log("connected. waiting for timer...");
	}
	socket.onmessage = function(message) {	
        let data = message.split("\n");
        if data[0] == "grid";
        draw(data.slice(1));
	}

	socket.onclose = function() {
		log("Connection closed.");
	}
	socket.onerror = function() {
		log("Websocket error!");
	}
}

function getBaseURL()
{
	var href = window.location.href.substring(7); // strip "http://"
	var idx = href.indexOf("/");
	return "ws://" + href.substring(0, idx);
}


/*
 * Input
 */ 
document.onkeydown = function(evt) {
    evt = evt || window.event;
    let charCode = evt.keyCode || evt.which;
    let key;
    switch(charCode) {
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
        socket.send(key);
        log("Key pressed: " + key);
    }
};

/*
 * Draw
 */ 

function draw(grid) {
    let canvas = document.getElementById("canvas");

    var id = canvas.createImageData(1,1);
    var d  = id.data;
    d[0]   = 0;
    d[1]   = 0;
    d[2]   = 0;
    d[3]   = 100;
    canvas.putImageData(id, 5, 5 );    
}


/*
 * Log
 */
function log(text)
{
    document.getElementById("log").innerHTML += text + '<br/>';
}
