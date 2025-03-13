import { useState, useRef, useEffect } from "react";
import "./App.css";

const uuid = require("uuid");

function App() {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const [isRecording, setIsRecording] = useState(false);
  const [uploadResultMessage, setUploadResultMessage] = useState(
    "Please allow camera access to begin"
  );
  const [visitorName, setVisitorName] = useState("placeholder.jpg");
  const [isAuth, setAuth] = useState(false);
  const [stream, setStream] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  // Initialize webcam when component mounts
  useEffect(() => {
    initializeCamera();

    // Cleanup function to stop the camera when component unmounts
    return () => {
      if (stream) {
        stream.getTracks().forEach((track) => track.stop());
      }
    };
  }, []);

  async function initializeCamera() {
    try {
      const videoStream = await navigator.mediaDevices.getUserMedia({
        video: true,
        audio: false,
      });

      if (videoRef.current) {
        videoRef.current.srcObject = videoStream;
      }

      setStream(videoStream);
      setUploadResultMessage(
        "Camera ready. Click 'Authenticate' to verify your identity"
      );
    } catch (error) {
      console.error("Error accessing camera:", error);
      setUploadResultMessage(
        "Failed to access camera. Please ensure camera permissions are granted."
      );
    }
  }

  function captureAndSendFrame() {
    if (!videoRef.current || !canvasRef.current) return;

    const canvas = canvasRef.current;
    const video = videoRef.current;

    // Set canvas dimensions to match video
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    // Draw current video frame to canvas
    const context = canvas.getContext("2d");
    context.drawImage(video, 0, 0, canvas.width, canvas.height);

    // Convert canvas to blob (JPEG format)
    canvas.toBlob(
      (blob) => {
        if (blob) {
          sendFrameForAuthentication(blob);
        }
      },
      "image/jpeg",
      0.9
    );
  }

  function sendFrameForAuthentication(frameBlob) {
    setIsLoading(true);
    setUploadResultMessage("Authenticating...");
    const visitorImageName = uuid.v4();

    fetch(
      `https://gpofirxou8.execute-api.us-east-1.amazonaws.com/DEV/visitor-images-storage-rk1/${visitorImageName}.jpeg`,
      {
        method: "PUT",
        headers: {
          "Content-Type": "image/jpeg",
        },
        body: frameBlob,
      }
    )
      .then(async () => {
        const response = await authenticate(visitorImageName);
        if (response.Message === "Success") {
          setAuth(true);
          setVisitorName(visitorImageName);
          setUploadResultMessage(
            `Hi ${response["firstName"]} ${response["lastName"]}, welcome to work`
          );
        } else {
          setAuth(false);
          setUploadResultMessage(`Authentication Failed`);
        }
        setIsLoading(false);
      })
      .catch((error) => {
        setAuth(false);
        setUploadResultMessage(
          `There is an error in authentication process, try again later.`
        );
        console.error(error);
        setIsLoading(false);
      });
  }

  async function authenticate(visitorImageName) {
    const requestUrl =
      "https://gpofirxou8.execute-api.us-east-1.amazonaws.com/DEV/employee?" +
      new URLSearchParams({
        objectKey: `${visitorImageName}.jpeg`,
      }).toString();

    return await fetch(requestUrl, {
      method: "GET",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        return data;
      })
      .catch((error) => console.error(error));
  }

  function handleAuthenticate() {
    if (!stream) {
      initializeCamera();
      return;
    }

    captureAndSendFrame();
  }

  return (
    <div className="App">
      <div className="auth-container">
        <div className="header">
          <h1>FACIAL RECOGNITION</h1>
          <p className="subtitle">Secure Authentication System</p>
        </div>

        <div className="video-frame">
          <div className="video-overlay">
            <div className="corner top-left"></div>
            <div className="corner top-right"></div>
            <div className="corner bottom-left"></div>
            <div className="corner bottom-right"></div>

            {isLoading && (
              <div className="scanning-animation">
                <div className="scan-line"></div>
              </div>
            )}
          </div>

          <video ref={videoRef} autoPlay playsInline muted />

          {/* Hidden canvas for processing frames */}
          <canvas ref={canvasRef} style={{ display: "none" }} />
        </div>

        <div className={isAuth ? "success message-box" : "failure message-box"}>
          {uploadResultMessage}
        </div>

        <button
          className={`auth-button ${isLoading ? "loading" : ""}`}
          onClick={handleAuthenticate}
          disabled={isLoading}
        >
          {isLoading ? "Authenticating..." : "Authenticate"}
        </button>

        {isAuth && (
          <div className="access-granted">
            <div className="checkmark">✓</div>
            <p>Access Granted</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
