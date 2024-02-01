PamPam
=================================================================

Intro
----------------------------

It's portable text-based server stack for web development on windows

Features
----------------------------

1. Portable
2. Text-Based
3. Version Switching
4. Auto Virtual Host

## Require

1. Microsoft Visual C++ Redistributable, both x86 and x64 versions
   
   https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

2. The ports `80` `443` `3306` free
   
   Check at Resource Monitor → Network → Listening Ports

Install & Run
----------------------------

1. Download the stack. Then extract it into anywhere
2. Run `board.ps1` and follow the instructions
3. Browse http://test.dev.win or https://test.dev.win 

## Portable

You can move it around. Then it still run normally

## Text-Based

All files are plain text. So they're understandable and modificable 

## Version Switching

You can add more package versions, so you can switch between versions

1. Download zip versions into folder of the stack. Don't extract them
   
   - Apache: https://www.apachelounge.com/download
   
   - MariaDB: https://mariadb.org/download
   
   - PHP: https://windows.php.net/downloads/releases

2. Sure their versions are matched together
   
   - Architecture: 32 bit or 64 bit
   
   - MSVC version: VCx, VSx
   
   - Thread Safe: ts

3. Close and reopen the board. Click button `change` to choose new version
   
   - Auto update folder of new version into User Environment Variable `Path`

## Auto Virtual Host

1. Generate virtual host with chosen domain and webroot and ssl

2. Auto append `127.0.0.1 {domain}.dev.win` into windows `hosts` file

3. Auto add a certificate of domains `*.dev.win` into windows certification authority

License
----------------------------

This software is licensed under the MIT license.
