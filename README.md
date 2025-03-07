## CamHawk 
Advanced Camera Phishing Tool using Serveo.net for Port Forwarding

CamHawk is a camera phishing tool that tricks users into granting webcam access, captures their images, and sends them to your machine. It uses JavaScript for the server, Bash scripting for automation, and Serveo.net for port forwarding.

## ⚠️ Disclaimer
CamHawk is made for ethical hacking and security research. Do not use it for illegal activities. The developer is not responsible for any misuse

##  Features
✔ Automatic Camera Access – No button clicks required.

✔ Real-time Photo Capture – Saves images instantly upon access.

✔ Serveo.net Port Forwarding – No manual setup needed.

✔ Live Terminal Updates – Displays "Photo Received!" when an image is captured.

✔ User-Friendly Bash Script – Easily start, stop, and manage the server.


##  Installation
**What You Need:**

- **Linux** (`Kali, Parrot, Ubuntu, etc`.)
- **npm** (required for install `expressjs`. if it is not installed it will automatically install `npm`)
- **Node.js and expressjs** ( In linux distributions like `kalilinux`,`parrot os` etc.. it automatically install `nodejs` and `expressjs` if it is not installed)
- **Serveo.net** (Automatically used for port forwarding)
  
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
2️⃣ It will automatically set up Serveo.net for port forwarding.

3️⃣ Share the generated link with the target.

4️⃣ Once they open the link, their camera activates, and images are saved automatically.

5️⃣ Captured images are stored in the capture/ folder.

## License

This project is licensed under the MIT License.
