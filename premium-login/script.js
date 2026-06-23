document.addEventListener('DOMContentLoaded', () => {
    
    // --- Interactive 3D Card Effect ---
    const card = document.getElementById('card');
    const container = document.getElementById('container');
    
    // Solo aplicar el efecto 3D si no estamos en móvil
    if (window.innerWidth > 900) {
        container.addEventListener('mousemove', (e) => {
            const xAxis = (window.innerWidth / 2 - e.pageX) / 25;
            const yAxis = (window.innerHeight / 2 - e.pageY) / 25;
            card.style.transform = `rotateY(${xAxis}deg) rotateX(${yAxis}deg)`;
        });

        container.addEventListener('mouseenter', () => {
            card.style.transition = 'none';
        });

        container.addEventListener('mouseleave', () => {
            card.style.transition = 'transform 0.5s ease';
            card.style.transform = `rotateY(0deg) rotateX(0deg)`;
        });
    }

    // --- Particle Background Canvas ---
    const canvas = document.getElementById('particles-canvas');
    const ctx = canvas.getContext('2d');
    
    let particlesArray;

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    let mouse = {
        x: null,
        y: null,
        radius: (canvas.height/80) * (canvas.width/80)
    }

    window.addEventListener('mousemove',
        function(event) {
            mouse.x = event.x;
            mouse.y = event.y;
        }
    );

    class Particle {
        constructor(x, y, directionX, directionY, size, color) {
            this.x = x;
            this.y = y;
            this.directionX = directionX;
            this.directionY = directionY;
            this.size = size;
            this.color = color;
        }
        
        draw() {
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2, false);
            ctx.fillStyle = this.color;
            ctx.fill();
        }
        
        update() {
            if (this.x > canvas.width || this.x < 0) {
                this.directionX = -this.directionX;
            }
            if (this.y > canvas.height || this.y < 0) {
                this.directionY = -this.directionY;
            }

            // Interactividad con el mouse
            let dx = mouse.x - this.x;
            let dy = mouse.y - this.y;
            let distance = Math.sqrt(dx*dx + dy*dy);
            
            if (distance < mouse.radius + this.size){
                if (mouse.x < this.x && this.x < canvas.width - this.size * 10) {
                    this.x += 10;
                }
                if (mouse.x > this.x && this.x > this.size * 10) {
                    this.x -= 10;
                }
                if (mouse.y < this.y && this.y < canvas.height - this.size * 10) {
                    this.y += 10;
                }
                if (mouse.y > this.y && this.y > this.size * 10) {
                    this.y -= 10;
                }
            }
            this.x += this.directionX;
            this.y += this.directionY;
            this.draw();
        }
    }

    function init() {
        particlesArray = [];
        let numberOfParticles = (canvas.height * canvas.width) / 12000;
        for (let i = 0; i < numberOfParticles; i++) {
            let size = (Math.random() * 2) + 1;
            let x = (Math.random() * ((innerWidth - size * 2) - (size * 2)) + size * 2);
            let y = (Math.random() * ((innerHeight - size * 2) - (size * 2)) + size * 2);
            let directionX = (Math.random() * 2) - 1;
            let directionY = (Math.random() * 2) - 1;
            let color = 'rgba(102, 252, 241, 0.5)'; // Color de las partículas
            
            particlesArray.push(new Particle(x, y, directionX, directionY, size, color));
        }
    }

    function animate() {
        requestAnimationFrame(animate);
        ctx.clearRect(0,0,innerWidth, innerHeight);

        for (let i = 0; i < particlesArray.length; i++) {
            particlesArray[i].update();
        }
        connect();
    }

    function connect() {
        let opacityValue = 1;
        for (let a = 0; a < particlesArray.length; a++) {
            for (let b = a; b < particlesArray.length; b++) {
                let distance = ((particlesArray[a].x - particlesArray[b].x) * (particlesArray[a].x - particlesArray[b].x))
                + ((particlesArray[a].y - particlesArray[b].y) * (particlesArray[a].y - particlesArray[b].y));
                if (distance < (canvas.width/7) * (canvas.height/7)) {
                    opacityValue = 1 - (distance/20000);
                    ctx.strokeStyle = 'rgba(102, 252, 241,' + opacityValue + ')';
                    ctx.lineWidth = 1;
                    ctx.beginPath();
                    ctx.moveTo(particlesArray[a].x, particlesArray[a].y);
                    ctx.lineTo(particlesArray[b].x, particlesArray[b].y);
                    ctx.stroke();
                }
            }
        }
    }

    window.addEventListener('resize',
        function() {
            canvas.width = innerWidth;
            canvas.height = innerHeight;
            mouse.radius = ((canvas.height/80) * (canvas.height/80));
            init();
        }
    );

    init();
    animate();

    // --- Form Logic ---
    const loginForm = document.getElementById('loginForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const togglePasswordBtn = document.getElementById('togglePassword');
    const submitBtn = document.getElementById('submitBtn');
    const passwordStrengthContainer = document.querySelector('.password-strength');
    const strengthBar = document.querySelector('.strength-bar');

    // Toggle Password Visibility
    togglePasswordBtn.addEventListener('click', () => {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        
        const icon = togglePasswordBtn.querySelector('i');
        if (type === 'text') {
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    });

    // Password Strength Indicator
    passwordInput.addEventListener('input', (e) => {
        const val = e.target.value;
        
        if (val.length > 0) {
            passwordStrengthContainer.style.display = 'block';
        } else {
            passwordStrengthContainer.style.display = 'none';
        }

        strengthBar.className = 'strength-bar'; // Reset
        
        if (val.length >= 8 && /[A-Z]/.test(val) && /[0-9]/.test(val) && /[^A-Za-z0-9]/.test(val)) {
            strengthBar.classList.add('strength-strong');
        } else if (val.length >= 6 && (/[A-Z]/.test(val) || /[0-9]/.test(val))) {
            strengthBar.classList.add('strength-medium');
        } else if (val.length > 0) {
            strengthBar.classList.add('strength-weak');
        }
    });

    // Form Submission & Validation
    loginForm.addEventListener('submit', (e) => {
        e.preventDefault();
        
        let isValid = true;
        const emailGroup = emailInput.closest('.input-group');
        const passwordGroup = passwordInput.closest('.input-group');

        // Reset errors
        emailGroup.classList.remove('error', 'shake');
        passwordGroup.classList.remove('error', 'shake');

        // Validate Email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(emailInput.value)) {
            emailGroup.classList.add('error');
            // Trigger reflow to restart animation
            void emailGroup.offsetWidth;
            emailGroup.classList.add('shake');
            isValid = false;
        }

        // Validate Password
        if (passwordInput.value.length < 8) {
            passwordGroup.classList.add('error');
            void passwordGroup.offsetWidth;
            passwordGroup.classList.add('shake');
            isValid = false;
        }

        if (isValid) {
            // Simulate Loading State
            submitBtn.classList.add('loading');
            
            setTimeout(() => {
                submitBtn.classList.remove('loading');
                // Success animation or redirect
                submitBtn.innerHTML = '<i class="fa-solid fa-check"></i><span style="margin-left:8px;">Acceso Concedido</span>';
                submitBtn.style.background = 'linear-gradient(135deg, #00e676 0%, #00c853 100%)';
                
                setTimeout(() => {
                    // Reset button after showing success
                    submitBtn.innerHTML = '<span class="btn-text">Iniciar Sesión</span><div class="loader"></div><div class="btn-glow"></div>';
                    submitBtn.style.background = '';
                    loginForm.reset();
                    passwordStrengthContainer.style.display = 'none';
                }, 2000);
            }, 1500);
        }
    });

    // Remove error states on input
    emailInput.addEventListener('input', () => {
        emailInput.closest('.input-group').classList.remove('error', 'shake');
    });

    passwordInput.addEventListener('input', () => {
        passwordInput.closest('.input-group').classList.remove('error', 'shake');
    });
});
