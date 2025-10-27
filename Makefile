apply:
	@echo "Applying changes..."
	kpackagetool6 --type=KWin/Script -r ktile
	kpackagetool6 --type=KWin/Script -i ~/Desktop/windows_grid/package
	kwriteconfig6 --file kwinrc --group Plugins --key ktileEnabled true
	kpackagetool6 --type=KWin/Script -l 
	kwin_x11 --replace &   