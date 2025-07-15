setInterval(() => {
  fetch('ReflexTimeline.json')
    .then(res => res.json())
    .then(data => {
      const now = Date.now();
      const decay = 8000;
      const spikes = {};

      data.forEach(entry => {
        const age = now - new Date(entry.timestamp).getTime();
        if (age < decay) {
          spikes[entry.target] = (spikes[entry.target] || 0) + 1;
        }
      });

      d3.selectAll('circle.node')
        .attr('r', d => 5 + (spikes[d.id] || 0))
        .style('fill', d => spikes[d.id] ? '#ff4444' : '#aaa');

    });
}, 1000);
