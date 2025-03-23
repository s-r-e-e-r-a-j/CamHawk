## CamHawk 
Advanced Camera Phishing Tool using Serveo.net & Cloudflared for Port Forwarding

CamHawk is a camera phishing tool that tricks users into granting webcam access, captures their images, and sends them to your machine. It uses JavaScript for the server, Bash scripting for automation, and now supports multiple tunneling options for port forwarding.
## ⚠️ Disclaimer
CamHawk is made for ethical hacking and security research. Do not use it for illegal activities. The developer is not responsible for any misuse

##  Features

✔ Real-time Photo Capture – Instantly saves images as soon as the target grants access.

✔ Multiple Port Forwarding Options – Choose between Serveo.net and Cloudflared for tunneling.

✔ Live Terminal Updates – Displays "Photo Received!" along with the target’s IP address when an image is captured.

✔ Automated Dependency Installation – Installs Node.js, Express.js, npm, SSH, and Cloudflared if missing.

✔ User-Friendly Bash Script – Easily start, stop, and manage the server with a simple command.

✔ Automatic Cloudflared Setup – Ensures Cloudflared is installed and configures it for tunneling.

✔ Custom HTML Support – Allows users to provide their own phishing page without external <script src="script.js"></script>. JavaScript will be directly embedded in the HTML, and internal CSS is fully supported.

##  Installation
**What You Need:**

- **Linux** (`Kali, Parrot, Ubuntu, etc`.)
- **npm** (required for install `express.js`. if it is not installed it will automatically install `npm`)
- **Node.js and expressjs** ( In linux distributions like `kalilinux`,`parrot os` etc.. it automatically install `nodejs` and `expressjs` if it is not installed)
- **Port Forwarding Options:**
- **Serveo.net** – Used as the default option for tunneling
- **Cloudflared** – Available as an alternative for port forwarding and is automatically installed if missing.
  
**Steps to Install:**
1. **Clone the repository**
```bash
git clone https://github.com/s-r-e-e-r-a-j/CamHawk.git
```
2. **Navigate to the CamHawk directory**
```bash  
cd CamHawk
```
3. **Navigate to the CamHawk directory**
```bash
cd CamHawk
```
4. **Start the tool**
```bash   
bash camhawk.sh
```

##  How to Use
1️⃣ Run the tool:

```bash
bash camhawk.sh
```
2️⃣ Choose a custom HTML page – Optionally, provide your own phishing page with internal JavaScript and CSS support for a personalized experience.

3️⃣ Choose a port forwarding method – Select between Serveo.net or Cloudflared for tunneling.

4️⃣ Share the generated link with the target.

5️⃣ Once they open the link, their camera activates, and images are saved automatically.

6️⃣ Captured images are stored in the capture/ folder.

## License

This project is licensed under the MIT License.
