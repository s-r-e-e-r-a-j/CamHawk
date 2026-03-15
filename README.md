## CamHawk
Advanced Camera Phishing Tool

CamHawk is a camera phishing tool that tricks users into granting webcam access. Once permission is granted, the tool captures images from the webcam and sends them to your machine.

CamHawk uses **JavaScript** for the server-side functionality and **Bash scripting** for automation. It also supports multiple tunneling options for port forwarding.

## Security Research & Educational Purpose

CamHawk was created for **security research, penetration testing, and educational purposes**. It demonstrates how attackers can exploit browser permission systems and social engineering techniques to gain webcam access.

Understanding these techniques helps **developers, cybersecurity students, and security professionals** learn how such attacks work and how to design stronger defenses against them.

## ⚠️ DISCLAIMER

CamHawk is developed for **educational purposes, ethical hacking demonstrations, and authorized security research only**. It is intended to help security professionals and researchers understand camera phishing risks so they can improve defenses.

**Unauthorized use is illegal and may result in criminal or civil penalties.**

By using this tool, you agree that:

- You will use it **only on devices or systems you own** or have **explicit written permission** to test.
- You will comply with **all applicable laws** related to privacy, surveillance, and computer access.
- You are **fully responsible** for how you use this tool and for any data you collect.
- This software is provided **“as is”**, without warranties of any kind.
- The developer **assumes no liability** for misuse, damages, or legal consequences.

If you do not agree with these terms, **do not use this software**.

##  Features

- **Real-time Photo Capture** – Instantly saves images as soon as the target grants access.

- **Multiple Port Forwarding Options** – Choose between `Serveo.net`, `Cloudflared`, or `Localhost` for manual/external tunneling.

- **Live Terminal Updates** – Displays "Photo Received!" along with the target’s IP address when an image is captured.

- **Automated Dependency Installation** – Installs Node.js, Express.js, npm, SSH, and Cloudflared if missing.

- **User-Friendly Bash Script** – Easily start, stop, and manage the server with a simple command.

- **Automatic Cloudflared Setup** – Ensures Cloudflared is installed and configures it for tunneling.

- **Custom HTML Support** – Allows users to provide their own phishing page with full customization. Supports internal CSS and embedded JavaScript

##  Installation
**What You Need:**

- **Linux (Debian, RHEL, Arch**) (`Kali, Parrot, Ubuntu, Black Arch, Fedora, etc`.)
- **npm** (required for install `express.js`. if it is not installed it will automatically install `npm`)
- **Node.js and expressjs** ( In linux distributions like `Debian`,`RHEL`, `Arch` it automatically install `nodejs` and `expressjs` if it is not installed)
- **Port Forwarding Options:**

  - **Serveo.net** – Used as the default option for tunneling.

  - **Cloudflared** – Available as an alternative for port forwarding and automatically installed if missing.

  - **Localhost Mode** – Runs the server locally and displays the running port, allowing users to use their own VPS or external tunneling services (e.g., Ngrok, SSH tunnels, etc.).
  
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
1. **Run the tool**:

```bash
bash camhawk.sh
```
**OR**

```bash
chmod +x camhawk.sh
./camhawk.sh
```

2. **Choose a custom HTML page** – Optionally, provide your own phishing page with internal JavaScript and CSS support for a fully customized experience. Or, skip this step to use the default page.

3. **Choose a port forwarding method** – Select between `Serveo.net`, `Cloudflared`, or `Localhost` mode for manual/external tunneling.

4. **Share the generated link with the target**.

5. **Once they open the link and grant permission, their camera is activated and images are saved automatically**.

6. **Captured images are stored in the `capture/` folder.**

## License

This project is licensed under the MIT License.
