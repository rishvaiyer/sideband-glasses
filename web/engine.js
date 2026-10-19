export class SignalSession {
  constructor() { this.signals = new Map(); this.announced = new Set(); this.alerts = []; this.lastAlert = -Infinity; this.quiet = false; }
  ingest(o) {
    if (!o || typeof o.id !== 'string' || !o.id || o.id.length > 128 || !Number.isFinite(o.timestamp) || !Number.isInteger(o.rssi) || o.rssi < -127 || o.rssi > -1 || !Array.isArray(o.services) || o.services.length > 64) return null;
    let s = this.signals.get(o.id);
    if (s && o.timestamp < s.lastSeen) return null;
    if (!s && this.signals.size >= 128) return null;
    s ??= {id:o.id, firstSeen:o.timestamp, lastSeen:o.timestamp, samples:[], services:[], observations:0, ignored:false};
    s.lastSeen=o.timestamp; s.samples=[...s.samples,o.rssi].slice(-20); s.observations++;
    s.services=[...new Set([...s.services,...o.services.filter(v=>typeof v==='string' && v.length<=36).map(v=>v.toUpperCase())])].sort();
    this.signals.set(s.id,s);
    if (!isMeta(s) || s.observations<3 || s.lastSeen-s.firstSeen<2 || s.ignored || this.quiet || this.announced.has(s.id) || o.timestamp-this.lastAlert<30) return null;
    const message='A Meta-associated Bluetooth signal has appeared nearby. Device type and recording are unconfirmed.';
    this.announced.add(s.id); this.lastAlert=o.timestamp; this.alerts.push(message); return message;
  }
  toggleIgnored(id) { const s=this.signals.get(id); if(s) s.ignored=!s.ignored; }
  recap(now) { const all=[...this.signals.values()]; return `Session recap. ${all.length} Bluetooth signals observed. ${all.filter(s=>active(s,now)&&!s.ignored).length} recently seen. ${all.filter(s=>isMeta(s)&&!s.ignored).length} matched the Meta-associated service rule. Recording was not determined.`; }
}
export const isMeta=s=>s.services.some(v=>v==='FD5F'||v==='0000FD5F-0000-1000-8000-00805F9B34FB');
export const active=(s,now)=>now>=s.lastSeen && now-s.lastSeen<=20;
export const median=s=>[...s.samples].sort((a,b)=>a-b)[Math.floor(s.samples.length/2)];
export function scenario(name,t) {
 const ids=name==='cafe'?['A','B','C']:name==='commute'?['A','B','C','D','E']:['A','B'];
 return ids.filter((_,i)=>t>=i*5).filter((id)=>!(name==='commute'&&t>24&&id==='B')).map((id,i)=>({id,services:i===0||i===2?['FD5F']:i===1?['180F']:[],rssi:Math.round(-46-i*9+Math.sin(t/3+i)*7),timestamp:t}));
}
