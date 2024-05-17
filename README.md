# eDuke32

## Network Duke Multiplayer for MAC OSX 

1. Make a folder `~/.eduke32` eg. `/Users/<Your-Mac-Login>/.eduke32` and download _**git repo**_ to that folder
2. Copy Eduke32 to your Applications folder
3. Run Eduke32 to launch Duke3D
4. Press **~** to bring down console. Type `connect <ip address>` to connect to Duke Multiplayer Host

### Auto:

Open `install.sh` with a terminal program eg. `right click > open with terminal`.

Or copy the commands below and run them from Terminal (search terminal & open it):

```bash
mkdir ~/.eduke32; cd ~/.eduke32;
git clone https://github.com/ninjada/eduke32.git ~/.eduke32;
cp -R EDuke32.app /Applications;
open /Applications/EDuke32.app/;
```

Click on Start to launch game

Once in game use tilde **(~)** to bring down console and type `connect <host-server-ip-address>` to join a game

If you receive a warning about opening a downloaded app: `System Preferences > Security & Privacy > Allow apps downloaded from etc`.

## Docker image

Docker image run te application instance in [**xpra**](https://github.com/Xpra-org/xpra).

### how to build

```bash
$ docker build -t ${PWD##*\/}:latest .
```

### how to run

```bash
docker run --rm -p 10000:10000 -it eduke32:latest
```

http://localhost:10000
