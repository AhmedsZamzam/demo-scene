var localSore = new LocalStorageManager;

window.requestAnimationFrame(function () {
    checkName();
});

function checkName() {
    var username = localSore.getUsername();
    if (username != null | username.length > 0) {
        document.getElementById("user").value = username;
    }
    
}

function enter(e) {
    if (e.which == 13 || e.keyCode == 13) {
        play();
    }
}

function play() {
    var user = document.getElementById("user").value;
    if (user == '') {
        alert('You need to provide a name.');
        return;
    }
    localSore.setUsername(user);
    window.location.href = "2048/index.html";
}