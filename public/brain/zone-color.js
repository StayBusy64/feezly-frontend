function getZoneColor(zone) {
  switch(zone) {
    case 'Core': return '#FF6B6B';
    case 'Proxy': return '#4D96FF';
    case 'Vision': return '#6BCB77';
    case 'Synthetic': return '#FFD93D';
    default: return '#999';
  }
}
