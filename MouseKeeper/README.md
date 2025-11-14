Mouse Keeper 🖱️

A lightweight, "set it and forget it" mouse jiggler for Windows that runs in your system tray.

Mouse Keeper prevents your computer from going idle, sleeping, or locking by periodically "jiggling" the mouse cursor by a tiny, unnoticeable amount. It's smart enough to know when you're active and will pause itself, only running when you're idle.

Features

System Tray Icon: Runs quietly in the system tray. No console window.

Smart Inactivity Check: Only jiggles the mouse after a set period of user inactivity.

Live Visual Feedback: The tray icon changes color to show its current state:

Red Dot: Paused. The user is active, so the jiggler is paused.

White "M" (no dot): Idle. The user is inactive, and the countdown timer is running.

Green Dot (flashing): Jiggling. The inactivity threshold was met, and the script is moving the mouse.

Configurable Interval: Set the inactivity period (5, 10, 30, or 60 seconds) directly from a sub-menu.

Automatic Startup: On first run, it creates a silent shortcut in the Windows Startup folder.

Advanced Logging Menu:

Enable/Disable Logging: Turn logging on or off from the tray.

View Log: Instantly open the log file (stored in your system's Temp folder).

Open Log Folder: Open the log file's containing folder.

How to Use (Recommended Method)

The easiest way to use Mouse Keeper is to compile it into a single .exe file. This lets you run it on any Windows computer without needing to install Python.

1. Compile the .exe

You only need to do this once.

Install Python: If you don't have it, get it from python.org.

Open a Terminal (CMD or PowerShell).

Install Dependencies:

pip install pyautogui pystray winshell pillow pyinstaller


Run PyInstaller: Navigate to your project folder and run:

pyinstaller --onefile --windowed mouse_keeper.py


--onefile: Bundles everything into a single .exe.

--windowed: Ensures no console window appears.

Your standalone mouse_keeper.exe will be in the dist folder.

2. Run the .exe

Move mouse_keeper.exe from the dist folder to anywhere you like (e.g., your Desktop).

Right-click mouse_keeper.exe and select "Run as administrator".

IMPORTANT: You only need to do this one time. This gives the app permission to create its shortcut in your Windows Startup folder.

That's it! The app is now running and will launch automatically every time you boot your computer.

How to Use (as a Python Script)

1. Create a Virtual Environment

It is best practice to create a separate Python environment for each project.

# In your project folder, create the environment
python -m venv .venv

# Activate the environment
.venv\Scripts\activate


2. Install Dependencies

With your virtual environment active, run:

pip install pyautogui pystray winshell pillow


3. Run the Script

To run the script silently (without a console window), use pythonw.exe:

pythonw.exe mouse_keeper.py
