var holdCoverGrp:Map<Int, Array<FunkinSprite>> = [];

function postCreate() {
    for (str in strumLines) {
        var arr = [];

        for (spr in str) {
            spr.x -= 42.5;

            if (!str.cpu) {
                spr.animation.onFinish.add(name -> {
                    switch(name) {
                        case 'confirm':
                            spr.playAnim('pressed', true);
                    }
                });
            }

            var anims = ['Purple', 'Blue', 'Green', 'Red'];
            var animPrefix = anims[spr.ID];

            var holdCover:FunkinSprite = new FunkinSprite(spr.x - 110, spr.y - 95);
            holdCover.frames = Paths.getFrames('game/holdCovers/holdCover' + animPrefix);

            holdCover.animation.addByPrefix('start', 'holdCoverStart' + animPrefix, 24, false);
            holdCover.animation.finishCallback = name -> {
                if (name == 'start') {
                    holdCover.visible = str.visible;
                    holdCover.playAnim('loop', true);
                }
                if (name == 'end') {
                    holdCover.visible = false;
                }
            };

            holdCover.animation.addByPrefix('loop', 'holdCover' + animPrefix, 24, true);
            holdCover.animation.addByPrefix('end', 'holdCoverEnd' + animPrefix, 24, false);

            holdCover.visible = false;

            holdCover.ID = spr.ID;

            insert(FlxG.state.members.indexOf(strumLines) + 1, holdCover);
            holdCover.cameras = [camHUD];
            arr.push(holdCover);
        }

        holdCoverGrp.set(str.ID, arr);
    };

    missesTxt.visible = false;
    accuracyTxt.visible = false;
    scoreTxt.x -= 50;
}

function onNoteHit(event) {
    var note = event.note;

    if (!note.isSustainNote) return;

    // Hold flags
    var holdStart = note.isSustainNote && !note.prevNote.isSustainNote;
    var holdLoop = note.isSustainNote && note.prevNote.isSustainNote;
    var holdEnd = note.isSustainNote && !note.nextNote.isSustainNote;

    var strum = note.strumLine;
    var holdCoverArray = holdCoverGrp.get(strum.ID);

    for (holdCover in holdCoverArray) {
        if (note.noteData != holdCover.ID) continue;

        if (holdStart) {
            holdCover.playAnim('start', true);
        }

        if (holdEnd) {
            holdCover.playAnim('end', true);
            if (strum.cpu) holdCover.animation.finish();
        }
    }
}