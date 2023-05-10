var localSore = new LocalStorageManager;

window.requestAnimationFrame(function () {
    fillScoreboardPage(localSore);
    loadScoreboard(localSore);

    window.setInterval(function(){
        /// call your function here
        loadScoreboard(localSore);
        fillScoreboardPage(localSore);
    }, 1000);
});
