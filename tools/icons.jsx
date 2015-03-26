preferences.rulerUnits = Units.POINTS;
var SIZE = [1024, 512, 152, 144, 120, 114, 100, 80, 76, 72, 58, 57, 50, 40, 29];
var dst = activeDocument.path
activeDocument.duplicate();
for (var i = 0; i < SIZE.length; i++) {
    activeDocument.resizeImage(SIZE[i], SIZE[i]);
    var pathAndName = dst + "/Icon-" + SIZE[i] + ".png";
    var fileObj = new File(pathAndName);
    pngOpt = new PNGSaveOptions();
    pngOpt.interlaced = false;
    activeDocument.saveAs(fileObj, pngOpt, true, Extension.LOWERCASE);
}
activeDocument.close(SaveOptions.DONOTSAVECHANGES);
