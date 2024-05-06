# Helldivers 2 IPv6 Auto Toggle
This script will automatically toggle IPv6 on and off for you when you want to play Helldivers 2. It'll also create a handy shortcut on your desktop.

**Update 04/05/2024**

I have resolved this issue within my Mikrotik router by increasing my vlan101 (PPPoE client interface) MTU from 1500 to 1508 and setting the Max MTU / MRU to 1500 on the PPPoE client itself. I now have an "actual" MTU of 1500 on my PPPoE client instead of 1492 which allows me to play Helldivers without issue.

## The Helldivers 2 IPv6 problem
As of the time of writing (April 2024) Helldivers 2 does not seem to play nicely with IPv6 at all and in fact completely removes the ability to play for a lot of players (including myself). It is unclear exactly why; however I have also encountered issues where If I launch the game and try to play with IPv6 enabled, I can't even play after disabling IPv6 again until I verify the integrity of the game files.

## Instructions
#### On your first run only:
1. Verify the integrity of the Helldivers 2 game files and close Steam (exit Steam not just minimise).
1. Clone or manually download a copy of this repo and store it somewhere safe.
1. Run **First run.bat** as Administrator.

#### After the first run:
Simply use the **HELLDIVERS™ 2 (IPv4)** shortcut on your desktop.

#### Re-creating the shortcut
If you need to recreate the shortcut (e.g. if you've moved the location of the script) simply go back to step 3 and the shortcut will be re-generated.