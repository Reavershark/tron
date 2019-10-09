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
		log("Server: " + message.data);
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
 * Log
 */
function log(text)
{
    document.getElementById("log").innerHTML += text + '<br/>';
}
