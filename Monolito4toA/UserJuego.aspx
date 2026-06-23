<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserJuego.aspx.cs" Inherits="Monolito4toA.UserJuego" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Geometry Rush Evolution — Monolito</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@800;900&family=Plus+Jakarta+Sans:wght@700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <style>
        :root { --bg: #030712; --primary: #6366f1; --secondary: #ec4899; --accent: #10b981; --border: rgba(255,255,255,0.1); }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
        body { background: var(--bg) !important; color: white; overflow-y: auto !important; display: flex; flex-direction: column; min-height: 100vh; }
        .game-header { padding: 15px 40px; background: rgba(0,0,0,0.5); display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); }
        .canvas-container { flex: 1; display: flex; align-items: center; justify-content: center; position: relative; background: #000; overflow: hidden; }
        canvas { background: linear-gradient(180deg, #0f172a 0%, #030712 100%); cursor: crosshair; }
        .hud { position: absolute; top: 20px; left: 20px; pointer-events: none; }
        .stat { background: rgba(0,0,0,0.6); padding: 10px 20px; border-radius: 12px; margin-bottom: 10px; border: 1px solid var(--border); }
        .stat-val { font-size: 24px; font-weight: 900; color: var(--primary); font-family: 'Outfit'; }
        #death-screen { position: absolute; inset: 0; background: rgba(0,0,0,0.85); display: none; flex-direction: column; align-items: center; justify-content: center; z-index: 100; backdrop-filter: blur(5px); }
        .btn-play { background: var(--primary); color: white; border: none; padding: 15px 40px; border-radius: 12px; font-weight: 800; font-size: 18px; cursor: pointer; box-shadow: 0 10px 20px rgba(99,102,241,0.3); transition: 0.3s; }
        .btn-play:hover { transform: scale(1.05); background: var(--secondary); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="game-header">
            <a href="Dashboard.aspx" style="color:white; text-decoration:none; font-weight:800;"><i class="fa-solid fa-arrow-left"></i> SALIR</a>
            <h2 style="font-family:'Outfit';">GEOMETRY <span style="color:var(--primary);">RUSH</span> EVOLUTION</h2>
            <div style="width:100px;"></div>
        </div>
        <div class="canvas-container">
            <canvas id="game" width="1200" height="600"></canvas>
            <div class="hud">
                <div class="stat"><div style="font-size:10px; color:var(--secondary);">PUNTOS</div><div id="score" class="stat-val">0</div></div>
                <div class="stat"><div style="font-size:10px; color:var(--accent);">MODO</div><div id="mode" class="stat-val" style="color:white; font-size:16px;">CUBO</div></div>
            </div>
            <div id="death-screen">
                <h1 style="font-size:60px; color:#ef4444; font-family:'Outfit'; margin-bottom:10px;">¡COLISIÓN!</h1>
                <p id="final-score" style="margin-bottom:30px; font-size:20px;">Puntos: 0</p>
                <button type="button" class="btn-play" onclick="reset()">VOLVER A INTENTAR</button>
            </div>
        </div>
        <div id="leaderboard-section" style="padding:40px; background:rgba(255,255,255,0.02); border-top:1px solid var(--border);">
            <div style="max-width:800px; margin:0 auto;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                    <h3 style="font-family:'Outfit'; font-size:24px;">🏆 TOP OPERADORES</h3>
                    <div style="background:var(--primary); padding:8px 15px; border-radius:10px; font-weight:800; font-size:12px;">
                        MI RÉCORD: <asp:Literal ID="litBestScore" runat="server" /> PTS
                    </div>
                </div>
                <div class="scores-container">
                    <asp:Literal ID="litScoresList" runat="server" />
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hfScoreSave" runat="server" />
        <asp:Button ID="btnSaveScoreHidden" runat="server" OnClick="btnSaveScore_Click" style="display:none" />
            </div>
        </div>
    </form>
    <script>
            const canvas = document.getElementById('game');
            const ctx = canvas.getContext('2d');
            const deathScreen = document.getElementById('death-screen');
            
            let player, obstacles, particles, frame, score, gameActive, mode, speed, shake = 0;
            const MODES = { CUBE: 'CUBO', SHIP: 'NAVE' };

            // Audio System
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            function playSound(freq, type, duration, vol) {
                const osc = audioCtx.createOscillator();
                const g = audioCtx.createGain();
                osc.type = type; osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
                g.gain.setValueAtTime(vol, audioCtx.currentTime);
                g.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + duration);
                osc.connect(g); g.connect(audioCtx.destination);
                osc.start(); osc.stop(audioCtx.currentTime + duration);
            }

            class Particle {
                constructor(x, y, color) {
                    this.x = x; this.y = y; this.vx = (Math.random() - 0.5) * 15; this.vy = (Math.random() - 0.5) * 15;
                    this.life = 1; this.color = color; this.size = Math.random() * 5 + 2;
                }
                draw() {
                    ctx.globalAlpha = this.life; ctx.fillStyle = this.color;
                    ctx.fillRect(this.x, this.y, this.size, this.size);
                    ctx.globalAlpha = 1;
                }
                update() { this.x += this.vx; this.y += this.vy; this.life -= 0.02; }
            }

            class Player {
                constructor() {
                    this.x = 150; this.y = 500; this.w = 40; this.h = 40;
                    this.vy = 0; this.rot = 0; this.color = '#6366f1'; this.trail = [];
                }
                draw() {
                    // Trail
                    this.trail.forEach((t, i) => {
                        ctx.globalAlpha = i / 10; ctx.fillStyle = this.color;
                        ctx.fillRect(t.x, t.y, this.w, this.h);
                    });
                    ctx.globalAlpha = 1;

                    ctx.save();
                    ctx.translate(this.x + 20, this.y + 20);
                    if (mode === MODES.CUBE) ctx.rotate(this.rot);
                    
                    ctx.shadowBlur = 20; ctx.shadowColor = this.color;
                    ctx.fillStyle = this.color;
                    if (mode === MODES.CUBE) {
                        ctx.fillRect(-20, -20, 40, 40);
                        ctx.strokeStyle = 'white'; ctx.lineWidth = 3;
                        ctx.strokeRect(-14, -14, 28, 28);
                    } else {
                        ctx.beginPath(); ctx.moveTo(25, 0); ctx.lineTo(-20, -18); ctx.lineTo(-10, 0); ctx.lineTo(-20, 18); ctx.closePath();
                        ctx.fill(); ctx.strokeStyle = 'white'; ctx.lineWidth = 2; ctx.stroke();
                    }
                    ctx.restore();
                }
                update() {
                    this.trail.push({x: this.x, y: this.y});
                    if(this.trail.length > 10) this.trail.shift();

                    if (mode === MODES.CUBE) {
                        this.vy += 0.85; this.y += this.vy;
                        if (this.y > 500) { this.y = 500; this.vy = 0; }
                        else { this.rot += 0.18; }
                    } else {
                        this.vy += 0.45; this.y += this.vy;
                        if (this.y < 40) { this.y = 40; this.vy = 0; }
                        if (this.y > 540) { this.y = 540; this.vy = 0; }
                        this.rot = this.vy * 0.05;
                    }
                }
                jump() {
                    if (mode === MODES.CUBE) {
                    if (this.y >= 500) { this.vy = -15; playSound(150, 'square', 0.2, 0.1); }
                } else { this.vy -= 1.4; playSound(400, 'sine', 0.1, 0.05); }
            }
        }

            function spawnObs() {
                let type = Math.random() > 0.6 ? 'spike' : 'block';
                if (mode === MODES.SHIP) {
                    type = 'gate';
                    let gap = Math.random() * 200 + 100;
                    obstacles.push({ x: 1300, y: gap, type: 'gate', w: 50, h: 600 });
                } else {
                    obstacles.push({ x: 1300, y: 500, type, w: 40, h: 40 });
                }
            }

            function reset() {
                player = new Player(); obstacles = []; particles = []; frame = 0; score = 0; speed = 9;
                gameActive = true; mode = MODES.CUBE; shake = 0;
                deathScreen.style.display = 'none';
                loop();
            }

            function loop() {
                if (!gameActive) return;
                handleInput();
                ctx.save();
                if(shake > 0) { ctx.translate(Math.random()*shake - shake/2, Math.random()*shake - shake/2); shake *= 0.9; }
                ctx.clearRect(0,0,1200,600);
                ctx.fillStyle = '#1e293b'; ctx.fillRect(0, 540, 1200, 60);
                ctx.strokeStyle = 'var(--primary)'; ctx.lineWidth = 2; ctx.strokeRect(-10, 540, 1220, 2);
                player.update(); player.draw();
                if (frame % Math.max(40, 70 - Math.floor(speed)) === 0) spawnObs();
                if (frame % 800 === 0) {
                    mode = mode === MODES.CUBE ? MODES.SHIP : MODES.CUBE;
                    document.getElementById('mode').innerText = mode;
                    speed += 0.8;
                    shake = 15;
                }
                obstacles.forEach((o, i) => {
                    o.x -= speed;
                    if (o.type === 'spike') {
                        ctx.fillStyle = '#ef4444'; ctx.beginPath(); ctx.moveTo(o.x, 540); ctx.lineTo(o.x+25, 490); ctx.lineTo(o.x+50, 540); ctx.fill();
                    } else if (o.type === 'block') {
                        ctx.fillStyle = '#f59e0b'; ctx.fillRect(o.x, o.y, 45, 45);
                        ctx.strokeStyle = 'white'; ctx.strokeRect(o.x+5, o.y+5, 35, 35);
                    } else if (o.type === 'gate') {
                        ctx.fillStyle = 'rgba(239, 68, 68, 0.3)'; ctx.fillRect(o.x, 0, 40, o.y - 100);
                        ctx.fillRect(o.x, o.y + 100, 40, 600);
                        ctx.fillStyle = '#ef4444'; ctx.fillRect(o.x, o.y - 110, 40, 10); ctx.fillRect(o.x, o.y + 100, 40, 10);
                    }
                    let hit = false;
                    if (o.type === 'gate') {
                        if (player.x + 30 > o.x && player.x < o.x + 40) {
                            if (player.y < o.y - 100 || player.y + 30 > o.y + 100) hit = true;
                        }
                    } else {
                        if (player.x + 30 > o.x && player.x < o.x + 40 && player.y + 30 > o.y && player.y < o.y + 40) hit = true;
                    }
                    if (hit) {
                        gameActive = false; shake = 30;
                        playSound(100, 'sawtooth', 0.5, 0.2);
                        for(let p=0; p<30; p++) particles.push(new Particle(player.x+20, player.y+20, player.color));
                        document.getElementById('final-score').innerText = "Puntos: " + Math.floor(score);
                        document.getElementById('<%= hfScoreSave.ClientID %>').value = Math.floor(score);
                        deathScreen.style.display = 'flex';
                        document.getElementById('<%= btnSaveScoreHidden.ClientID %>').click();
                    }
                    if (o.x < -100) obstacles.splice(i,1);
                });
                particles.forEach((p, i) => { p.update(); p.draw(); if(p.life <= 0) particles.splice(i,1); });
                score += 0.15;
                document.getElementById('score').innerText = Math.floor(score);
                frame++;
                ctx.restore();
                requestAnimationFrame(loop);
            }

        const keys = {};
        window.addEventListener('keydown', e => { 
            if (audioCtx.state === 'suspended') audioCtx.resume();
            if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.code)) e.preventDefault();
            keys[e.code] = true;
        });
        window.addEventListener('keyup', e => { keys[e.code] = false; });
        canvas.addEventListener('mousedown', () => { 
            if (audioCtx.state === 'suspended') audioCtx.resume();
            keys['Space'] = true; 
        });
        canvas.addEventListener('mouseup', () => { keys['Space'] = false; });

        function handleInput() {
            if (keys['Space'] || keys['ArrowUp']) {
                if (mode === MODES.CUBE) {
                    if (player.y >= 500) { player.vy = -15; playSound(150, 'square', 0.2, 0.1); }
                } else { 
                    player.vy -= 1.4;
                    if (frame % 5 === 0) playSound(400, 'sine', 0.1, 0.03);
                }
            }
        }
        reset();
    </script>
</body>
</html>
