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

media.volume(80);
ui.enableVolumeKeys(true);

var txt = ui.addText(20, 20, 600, 100);

ui.onKeyDown(function(key) {
    //txt.setText("Pressed key: " +  key);
    switch(key){
        case 21:
            media.playSound("sound5.wav");
            //ui.backgroundImageTile("bq1.png");
            ui.backgroundColor(235, 0, 0);
            break;
        case 19:
            media.playSound("sound6.wav");
            //ui.backgroundImageTile("bq2.png");
            ui.backgroundColor(0, 235, 0);
            break;
        case 20:
            media.playSound("sound7.wav");
            //ui.backgroundImageTile("bq3.png");
            ui.backgroundColor(0, 0, 235);
            break;
        case 22:
            media.playSound("sound8.wav");
            //ui.backgroundImageTile("bq4.png");
            ui.backgroundColor(235, 235, 0);
            break;
        case 24:
            ui.backgroundColor(0, 0, 0);
            media.playSound("sound5.wav");
            //ui.backgroundImageTile("circolab_logo.svg");
            var img = ui.addImage( "circolab_logo.svg", 0, 0, 1080, 1920);
            break;
        case 25:
            ui.backgroundColor(0, 0, 0);
            media.playSound("sound6.wav");
            break;
    }
});