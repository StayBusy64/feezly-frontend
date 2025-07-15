
// === Live WebSocket Cortex Hook ===
const socket = new WebSocket('ws://127.0.0.1:8000/ws');

socket.onmessage = (event) => {
    try {
        const graphData = JSON.parse(event.data);
        updateGraph(graphData);
        pulseNodes(graphData.nodes);
        updateStats();
    } catch (err) {
        console.error('? WebSocket parse error:', err);
    }
};

function pulseNodes(nodes) {
    d3.selectAll('circle')
        .transition().duration(400)
        .attr('r', 10)
        .transition().duration(400)
        .attr('r', 6);
}

// === Zone-based coloring ===
function zoneColor(zone) {
    return {
        "Core": "#ff4c4c",
        "Vision": "#4cafff",
        "Proxy": "#7dff4c"
    }[zone] || "#cccccc";
}

// === Status HUD ===
const statusBox = document.createElement("div");
statusBox.style.cssText = "position:absolute;top:10px;right:10px;color:white;background:#000a;padding:8px;border-radius:8px;z-index:1000;font-size:14px";
statusBox.id = "liveStatus";
statusBox.innerText = "?? Waiting for updates...";
document.body.appendChild(statusBox);

function updateStats() {
    const now = new Date().toLocaleTimeString();
    document.getElementById("liveStatus").innerText = "?? Last update: " + now;
}

// === Zone color bind on updateGraph call ===
const originalUpdateGraph = updateGraph;
updateGraph = function(graphData) {
    simulation.nodes(graphData.nodes);
    simulation.force("link").links(graphData.links);

    svg.selectAll(".link")
        .data(graphData.links)
        .join("line")
        .attr("class", "link");

    svg.selectAll(".node")
        .data(graphData.nodes)
        .join("circle")
        .attr("class", "node")
        .attr("r", 6)
        .style("fill", d => zoneColor(d.zone || ""))
        .call(drag(simulation));

    simulation.alpha(1).restart();
}
