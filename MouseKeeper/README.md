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


The script will start, add itself to your startup, and the tray icon will appear.

Full Python Script

This is the complete source code for the application.

import os
import sys
import threading
import time
import pyautogui
from PIL import Image, ImageDraw
import pystray
import logging
from logging.handlers import RotatingFileHandler
import tempfile # Added import
import webbrowser # Added import

# --- 1. Logging Setup ---

# This flag controls logging globally
g_logging_enabled = True

try:
    # Get the system's temporary folder path
    temp_dir = tempfile.gettempdir()
    # Create a sub-folder for our app to keep things clean
    app_log_dir = os.path.join(temp_dir, "MouseKeeper")
    
    # Ensure the directory exists
    if not os.path.exists(app_log_dir):
        os.makedirs(app_log_dir)
        
    LOG_FILE_PATH = os.path.join(app_log_dir, "MouseKeeper.log")
    
except Exception:
    # Fallback to the original location just in case
    try:
        script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    except Exception:
        script_dir = os.path.abspath(os.getcwd())
    LOG_FILE_PATH = os.path.join(script_dir, "MouseKeeper.log")


# Configure the logger
logger = logging.getLogger("MouseKeeper")
logger.setLevel(logging.DEBUG) 

# Create a rotating file handler: Max 2MB, 1 backup file
handler = RotatingFileHandler(
    LOG_FILE_PATH, maxBytes=2*1024*1024, backupCount=1
)
formatter = logging.Formatter(
    '%(asctime)s - %(levelname)s - (%(threadName)s) - %(message)s'
)
handler.setFormatter(formatter)

if logger.hasHandlers():
    logger.handlers.clear()
    
logger.addHandler(handler)

# --- New: Wrapper functions for logging ---
def log_info(message):
    if g_logging_enabled:
        logger.info(message)

def log_debug(message):
    if g_logging_enabled:
        logger.debug(message)

def log_warning(message):
    if g_logging_enabled:
        logger.warning(message)

def log_error(message, exc_info=False):
    if g_logging_enabled:
        logger.error(message, exc_info=exc_info)
# --- End new functions ---

log_info("--- MouseKeeper Started ---")

# --- End Logging Setup ---

try:
    import winshell
except ImportError:
    log_warning("'winshell' library not found. Startup feature will be disabled.")
    log_warning("Please install it: pip install winshell")
    winshell = None


class MouseMover:
    def __init__(self, icon_idle, icon_active, icon_paused):
        self.running = False
        self.thread = None
        self.last_position = pyautogui.position()
        self.last_user_activity = time.time()
        
        self.inactivity_threshold = 60 # Default: 60 seconds
        
        # --- State for Logging/Icons ---
        self.user_is_active_state = True 
        
        # --- Icon Resources ---
        self.icon_idle = icon_idle
        self.icon_active = icon_active
        self.icon_paused = icon_paused # New icon for paused state
        self.icon_object = None 

    def set_icon_object(self, icon):
        self.icon_object = icon

    def start(self):
        if not self.running:
            self.running = True
            self.thread = threading.Thread(
                target=self._run, 
                daemon=True, 
                name="MoverThread"
            )
            self.thread.start()
            log_info("MouseMover Thread started.")
            self._set_icon_paused() # Start in paused state (user is active)

    def stop(self):
        if self.running:
            self.running = False
            if self.thread:
                self.thread.join(timeout=1.0)
            log_info("MouseMover Thread stopped.")

    # --- New method to change interval ---
    def set_interval(self, seconds):
        log_info(f"Changing inactivity threshold to {seconds} seconds.")
        self.inactivity_threshold = seconds
        # Reset activity timer to apply new interval immediately
        self.last_user_activity = time.time()
        self.user_is_active_state = True # Assume user is active
        self._set_icon_paused()
        
    def _flash_icon_active(self):
        """Jiggling - Flashes Green"""
        if self.icon_object:
            log_debug("Flashing icon to 'active' (green)")
            self.icon_object.icon = self.icon_active
            # After 2s, go back to IDLE (white M), NOT paused
            threading.Timer(2.0, self._set_icon_idle).start()

    def _set_icon_idle(self):
        """Idle - White M"""
        if self.icon_object and not self.user_is_active_state:
            log_debug("Setting icon to 'idle' (white M)")
            self.icon_object.icon = self.icon_idle

    def _set_icon_paused(self):
        """Paused - Red Dot"""
        if self.icon_object and self.user_is_active_state:
            log_debug("Setting icon to 'paused' (red dot)")
            self.icon_object.icon = self.icon_paused

    def _run(self):
        """Main loop for the mouse mover thread with enhanced logging."""
        log_debug(f"MoverThread running. Initial threshold: {self.inactivity_threshold}s")
        
        while self.running:
            try:
                current_position = pyautogui.position()
                
                # 1. Check if user is currently active
                if current_position != self.last_position:
                    self.last_user_activity = time.time()
                    self.last_position = current_position
                    
                    if not self.user_is_active_state:
                        # This is the FIRST movement after being idle
                        log_info("User activity detected. Pausing jiggler.")
                        self.user_is_active_state = True
                        self._set_icon_paused() # Set to Paused (red)
                    else:
                        log_debug("User continues to be active.")

                # 2. Check if user has been idle long enough to jiggle
                elif (time.time() - self.last_user_activity) > self.inactivity_threshold:
                    log_info(f"User has been inactive for {self.inactivity_threshold}s. Jiggling mouse.")
                    self._flash_icon_active() # Flash Green
                    
                    pyautogui.moveRel(1, 0, duration=0.1)
                    pyautogui.moveRel(-1, 0, duration=0.1)
                    
                    self.last_user_activity = time.time()
                    self.last_position = pyautogui.position()
                    self.user_is_active_state = False # Still idle
                    # Note: _flash_icon_active sets timer to call _set_icon_idle
                
                # 3. User is idle, but not long enough to jiggle
                else:
                    if self.user_is_active_state:
                        # This is the FIRST check after user stopped moving
                        log_info("User has gone idle. Starting inactivity timer...")
                        self.user_is_active_state = False
                        self._set_icon_idle() # Set to Idle (white)
                        
                    time_since_active = time.time() - self.last_user_activity
                    log_debug(f"User idle for {time_since_active:.0f}s. Waiting for threshold...")

            except Exception as e:
                log_error(f"Mouse move failed: {e}")
            
            # Check every 10 seconds
            time.sleep(10)


