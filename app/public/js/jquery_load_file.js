// common variables
//var iMaxFilesize = 1048576; // 1MB
var iMaxFilesize = 2097152; // 2MB

function fileSelected() {

    // get selected file element
    var oFile = document.getElementById('filename').files[0];

    // filter for image files
    var rFilter = /^(image\/bmp|image\/gif|image\/jpeg|image\/png|image\/tiff)$/i;
    if (! rFilter.test(oFile.type)) {
        alert("Please add a valid image format");
        document.getElementById("upload").disabled = true;
        return;
    }

    // little test for filesize
    if (oFile.size > iMaxFilesize) {
        alert("Your file is very big. We can't accept it. Please select more small file");
        document.getElementById("upload").disabled = true;
        return;
    }
    document.getElementById("upload").disabled = false;
}
