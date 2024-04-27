# Helldivers 2 IPv6 Auto Toggle
This script will toggle IPv6 automatically when you launch Helldivers 2 through the provided shortcut.

### The Helldivers 2 IPv6 problem
As of the time of writing (April 2024) Helldivers 2 does not seem to play nicely with IPv6 at all and in fact completely removes the ability to play for a lot of players (including myself). It is unclear exactly why; however I have also encountered issues where If I launch the game and try to play with IPv6 enabled, I can't even play after disabling IPv6 again until I verify the integrity of the game files.

### Instructions
1. **On your first run only**, verify the integrity of the Helldivers 2 game files and close Steam (exit Steam not just minimise)
2. **On your first run only**, clone or manually download a copy of this repo and store it somewhere safe.
3. **On your first run only**, run **First run.bat** as Administrator.
4. When launching the game in future, simply use the **HELLDIVERS™ 2 (IPv4)** shortcut on your desktop

N.B - If you need to recreate the shortcut (e.g. if you move the location of the script) simply go back to step 3 to re-create the shortcut.

### What does this script do?
1. On your first run, providing you use the included bat file or manually pass the `-firstRun` switch, it will create a shortcut to this script on your desktop. The shortcut will be set to run the script (and launch the game) as Administrator with `-ExecutionPolicy Bypass`. Administrative access is required to toggle IPv6 on your network adapter.
2. It will then search for an active network adapter; The script will only run if it locates exactly **one active** network adapter.
3. IPv6 is disabled on the active network adapter.
4. Helldivers 2 is launched through Steam `steam://rungameid/553850`.
5. The script will then wait for the game to launch. If it fails to detect the game launch after a set time, then IPv6 will be re-enabled.
6. Once the script finds the Helldivers 2 process it will wait for you to close the game.
7. When the game is closed the script will re-enable IPv6 on your network adapter.