def create_icon_idle():
    """Idle (White M): User is idle, timer counting down."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.line((12, 52, 12, 12), fill="white", width=8)
    draw.line((12, 12, 32, 32), fill="white", width=8)
    draw.line((32, 32, 52, 12), fill="white", width=8)
    draw.line((52, 12, 52, 52), fill="white", width=8)
    return img

def create_icon_active():
    """Active (Green Dot): Jiggler is moving the mouse."""
    img = create_icon_idle()
    draw = ImageDraw.Draw(img)
    draw.ellipse((40, 4, 60, 24), fill="green", outline="white")
    return img

def create_icon_paused():
    """Paused (Red Dot): User is active, jiggler is paused."""
    img = create_icon_idle()
    draw = ImageDraw.Draw(img)
    draw.ellipse((40, 4, 60, 24), fill="red", outline="white") # Changed to red
    return img


def add_to_startup_windows():
    if not winshell or os.name != 'nt':
        if os.name != 'nt':
            log_warning("Startup feature is only supported on Windows.")
        return
    
    try:
        startup_dir = winshell.startup()
        shortcut_path = os.path.join(startup_dir, "MouseKeeper.lnk")
        log_debug(f"Checking for startup shortcut at: {shortcut_path}")

        # --- This logic is now fixed for EXE vs PY ---
        is_frozen = getattr(sys, 'frozen', False)
        
        if is_frozen:
            # We are running as a compiled EXE
            target = os.path.abspath(sys.argv[0]) # This IS the exe
            arguments = ""
            icon_path = target
            log_debug("Running as a compiled EXE.")
        
        else:
            # We are running as a .py script
            target = sys.executable # This is python.exe
            arguments = f'"{os.path.abspath(sys.argv[0])}"' # This is mouse_keeper.py
            icon_path = target
            log_debug("Running as a .py script.")

            # Try to use pythonw.exe for silent startup
            if target.lower().endswith("python.exe"):
                pythonw_path = target.lower().replace("python.exe", "pythonw.exe")
                if os.path.exists(pythonw_path):
                    log_debug("Using 'pythonw.exe' for silent startup.")
                    target = pythonw_path
                    icon_path = target
                else:
                    log_warning("'pythonw.exe' not found, using 'python.exe'.")
        
        # --- End of new logic ---

        if not os.path.exists(shortcut_path):
            log_info(f"Creating shortcut:")
            log_info(f"  Target: {target}")
            log_info(f"  Arguments: {arguments}")
            winshell.CreateShortcut(
                Path=shortcut_path,
                Target=target,
                Arguments=arguments,
                Description="Mouse Keeper - Prevents system sleep",
                Icon=(icon_path, 0)
            )
            log_info(f"Mouse Keeper added to Startup: {shortcut_path}")
        else:
            log_info("Mouse Keeper already in Startup.")
            
    except Exception as e:
        log_error(f"Could not add to Startup: {e}", exc_info=True)


# --- Pystray Menu Functions ---

icon_idle = create_icon_idle()
icon_active = create_icon_active()
icon_paused = create_icon_paused() # New paused icon
mover = MouseMover(icon_idle, icon_active, icon_paused)

# --- New functions for interval menu ---
def on_set_interval(icon, item):
    """Called when a user clicks an interval."""
    interval_seconds = item.value
    mover.set_interval(interval_seconds)
    icon.update_menu()

def is_interval_checked(item):
    """Used to show radio checkmark for intervals."""
    return mover.inactivity_threshold == item.value

# --- End new interval functions ---

# --- New functions for logging menu ---
def on_toggle_logging(icon, item):
    """Enables or disables logging."""
    global g_logging_enabled
    g_logging_enabled = not g_logging_enabled
    if g_logging_enabled:
        log_info("Logging has been ENABLED.")
    else:
        # We must log this *before* disabling
        logger.info("Logging has been DISABLED.")
    icon.update_menu()

def is_logging_enabled(item):
    """Used to show checkmark for logging."""
    return g_logging_enabled

def on_open_log_folder(icon, item):
    """Opens the folder containing the log file."""
    log_info("User selected 'Open Log Folder' from menu.")
    try:
        # Open the *directory* containing the log file
        webbrowser.open(os.path.dirname(LOG_FILE_PATH))
    except Exception as e:
        log_error(f"Could not open log folder: {e}", exc_info=True)
# --- End new logging functions ---


def is_mover_running(item):
    return mover.running

def on_toggle_move(icon, item):
    if mover.running:
        log_info("User selected 'Stop Moving' from menu.")
        mover.stop()
    else:
        log_info("User selected 'Start Moving' from menu.")
        mover.start()
    icon.update_menu()

def on_view_log(icon, item):
    log_info("User selected 'View Log' from menu.")
    try:
        os.startfile(LOG_FILE_PATH)
    except Exception as e:
        log_error(f"Could not open log file: {e}", exc_info=True)
        try:
            webbrowser.open(LOG_FILE_PATH)
        except Exception as e2:
            log_error(f"Fallback webbrowser.open also failed: {e2}", exc_info=True)

def on_exit(icon, item):
    log_info("User selected 'Exit' from menu.")
    log_info("--- Stopping MouseKeeper ---")
    mover.stop()
    icon.stop()

def get_menu_items():
    """Dynamically generate the menu items."""
    toggle_text = "Stop Moving" if mover.running else "Start Moving"
    
    yield pystray.MenuItem(
        toggle_text, 
        on_toggle_move, 
        checked=is_mover_running
    )
    
    # --- Create the new interval sub-menu ---
    item_5 = pystray.MenuItem(
        "5 Seconds",
        on_set_interval,
        checked=is_interval_checked,
        radio=True
    )
    item_5.value = 5

    item_10 = pystray.MenuItem(
        "10 Seconds",
        on_set_interval,
        checked=is_interval_checked,
        radio=True
    )
    item_10.value = 10

    item_30 = pystray.MenuItem(
        "30 Seconds",
        on_set_interval,
        checked=is_interval_checked,
        radio=True
    )
    item_30.value = 30

    item_60 = pystray.MenuItem(
        "1 Minute (60s)",
        on_set_interval,
        checked=is_interval_checked,
        radio=True
    )
    item_60.value = 60

    interval_menu = pystray.Menu(
        item_5,
        item_10,
        item_30,
        item_60
    )
    yield pystray.MenuItem("Set Interval", interval_menu)
    # --- End new sub-menu ---
    
    yield pystray.Menu.SEPARATOR 
    
    # --- New Logging Sub-Menu ---
    logging_menu = pystray.Menu(
        pystray.MenuItem(
            "Enable Logging",
            on_toggle_logging,
            checked=is_logging_enabled,
            radio=True
        ),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem(
            "View Current Log",
            on_view_log
        ),
        pystray.MenuItem(
            "Open Log Folder",
            on_open_log_folder
        )
    )
    yield pystray.MenuItem("Logging", logging_menu)
    # --- End new sub-menu ---

    yield pystray.MenuItem("Exit", on_exit)

def main():
    add_to_startup_windows()
    
    # Start with the paused icon
    icon = pystray.Icon(
        "MouseKeeper",
        icon_paused, 
        "Mouse Keeper - Keeping you active!",
        menu=pystray.Menu(get_menu_items),
    )
    
    mover.set_icon_object(icon)
    mover.start() 
    
    log_info("Starting system tray icon.")
    icon.run()


if __name__ == "__main__":
    threading.current_thread().name = "MainThread"
    try:
        main()
    except Exception as e:
        log_error(f"Unhandled exception in main: {e}", exc_info=True)
        sys.exit(1)


VS Code Setup (Optional)

If you want to debug or develop the script, create a .vscode folder in your project directory and add these files.

.vscode/launch.json

(This configures the F5 "Debug" button).

{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug MouseKeeper",
      "type": "python",
      "request": "launch",
      "program": "${workspaceFolder}/mouse_keeper.py",
      "console": "integratedTerminal",
      "justMyCode": true
    }
  ]
}


.vscode/settings.json

(This configures your VS Code workspace).

{
  // --- Python Configuration ---
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/Scripts/python.exe", // Windows

  // --- Formatting & Linting (Best Practice) ---
  // Run 'pip install black flake8 debugpy' to use these.
  "python.formatting.provider": "black",
  "python.linting.flake8Enabled": true,
  "python.linting.enabled": true,
  "editor.formatOnSave": true,

  // --- File/Folder Settings ---
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true,
    "**/CVS": true,
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/__pycache__": true,
    "**/.venv": true,
    "**/build": true,
    "**/dist": true,
    "**/*.spec": true
  },

  // Make sure .log files are treated as plain text
  "files.associations": {
    "MouseKeeper.log": "plaintext"
  }
}
