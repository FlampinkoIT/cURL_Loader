Simple Batch File to load or update cURL on Windows.

Usage:

Simple double click the cURL_Loader.bat file and let it do its magic.
(only downloads curl into the same directory.)

Use in CMD Window or Powershell:
just call the cURL_Loader.bat file or add some Switches.

Switches: /i /f /d""

/i install cURL to System
use with /d else it will only downloaded to actual dir of this batch.

/f Force update
Downloads curl and ignore local and system version number

/d "full\path\for\installing\curl\"
e.g. "C:\Programms\curl\"
