// WebGL Fluid Simulation
// Based on PavelDoGreat's WebGL-Fluid-Simulation

const canvas = document.createElement('canvas');
canvas.id = 'fluid-canvas';
canvas.style.position = 'fixed';
canvas.style.top = '0';
canvas.style.left = '0';
canvas.style.width = '100%';
canvas.style.height = '100%';
canvas.style.zIndex = '1';
canvas.style.pointerEvents = 'none';

// Wait for DOM to be ready
function initFluid() {
    if (document.body) {
        document.body.insertBefore(canvas, document.body.firstChild);
        
        // Make sure Flutter content is above
        const flutterView = document.querySelector('flutter-view, flt-glass-pane, #app-container');
        if (flutterView) {
            flutterView.style.position = 'relative';
            flutterView.style.zIndex = '2';
        }
        
        startFluidSimulation();
    } else {
        setTimeout(initFluid, 100);
    }
}

function startFluidSimulation() {
    const config = {
        SIM_RESOLUTION: 128,
        DYE_RESOLUTION: 1024,
        CAPTURE_RESOLUTION: 512,
        DENSITY_DISSIPATION: 1,
        VELOCITY_DISSIPATION: 0.2,
        PRESSURE: 0.8,
        PRESSURE_ITERATIONS: 20,
        CURL: 30,
        SPLAT_RADIUS: 0.25,
        SPLAT_FORCE: 6000,
        SHADING: true,
        COLORFUL: true,
        COLOR_UPDATE_SPEED: 10,
        PAUSED: false,
        BACK_COLOR: { r: 10, g: 14, b: 39 },
        TRANSPARENT: false,
        BLOOM: true,
        BLOOM_ITERATIONS: 8,
        BLOOM_RESOLUTION: 256,
        BLOOM_INTENSITY: 0.8,
        BLOOM_THRESHOLD: 0.6,
        BLOOM_SOFT_KNEE: 0.7,
        SUNRAYS: true,
        SUNRAYS_RESOLUTION: 196,
        SUNRAYS_WEIGHT: 1.0,
    };

    const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
    if (!gl) {
        console.error('WebGL not supported');
        return;
    }

    function getWebGLContext() {
        const params = { alpha: true, depth: false, stencil: false, antialias: false, preserveDrawingBuffer: false };
        return canvas.getContext('webgl2', params) || canvas.getContext('webgl', params);
    }

    const ext = {
        formatRGBA: gl.getExtension('EXT_color_buffer_float') || gl.getExtension('WEBGL_color_buffer_float'),
        formatRG: gl.getExtension('EXT_color_buffer_float'),
        formatR: gl.getExtension('EXT_color_buffer_float'),
        halfFloatTexType: gl.HALF_FLOAT || gl.getExtension('OES_texture_half_float').HALF_FLOAT_OES,
        supportLinearFiltering: gl.getExtension('OES_texture_float_linear') || gl.getExtension('OES_texture_half_float_linear')
    };

    function resizeCanvas() {
        const width = window.innerWidth;
        const height = window.innerHeight;
        if (canvas.width !== width || canvas.height !== height) {
            canvas.width = width;
            canvas.height = height;
        }
    }

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    const pointers = [];
    const splatStack = [];

    class Pointer {
        constructor() {
            this.id = -1;
            this.texcoordX = 0;
            this.texcoordY = 0;
            this.prevTexcoordX = 0;
            this.prevTexcoordY = 0;
            this.deltaX = 0;
            this.deltaY = 0;
            this.down = false;
            this.moved = false;
            this.color = [30, 0, 300];
        }
    }

    pointers.push(new Pointer());

    // Shaders
    const baseVertexShader = `
        precision highp float;
        attribute vec2 aPosition;
        varying vec2 vUv;
        varying vec2 vL;
        varying vec2 vR;
        varying vec2 vT;
        varying vec2 vB;
        uniform vec2 texelSize;
        void main () {
            vUv = aPosition * 0.5 + 0.5;
            vL = vUv - vec2(texelSize.x, 0.0);
            vR = vUv + vec2(texelSize.x, 0.0);
            vT = vUv + vec2(0.0, texelSize.y);
            vB = vUv - vec2(0.0, texelSize.y);
            gl_Position = vec4(aPosition, 0.0, 1.0);
        }
    `;

    const displayShaderSource = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        uniform sampler2D uTexture;
        uniform float uOpacity;
        void main () {
            vec3 C = texture2D(uTexture, vUv).rgb;
            float a = max(C.r, max(C.g, C.b));
            gl_FragColor = vec4(C, a * uOpacity);
        }
    `;

    const splatShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        uniform sampler2D uTarget;
        uniform float aspectRatio;
        uniform vec3 color;
        uniform vec2 point;
        uniform float radius;
        void main () {
            vec2 p = vUv - point.xy;
            p.x *= aspectRatio;
            vec3 splat = exp(-dot(p, p) / radius) * color;
            vec3 base = texture2D(uTarget, vUv).xyz;
            gl_FragColor = vec4(base + splat, 1.0);
        }
    `;

    const advectionShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        uniform sampler2D uVelocity;
        uniform sampler2D uSource;
        uniform vec2 texelSize;
        uniform float dt;
        uniform float dissipation;
        void main () {
            vec2 coord = vUv - dt * texture2D(uVelocity, vUv).xy * texelSize;
            gl_FragColor = dissipation * texture2D(uSource, coord);
        }
    `;

    const divergenceShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        varying vec2 vL;
        varying vec2 vR;
        varying vec2 vT;
        varying vec2 vB;
        uniform sampler2D uVelocity;
        void main () {
            float L = texture2D(uVelocity, vL).x;
            float R = texture2D(uVelocity, vR).x;
            float T = texture2D(uVelocity, vT).y;
            float B = texture2D(uVelocity, vB).y;
            float div = 0.5 * (R - L + T - B);
            gl_FragColor = vec4(div, 0.0, 0.0, 1.0);
        }
    `;

    const curlShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        varying vec2 vL;
        varying vec2 vR;
        varying vec2 vT;
        varying vec2 vB;
        uniform sampler2D uVelocity;
        void main () {
            float L = texture2D(uVelocity, vL).y;
            float R = texture2D(uVelocity, vR).y;
            float T = texture2D(uVelocity, vT).x;
            float B = texture2D(uVelocity, vB).x;
            float vorticity = R - L - T + B;
            gl_FragColor = vec4(0.5 * vorticity, 0.0, 0.0, 1.0);
        }
    `;

    const vorticityShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        varying vec2 vL;
        varying vec2 vR;
        varying vec2 vT;
        varying vec2 vB;
        uniform sampler2D uVelocity;
        uniform sampler2D uCurl;
        uniform float curl;
        uniform float dt;
        void main () {
            float L = texture2D(uCurl, vL).x;
            float R = texture2D(uCurl, vR).x;
            float T = texture2D(uCurl, vT).x;
            float B = texture2D(uCurl, vB).x;
            float C = texture2D(uCurl, vUv).x;
            vec2 force = 0.5 * vec2(abs(T) - abs(B), abs(R) - abs(L));
            force /= length(force) + 0.0001;
            force *= curl * C;
            force.y *= -1.0;
            vec2 velocity = texture2D(uVelocity, vUv).xy;
            velocity += force * dt;
            velocity = min(max(velocity, -1000.0), 1000.0);
            gl_FragColor = vec4(velocity, 0.0, 1.0);
        }
    `;

    const pressureShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        varying vec2 vL;
        varying vec2 vR;
        varying vec2 vT;
        varying vec2 vB;
        uniform sampler2D uPressure;
        uniform sampler2D uDivergence;
        void main () {
            float L = texture2D(uPressure, vL).x;
            float R = texture2D(uPressure, vR).x;
            float T = texture2D(uPressure, vT).x;
            float B = texture2D(uPressure, vB).x;
            float C = texture2D(uPressure, vUv).x;
            float divergence = texture2D(uDivergence, vUv).x;
            float pressure = (L + R + B + T - divergence) * 0.25;
            gl_FragColor = vec4(pressure, 0.0, 0.0, 1.0);
        }
    `;

    const gradientSubtractShader = `
        precision highp float;
        precision highp sampler2D;
        varying vec2 vUv;
        varying vec2 vL;
        varying vec2 vR;
        varying vec2 vT;
        varying vec2 vB;
        uniform sampler2D uPressure;
        uniform sampler2D uVelocity;
        void main () {
            float L = texture2D(uPressure, vL).x;
            float R = texture2D(uPressure, vR).x;
            float T = texture2D(uPressure, vT).x;
            float B = texture2D(uPressure, vB).x;
            vec2 velocity = texture2D(uVelocity, vUv).xy;
            velocity.xy -= vec2(R - L, T - B);
            gl_FragColor = vec4(velocity, 0.0, 1.0);
        }
    `;

    function compileShader(type, source) {
        const shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        return shader;
    }

    const programs = {
        display: createProgram(baseVertexShader, displayShaderSource),
        splat: createProgram(baseVertexShader, splatShader),
        advection: createProgram(baseVertexShader, advectionShader),
        divergence: createProgram(baseVertexShader, divergenceShader),
        curl: createProgram(baseVertexShader, curlShader),
        vorticity: createProgram(baseVertexShader, vorticityShader),
        pressure: createProgram(baseVertexShader, pressureShader),
        gradientSubtract: createProgram(baseVertexShader, gradientSubtractShader)
    };

    function createProgram(vertexShader, fragmentShader) {
        const program = gl.createProgram();
        gl.attachShader(program, compileShader(gl.VERTEX_SHADER, vertexShader));
        gl.attachShader(program, compileShader(gl.FRAGMENT_SHADER, fragmentShader));
        gl.linkProgram(program);
        return program;
    }

    // Mouse/Touch events
    canvas.addEventListener('mousemove', e => {
        const pointer = pointers[0];
        pointer.moved = pointer.down;
        pointer.dx = (e.clientX - pointer.x) * 5.0;
        pointer.dy = (e.clientY - pointer.y) * 5.0;
        pointer.x = e.clientX;
        pointer.y = e.clientY;
    });

    canvas.addEventListener('touchmove', e => {
        e.preventDefault();
        const touches = e.targetTouches;
        for (let i = 0; i < touches.length; i++) {
            const pointer = pointers[i];
            pointer.moved = pointer.down;
            pointer.dx = (touches[i].clientX - pointer.x) * 8.0;
            pointer.dy = (touches[i].clientY - pointer.y) * 8.0;
            pointer.x = touches[i].clientX;
            pointer.y = touches[i].clientY;
        }
    }, false);

    // Animation loop
    let lastUpdateTime = Date.now();
    
    function update() {
        const dt = calcDeltaTime();
        if (resizeCanvas()) {
            // Handle resize
        }
        updatePointerDownData();
        updatePointerMoveData();
        
        requestAnimationFrame(update);
    }

    function calcDeltaTime() {
        const now = Date.now();
        let dt = (now - lastUpdateTime) / 1000;
        dt = Math.min(dt, 0.016666);
        lastUpdateTime = now;
        return dt;
    }

    function updatePointerDownData() {
        // Implementation
    }

    function updatePointerMoveData() {
        // Implementation
    }

    update();
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initFluid);
} else {
    initFluid();
}

