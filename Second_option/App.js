import { useState } from "react";
import { v4 as uuidv4 } from "uuid";
import "./App.css";

function App() {
  const [image, setImage] = useState(null);
  const [uploadResultMessage, setUploadResultMessage] = useState(
    "Please enter an image to authenticate"
  );
  const [visitorName, setVisitorName] = useState("placeholder.jpg");
  const [isAuth, setAuth] = useState(false);
  const [preview, setPreview] = useState(null);

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    setImage(file);
    setPreview(URL.createObjectURL(file));
  };

  async function sendImage(e) {
    e.preventDefault();

    if (!image) {
      setUploadResultMessage("Please select an image first!");
      return;
    }

    setVisitorName(image.name);
    const visitorImageName = uuidv4();

    try {
      const uploadUrl = `https://ch6fdqle8k.execute-api.us-east-1.amazonaws.com/DEV/visitor-images-storage-rk1/${visitorImageName}.jpeg`;

      await fetch(uploadUrl, {
        method: "PUT",
        headers: { "Content-Type": "image/jpeg" },
        body: image,
      });

      const response = await authenticate(visitorImageName);

      if (response?.Message === "Success") {
        setAuth(true);
        setUploadResultMessage(
          `Hi ${response.firstName} ${response.lastName}, welcome to work!`
        );
      } else {
        setAuth(false);
        setUploadResultMessage("Authentication Failed");
      }
    } catch (error) {
      setAuth(false);
      setUploadResultMessage(
        "There is an error in the authentication process, try again later."
      );
      console.error("Error during authentication:", error);
    }
  }

  async function authenticate(visitorImageName) {
    const requestUrl = `https://ch6fdqle8k.execute-api.us-east-1.amazonaws.com/DEV/employee?objectKey=${visitorImageName}.jpeg`;

    try {
      const response = await fetch(requestUrl, {
        method: "GET",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      });

      return response.json();
    } catch (error) {
      console.error("Error fetching authentication response:", error);
      return null;
    }
  }

  return (
    <div className="App">
      <h2>FACIAL RECOGNITION SYSTEM</h2>

      <form onSubmit={sendImage}>
        <input
          type="file"
          name="image"
          accept="image/*"
          onChange={handleImageChange}
        />
        <button type="submit">Authenticate</button>
      </form>

      <div className={isAuth ? "success" : "failure"}>
        {uploadResultMessage}
      </div>

      {preview && (
        <img src={preview} alt="Visitor Preview" className="visitor-image" />
      )}
    </div>
  );
}

export default App;
