//checkConnection.js
var http = null;

function checkConnection(ip, port, username, password)
{
    var fixedIP = ip
    while(fixedIP.indexOf(",")!== -1)
    {
        fixedIP = fixedIP.replace(",",".")
    }

    var url = "http://" + fixedIP + ":" + port + "/requests/status.xml"
    http = new XMLHttpRequest();
    http.open("POST", url, true);

    // Send the proper header information along with the request
    http.setRequestHeader("Authorization", "Basic " + Qt.btoa(username + ":" + password));
    http.onreadystatechange = function() { // Call a function when the state changes.
        timerHTTP.stop();
        if (http.readyState === 4)
        {
            if (http.status === 200)
            {
                return 0;
            }
            else if(http.status === 401)
            {
                return 1;
            }
            else
            {
                return 2;
            }
        }
    }
    http.send();
    delay(500)
}

function delay(time) {
  var d1 = new Date();
  var d2 = new Date();
  while (d2.valueOf() < d1.valueOf() + time)
  {
    d2 = new Date();
  }
  httpConnectionCheck()
}

function httpConnectionCheck()
{
    if (http.readyState !== 4)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}
