using System.Net.WebSockets;
using System.Text;

namespace SaunaMonitor.Services;

public class WebSocketHandler
{
    private readonly List<WebSocket> _connectedSockets = new();

    // create new websocket connections 
    public async Task HandleWebSocketConnection(HttpContext context, WebSocket webSocket)
    {
        _connectedSockets.Add(webSocket); // track connected clients
        await ReceiveMessages(context, webSocket); // listen for messages
    }

    // listen for messages from connected clients
    private async Task ReceiveMessages(HttpContext context, WebSocket webSocket)
    {
        var buffer = new byte[1024 * 4]; // 4KB
        var result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

        while (!result.CloseStatus.HasValue)
            result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);

        // remove the disconnected client
        _connectedSockets.Remove(webSocket);
        await webSocket.CloseAsync(result.CloseStatus.Value, result.CloseStatusDescription, CancellationToken.None);
    }

    // send messages to all connected clients
    public async Task BroadcastMessage(string message)
    {
        var buffer = Encoding.UTF8.GetBytes(message);

        // loop through all connected clients and send the message
        foreach (var socket in _connectedSockets)
            if (socket.State == WebSocketState.Open)
                await socket.SendAsync(new ArraySegment<byte>(buffer), WebSocketMessageType.Text, true,
                    CancellationToken.None);
    }
}