//fileCheck.js
var allowedTypes =  ["3ga", "a52", "aac", "ac3", "ape", "awb", "dts", "flac", "it",
                                                        "m4a", "m4p", "mka", "mlp", "mod", "mp1", "mp2", "mp3",
                                                        "oga", "ogg", "oma", "s3m", "spx", "thd", "tta", "wav", "wma",
                                                        "wv", "xm",
                                                        "asf", "avi", "divx", "drc", "dv", "f4v", "flv", "gxf", "iso",
                                                        "m1v", "m2v", "m2t", "m2ts", "m4v", "mkv", "mov", "mp2", "mp4",
                                                        "mpeg", "mpeg1", "mpeg2", "mpeg4", "mpg", "mts", "mtv", "mxf",
                                                        "mxg", "nuv", "ogg", "ogm", "ogv", "ogx", "ps", "rec", "rm", "rmvb",
                                                        "ts", "vob", "wmv",
                                                        "asx", "b4s", "cue", "ifo", "m3u", "m3u8", "pls", "ram", "rar",
                                                        "sdp", "vlc", "xspf", "zip", "conf"
                                                        ]

var allowedSubs =["aqt", "cvd", "dks", "jss", "sub", "ttxt", "mpl", "sub", "pjs", "psb", "rt", "smi", "ssf",
                                                        "srt", "ssa", "sub", "svcd", "usf", "idx", "txt"]

function checkFile(index)
{
    var lastChars = xmlModel.get(index).uri.substring(xmlModel.get(index).uri.length - 8);
    var fileType = lastChars.substring(lastChars.indexOf(".") + 1).toLowerCase();

    if (xmlModel.get(index).type === "file" && allowedTypes.indexOf(fileType) > -1)
        return true;
    else
        return false;
}


function checkFileSubs(index)
{
    var lastChars = xmlModel.get(index).uri.substring(xmlModel.get(index).uri.length - 8);
    var fileType = lastChars.substring(lastChars.indexOf(".") + 1).toLowerCase();

    if (xmlModel.get(index).type === "file" && allowedSubs.indexOf(fileType) > -1)
        return true;
    else
        return false;
}

