class Cv2Camera {
  constructor() {
    this.module = null;
    this.cvReady = false;
    this.cameraReady = false;
  }

  async init() {
    // Load OpenCV.js
    await this._loadOpenCV();
    
    // Load our WASM module
    this.module = await this._loadWasmModule();
    
    // Initialize OpenCV
    await this.module.initOpenCV();
  }

  _loadOpenCV() {
    return new Promise((resolve, reject) => {
      if (typeof cv !== 'undefined' && cv.getBuildInformation) {
        this.cvReady = true;
        return resolve();
      }

      const script = document.createElement('script');
      script.src = 'assets/packages/flutter_cv2_camera/web/opencv/opencv.js';
      script.onload = () => {
        cv.onRuntimeInitialized = () => {
          this.cvReady = true;
          resolve();
        };
      };
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  _loadWasmModule() {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = 'assets/packages/flutter_cv2_camera/web/flutter_cv2_camera.js';
      script.onload = () => {
        createModule().then(module => {
          // Set up callbacks
          module.onOpenCVReady = () => {
            module._onOpenCVReady();
            resolve(module);
          };
          module.onCameraStarted = (stream) => module._onCameraStarted(stream);
          module.onCameraError = (err) => module._onCameraError(err);
          resolve(module);
        });
      };
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  startCamera(width, height, cameraIndex) {
    return this.module._startCamera(width, height, cameraIndex);
  }

  stopCamera() {
    return this.module._stopCamera();
  }

  getFrame() {
    return this.module._getFrame();
  }

  setResolution(width, height) {
    return this.module._setResolution(width, height);
  }

  switchCamera(index) {
    return this.module._switchCamera(index);
  }

  setFlipCode(code) {
    return this.module._setFlipCode(code);
  }
}

// Initialize and expose globally
window.cv2Camera = new Cv2Camera();
window.initCv2Camera = async function() {
  await window.cv2Camera.init();
  return true;
};