/*
*	
*	Miniblip piano protocoder example
*	by paclema on CIRCOLAB
*
*/

ui.screenMode("immersive");

//ui.toolbar.bgColor(55, 155, 155, 255);
//ui.toolbar.show(true);

ui.allowScroll(true);

ui.showVirtualKeys(true);
ui.backgroundColor(0, 0, 0);



media.volume(100);
ui.enableVolumeKeys(true);


//var txt = ui.addText("", 10, 10);
var txt = ui.addText(20, 20, 600, 100);

ui.onKeyDown(function(key) {
    txt.setText("pressed key " +  key);
    switch(key){
        case 21:
            ui.backgroundColor(120, 0, 0);
            media.playSound("sound1.wav");
            break;
        case 19:
            ui.backgroundColor(120, 0, 0);
            media.playSound("sound2.wav");
            break;
        case 20:
            ui.backgroundColor(120, 0, 0);
            media.playSound("sound3.wav");
            break;
        case 22:
            ui.backgroundColor(120, 0, 0);
            media.playSound("sound4.wav");
            break;
        case 24:
            ui.backgroundColor(120, 0, 0);
            media.playSound("sound1.wav");
            break;
        case 25:
            ui.backgroundColor(0, 120, 0);
            media.playSound("sound2.wav");
            break;
    }
});
