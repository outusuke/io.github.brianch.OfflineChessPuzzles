Flatpak build for [offlinechesspuzzles](https://github.com/brianch/offline-chess-puzzles)

```
flatpak run org.flatpak.Builder \
  --force-clean \
  --user \
  --install \
  --install-deps-from=flathub \
  build-dir \
  io.github.brianch.OfflineChessPuzzles.yml
  
  flatpak run io.github.brianch.OfflineChessPuzzles
```
