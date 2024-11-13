


## Install & get ready

1. install nix: `sh <(curl -L https://nixos.org/nix/install)`
2. create directory for nix file
3. init flake with nix-darwin: `nix flake init -t nix-darwin`
4. change config name: `sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix`
5. Install nix-darwin: `nix run nix-darwin --experimental-features 'nix-command flakes' -- switch --flake ~/nix`


## Usage

Afer install, use the following comand after config changes:

```
darwin-rebuild switch --flake dir/whre/flake.nix/lives/
```


